//
//  FoodTruckController.swift
//  FoodTruckAPI
//
//  Created by Marni Brewster on 3/30/17.
//
//

import Foundation
import Kitura
import LoggerAPI
import SwiftyJSON

public final class FoodTruckController {
    public let trucks: FoodTruckAPI
    public let router = Router()
    public let trucksPath = "api/v1/trucks"
    
    public init(backend: FoodTruckAPI){
        self.trucks = backend
        routeSetup()
    }
    
    public func routeSetup(){
    //parse the body of a request to get items out of it:
    router.all("/*", middleware: BodyParser())
    
    
    }
}
