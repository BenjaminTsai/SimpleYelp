//
//  YelpSearchSettings.swift
//  SimpleYelp
//
//  Created by Benjamin Tsai on 5/14/15.
//  Copyright (c) 2015 Benjamin Tsai. All rights reserved.
//

import Foundation

enum FilterDistance: Int {
    // in meters
    case Auto = 0
    case Mile_0_3
    case Mile_1_0
    case Mile_5_0
    case Mile_20_0
    
    func label() -> String {
        switch self {
        case .Auto:
            return "Auto"
        case .Mile_0_3:
            return "0.3 mile"
        case .Mile_1_0:
            return "1 mile"
        case .Mile_5_0:
            return "5 miles"
        case .Mile_20_0:
            return "20 miles"
        }
    }
    
    func row() -> Int {
        return self.rawValue
    }
    
    func api() -> Int {
        switch self {
        case .Auto:
            return 0
        case .Mile_0_3:
            return 482
        case .Mile_1_0:
            return 1609
        case .Mile_5_0:
            return 8047
        case .Mile_20_0:
            return 32187
        }
    }
    
    static func fromRow(row: Int) -> FilterDistance {
        switch row {
        case Auto.row():
            return .Auto
        case Mile_0_3.row():
            return .Mile_0_3
        case Mile_1_0.row():
            return .Mile_1_0
        case Mile_5_0.row():
            return .Mile_5_0
        case Mile_20_0.row():
            return .Mile_20_0
        default:
            NSLog("Unknown row for FilterDistance \(row)")
            return .Auto
        }
    }
    
    static func count() -> Int {
        return 5
    }
}

enum FilterSort: Int {
    case BestMatched = 0
    case Distance
    case Rating
    
    func label() -> String {
        switch self {
        case .BestMatched:
            return "Best Matched"
        case .Distance:
            return "Distance"
        case .Rating:
            return "Rating"
        }
    }
    
    func row() -> Int {
        return self.rawValue
    }
    
    func api() -> Int {
        return self.rawValue
    }
    
    static func fromRow(row: Int) -> FilterSort {
        switch row {
        case BestMatched.row():
            return .BestMatched
        case Distance.row():
            return .Distance
        case Rating.row():
            return .Rating
        default:
            NSLog("Unknown row for FilterSort \(row)")
            return .BestMatched
        }
    }
    
    static func count() -> Int {
        return 3
    }
}

class YelpSearchFilters {
    var searchString: String? = "Taiwanese"
    private let latitudeValue = 37.785771
    private let longitudeValue = -122.406165
    
    private var deal = false
    private var categories: [[String:String]]!
    private var categoryStates = [Int:Bool]()
    private var distanceValue = FilterDistance.Auto
    private var sortValue = FilterSort.BestMatched
    
    init() {
        categories = yelpCategories()
    }
    
    init(other: YelpSearchFilters) {
        searchString = other.searchString
        categories = other.categories
        categoryStates = other.categoryStates
        deal = other.deal
        distanceValue = other.distanceValue
        sortValue = other.sortValue
    }
    
    func setDeal(isOn: Bool) {
        deal = isOn
    }
    
    func isDealOn() -> Bool {
        return deal
    }
    
    // LOCATION
    
    func latitude() -> Double {
        return latitudeValue
    }
    
    func longitude() -> Double {
        return longitudeValue
    }
    
    // DISTANCE
    
    func distance() -> FilterDistance {
        return distanceValue
    }
    
    func distance(row: Int) {
        distanceValue = FilterDistance.fromRow(row)
    }
    
    func distanceLabel(row: Int) -> String {
        return FilterDistance.fromRow(row).label()
    }
    
    func distanceCount() -> Int {
        return FilterDistance.count()
    }
    
    // SORT
    
    func sort() -> FilterSort {
        return sortValue
    }
    
    func sort(row: Int) {
        sortValue = FilterSort.fromRow(row)
    }

    func sortLabel(row: Int) -> String {
        return FilterSort.fromRow(row).label()
    }
    
    func sortByCount() -> Int {
        return FilterSort.count()
    }
    
    // CATEGORY
    
    func setCategory(row: Int, isOn: Bool) {
        categoryStates[row] = isOn
    }
    
    func isCategoryOn(row: Int) -> Bool {
        return categoryStates[row] ?? false
    }
    
    func categoryLabel(row: Int) -> String {
        return categories[row]["name"]!
    }
    
    func categoryCount() -> Int {
        return categories.count
    }
    
    func categoryForSearch() -> [String] {
        var searchCategories = [String]()
        
        for (row, isOn) in categoryStates {
            if isOn {
                searchCategories.append(categories[row]["code"]!)
            }
        }

        return searchCategories
    }
    
    private func yelpCategories() -> [[String:String]] {
        // A few spot picked categories available in US Yelp
        return [
            ["name" : "Taiwanese", "code": "taiwanese"],
            ["name" : "Japanese", "code": "japanese"],
            ["name" : "French", "code": "french"],
            ["name" : "Italian", "code": "italian"],
            ["name" : "Korean", "code": "korean"],
            ["name" : "Chinese", "code": "chinese"],
            ["name" : "Comfort Food", "code": "comfortfood"],
            ["name" : "Vietnamese", "code": "vietnamese"],
            ["name" : "American, New", "code": "newamerican"],
            ["name" : "American, Traditional", "code": "tradamerican"],
        ]
    }
    
}