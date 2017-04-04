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
    
        //FoodTruck Handling
        // all trucks:
        router.get(trucksPath, handler: getTrucks)
        //add truck:
        router.post(trucksPath, handler: addTruck)
        
    }
    
    private func getTrucks(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        trucks.getAllTrucks { (trucks, err) in
            do {
                guard err == nil else {
                    try response.status(.badRequest).end()
                    Log.error(err.debugDescription)
                    return
                }
                guard let trucks = trucks else {
                    try response.status(.internalServerError).end()
                    Log.error("failed to get trucks")
                    return
                }
                let json = JSON(trucks.toDict())
                try response.status(.OK).send(json: json).end()
            } catch {
                Log.error("communications error")
            } 
        }
        
    }
    private func addTruck(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        //make sure we have a body:
        guard let body = request.body else {
            response.status(.badRequest)
            Log.error("no body found in request")
            return
        }
        
        //.json is enum value in bodyparser in kitura: make sure we have json in body
        guard case let .json(json) = body else {
            response.status(.badRequest)
            Log.error("invalid JSON data")
            return
        }
        //if we pass this, we have json in format we can use:
        let name: String = json["name"].stringValue
        let foodType: String = json["foodtype"].stringValue
        let avgCost: Float = json["avgcost"].floatValue // use non-optional value
        let latitude: Float = json["latitude"].floatValue
        let longitude: Float = json["longitude"].floatValue
        
        guard name != "" else {
            response.status(.badRequest)
            Log.error("necessary fields not supplied")
            return
        }
        
        trucks.addTruck(name: name, foodType: foodType, avgCost: avgCost, latitude: latitude, longitude: longitude) { (truck, err) in
            do {
                guard err == nil else {
                    try response.status(.badRequest).end()
                    Log.error(err.debugDescription)
                    return
                }
                
                guard let truck = truck else { //use guard to unwrap truck arg and make sure it's there
                    try response.status(.internalServerError).end()
                    Log.error("truck not found")
                    return
                }
                
                let result = JSON(truck.toDict())
                Log.info("\(name) added to Vehicle List")
                do {
                    try response.status(.OK).send(json: result).end()
                } catch {
                    Log.error("error sending response")
                }
            } catch {
                Log.error("communications error")
            }
        }
    }
}
