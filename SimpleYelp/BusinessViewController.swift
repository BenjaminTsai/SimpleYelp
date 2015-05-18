//
//  BusinessViewController.swift
//  SimpleYelp
//
//  Created by Benjamin Tsai on 5/12/15.
//  Copyright (c) 2015 Benjamin Tsai. All rights reserved.
//

import UIKit
import MapKit

class BusinessViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FiltersViewControllerDelegate {

    private var searchFilters = YelpSearchFilters()
    private var searchBar: UISearchBar!
    private var businesses: [Business]!
    private var totalBusinesses: Int?

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBAction func onListMapChange(sender: AnyObject) {
        let segment = sender as! UISegmentedControl
        if segment.selectedSegmentIndex == 0 {
            tableView.hidden = false
            mapView.hidden = true
        } else {
            tableView.hidden = true
            mapView.hidden = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // initialize UISearchBar
        searchBar = UISearchBar()
        searchBar.delegate = self
        
        // add search bar to navigation bar
        searchBar.sizeToFit()
        navigationItem.titleView = searchBar
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        mapView.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if businesses != nil {
            if totalBusinesses == businesses!.count {
                return businesses!.count
            }
            return businesses!.count + 1
        } else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let businessCount = businesses?.count ?? 0
        if indexPath.row < businessCount {
            let cell = tableView.dequeueReusableCellWithIdentifier("BusinessCell", forIndexPath: indexPath) as! BusinessCell
            cell.business = businesses[indexPath.row]
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("LoadingCell", forIndexPath: indexPath) as! LoadingCell
            return cell
        }
    }
    
    // Infinite scrolling
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let businessCount = businesses?.count ?? 0
        if indexPath.row == businessCount {
            doSearch(offset: businessCount)
        }
    }
    
    func doSearch(offset: Int = 0) {
        if offset == 0 {
            tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
        }
        
        Business.search(searchFilters, withOffset: offset,
            onSuccess: { (businesses: [Business], total: Int) -> Void in
                self.totalBusinesses = total
                if offset == 0 {
                    self.businesses = businesses
                    self.tableView.reloadData()
                } else if businesses.count > 0 {
                    let additionalRows = businesses.count
                    self.businesses = self.businesses + businesses
                    
                    var indexPaths = [NSIndexPath]()
                    for i in 1...additionalRows {
                        indexPaths.append(NSIndexPath(forRow: self.businesses.count - i, inSection: 0))
                    }
                    
                    self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
                } else {
                    NSLog("Search returned 0 results with > 0 offset, should never happen")
                    self.tableView.reloadData()
                }
                
                self.mapView.removeAnnotations(self.mapView.annotations)
                for b in self.businesses {
                    self.mapView.addAnnotation(b)
                }
                self.centerMap()
            }, onError: { (error: NSError) -> Void in
                NSLog("Error while searching, %@", error)
            }
        )
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let navigationController = segue.destinationViewController as! UINavigationController
        let filtersViewController = navigationController.topViewController as! FiltersViewController
        
        filtersViewController.filters = YelpSearchFilters(other: searchFilters)
        filtersViewController.delegate = self
    }
    
    func filterViewController(filtersViewController: FiltersViewController, didUpdateFilters: YelpSearchFilters) {
        searchFilters = YelpSearchFilters(other: didUpdateFilters)
        doSearch()
    }

    func centerMap() {
        let location = CLLocation(latitude: searchFilters.latitude(), longitude: searchFilters.longitude())
        var diameter = Double(searchFilters.distance().api() * 2)

        if diameter == 0 {
            // Auto distance
            diameter = 100000
        }
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, diameter, diameter)
        
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
}

extension BusinessViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true;
    }
    
    func searchBarShouldEndEditing(searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(false, animated: true)
        return true;
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchFilters.searchString = searchBar.text
        searchBar.resignFirstResponder()
        doSearch()
    }
}

