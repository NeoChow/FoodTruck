//
//  FoodTruckItem.swift
//  FoodTruckAPI
//
//  Created by Marni Brewster on 4/3/17.
//
//

import Foundation

typealias JSONDictionary = [String: Any]

protocol  DictionaryConvertible {
    func toDict() -> JSONDictionary
}

public struct FoodTruckItem {
    /// ID
    public let docId: String
    
    ///Name of the FoodTruck Business
    public let name: String
    
    ///Food Type
    public let foodType: String
    
    ///Average Cost
    public let avgCost: Float
    
    ///Lat Coordinates
    public let latitude: Float
    
    ///Lon Coordinates
    public let longitude: Float

    public init(docId: String, name: String, foodType: String, avgCost: Float, latitude: Float, longitude: Float) {
        self.docId = docId
        self.name = name
        self.foodType = foodType
        self.avgCost = avgCost
        self.latitude = latitude
        self.longitude = longitude
    }
}

extension FoodTruckItem: Equatable {
    public static func == (lhs: FoodTruckItem, rhs: FoodTruckItem) -> Bool {
        return lhs.name == rhs.name &&
        lhs.foodType == rhs.foodType &&
        lhs.avgCost == rhs.avgCost &&
        lhs.latitude == rhs.latitude &&
        lhs.longitude == rhs.longitude
    }
}

extension FoodTruckItem: DictionaryConvertible {
    func toDict() -> JSONDictionary {
        var result = JSONDictionary()
        result["id"] = self.docId
        result["name"] = self.name
        result["foodtype"] = self.foodType
        result["avgcost"] = self.avgCost
        result["latitude"] = self.latitude
        result["longitude"] = self.longitude
        
        return result
    }
}

extension Array where Element: DictionaryConvertible {
    func toDict() -> [JSONDictionary] {
        return self.map { $0.toDict() }
    }
}
