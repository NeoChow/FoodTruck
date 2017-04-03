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
    
    ///Lat / Lon Coordinates
    public let latitude: Float
    
    public let longitude: Float

}
