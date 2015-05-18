//
//  YelpClient.swift
//  SimpleYelp
//
//  Created by Benjamin Tsai on 5/11/15.
//  Copyright (c) 2015 Benjamin Tsai. All rights reserved.
//

import OAuthSwift
import Alamofire

enum YelpSortMode: Int {
    case BestMatched = 0, Distance, HighestRated
}

class YelpClient {

    let consumerKey: String
    let consumerSecret: String
    let token: String
    let tokenSecret: String

    private struct Instance {
        static let client = YelpClient()
    }
    
    static func mainClient() -> YelpClient {
        return Instance.client
    }
    
    init() {
        let secrets = NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("secrets", ofType: "plist")!)!
        consumerKey = secrets["consumerKey"] as! String
        consumerSecret = secrets["consumerSecret"] as! String
        token = secrets["token"] as! String
        tokenSecret = secrets["tokenSecret"] as! String
    }
    
    func search(filters: YelpSearchFilters, withOffset offset: Int, onSuccess: ([Business], Int) -> Void, onError: (NSError) -> Void) {
        if filters.searchString == nil {
            onSuccess([Business](), 0)
            return
        }
        
        // Default the location to San Francisco
        var parameters: [String : AnyObject] = ["term": filters.searchString!]

        // Lat / Long
        parameters["ll"] = "\(filters.latitude()),\(filters.longitude())"
        
        // Offset
        parameters["offset"] = offset
        
        // Categories
        let categories = filters.categoryForSearch()
        if categories.count > 0 {
            parameters["category_filter"] = ",".join(categories)
        }
        
        // Deal
        parameters["deals_filter"] = filters.isDealOn()

        // Distance
        if filters.distance() != FilterDistance.Auto {
            parameters["radius_filter"] = filters.distance().api()
        }
        
        // Sort
        parameters["sort"] = filters.sort().api()
        
        let client = OAuthSwiftClient(
            consumerKey: consumerKey,
            consumerSecret: consumerSecret,
            accessToken: token,
            accessTokenSecret: tokenSecret
        )
        
        client.get(
            "http://api.yelp.com/v2/search",
            parameters: parameters,
            success: { (data, response) -> Void in
                var parseError: NSError?
                let parsedObject = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: &parseError) as! NSDictionary
                
                let total = parsedObject["total"] as! Int
                let dictionaries = parsedObject["businesses"] as? [NSDictionary]
                
                if dictionaries != nil {
                    onSuccess(Business.businesses(array: dictionaries!), total)
                }
            },
            failure: { (error) -> Void in
                onError(error)
            }
        )
    }
}