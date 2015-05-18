//
//  FiltersViewController.swift
//  SimpleYelp
//
//  Created by Benjamin Tsai on 5/14/15.
//  Copyright (c) 2015 Benjamin Tsai. All rights reserved.
//

import UIKit

// why is :class needed for weak reference?
protocol FiltersViewControllerDelegate: class {
    func filterViewController(filtersViewController: FiltersViewController, didUpdateFilters: YelpSearchFilters)
}

class FiltersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SwitchCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    var isDistanceCollapsed = true
    var isSortByCollapsed = true
    var isCategoryCollapsed = true
    
    let categoriesWhileCollapsed = 3
    
    private enum FilterSection: Int {
        case Deal = 0
        case Distance
        case SortBy
        case Category
        
        static func fromInt(val: Int) -> FilterSection {
            switch val {
            case FilterSection.Deal.rawValue:
                return .Deal
            case FilterSection.Distance.rawValue:
                return .Distance
            case FilterSection.SortBy.rawValue:
                return .SortBy
            case FilterSection.Category.rawValue:
                return .Category
            default:
                NSLog("Unknown section \(val), returning .Deal")
                return .Deal
            }
        }
        
        static func count() -> Int {
            return 4
        }
    }
    
    weak var delegate: FiltersViewControllerDelegate?
    var filters: YelpSearchFilters!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onCancelButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onSearchButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
        delegate?.filterViewController(self, didUpdateFilters: filters)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return FilterSection.count()
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch FilterSection.fromInt(section) {
        case .Deal:
            return nil
        case .Distance:
            return "Distance"
        case .SortBy:
            return "Sort By"
        case .Category:
            return "Category"
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch FilterSection.fromInt(section) {
        case .Deal:
            return 1
        case .Distance:
            if isDistanceCollapsed {
                return 1
            }
            return filters.distanceCount()
        case .SortBy:
            if isSortByCollapsed {
                return 1
            }
            return filters.sortByCount()
        case .Category:
            if isCategoryCollapsed {
                return categoriesWhileCollapsed + 1
            }
            return filters.categoryCount()
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch FilterSection.fromInt(indexPath.section) {
        case .Deal:
            let cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell", forIndexPath: indexPath) as! SwitchCell
            
            cell.switchLabel.text = "Offering a Deal"
            cell.onSwitch.on = filters.isDealOn()
            cell.delegate = self
            
            return cell
        case .Distance:
            if isDistanceCollapsed {
                let cell = tableView.dequeueReusableCellWithIdentifier("RadioCollapsedCell", forIndexPath: indexPath) as! RadioCollapsedCell
                cell.radioCollapsedLabel.text = filters.distance().label()
                return cell
            }
            
            let cell = tableView.dequeueReusableCellWithIdentifier("RadioCell", forIndexPath: indexPath) as! RadioCell

            cell.radioLabel.text = filters.distanceLabel(indexPath.row)
            cell.setRadioGroup("distance")
            cell.setCheckbox(filters.distance().row() == indexPath.row)
            
            return cell
        case .SortBy:
            if isSortByCollapsed {
                let cell = tableView.dequeueReusableCellWithIdentifier("RadioCollapsedCell", forIndexPath: indexPath) as! RadioCollapsedCell
                cell.radioCollapsedLabel.text = filters.sort().label()
                return cell
            }
            
            let cell = tableView.dequeueReusableCellWithIdentifier("RadioCell", forIndexPath: indexPath) as! RadioCell
            
            cell.radioLabel.text = filters.sortLabel(indexPath.row)
            cell.setRadioGroup("sortby")
            cell.setCheckbox(filters.sort().row() == indexPath.row)
            
            return cell
        case .Category:
            if isCategoryCollapsed {
                if indexPath.row >= categoriesWhileCollapsed {
                    let cell = tableView.dequeueReusableCellWithIdentifier("ShowAllCell", forIndexPath: indexPath) as! UITableViewCell
                    return cell
                }
            }
            let cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell", forIndexPath: indexPath) as! SwitchCell
            
            cell.switchLabel.text = filters.categoryLabel(indexPath.row)
            cell.onSwitch.on = filters.isCategoryOn(indexPath.row)
            cell.delegate = self
            
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        switch FilterSection.fromInt(indexPath.section) {
        case .Distance:
            if isDistanceCollapsed {
                isDistanceCollapsed = false
                tableView.reloadSections(NSIndexSet(index: FilterSection.Distance.rawValue), withRowAnimation: .Fade)
            } else {
                isDistanceCollapsed = true
                filters.distance(indexPath.row)

                let cell = tableView.cellForRowAtIndexPath(indexPath) as! RadioCell
                cell.onSelect()
                
                tableView.reloadSections(NSIndexSet(index: FilterSection.Distance.rawValue), withRowAnimation: .Fade)
            }
        case .SortBy:
            if isSortByCollapsed {
                isSortByCollapsed = false
                tableView.reloadSections(NSIndexSet(index: FilterSection.SortBy.rawValue), withRowAnimation: .Fade)
            } else {
                isSortByCollapsed = true
                filters.sort(indexPath.row)
                
                let cell = tableView.cellForRowAtIndexPath(indexPath) as! RadioCell
                cell.onSelect()
                
                tableView.reloadSections(NSIndexSet(index: FilterSection.SortBy.rawValue), withRowAnimation: .Fade)
            }
        case .Category:
            if isCategoryCollapsed && indexPath.row >= categoriesWhileCollapsed {
                isCategoryCollapsed = false
                tableView.reloadSections(NSIndexSet(index: FilterSection.Category.rawValue), withRowAnimation: .Fade)
            }
        default:
            NSLog("didSelectRow default")
        }
    }
    
    func switchCell(switchCell: SwitchCell, didChangeValue value: Bool) {
        let indexPath = tableView.indexPathForCell(switchCell)!

        switch FilterSection.fromInt(indexPath.section) {
        case .Deal:
            filters.setDeal(value)
        case .Category:
            filters.setCategory(indexPath.row, isOn: value)
        default:
            NSLog("Unknown switch cell section \(indexPath.section)")
        }
    }
}
