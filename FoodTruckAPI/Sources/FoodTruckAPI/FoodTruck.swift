//
//  FoodTruck.swift
//  FoodTruckAPI
//
//  Created by Marni Brewster on 3/30/17.
//
//

import Foundation
import SwiftyJSON
import LoggerAPI
import CouchDB
import CloudFoundryEnv

#if os(Linux)
    typealias Valuetype = Any
#else
    typealias Valuetype = AnyObject
#endif

public enum APICollectionError: Error {
    case ParseError
    case AuthError
    
}

public class FoodTruck: FoodTruckAPI {
    
    static let defaultDBHost = "localhost"
    static let defaultDBPort = UInt16(5984)
    static let defaultDBName = "foodtruckapi"
    static let defaultUsername = "marni"
    static let defaultPassword = "123456"
    
    let dbName = "foodtruckapi"
    let designName = "foodtruckdesign"
    let connectionProps: ConnectionProperties
    
    public init(database: String = FoodTruck.defaultDBName, host: String = FoodTruck.defaultDBHost, port: uint16 = FoodTruck.defaultDBPort, username: String? = FoodTruck.defaultUsername, password: String? = FoodTruck.defaultPassword) {
        
        //if on bluemix, it will be secure (if host == default host, it'll be false
        let secured = (host == FoodTruck.defaultDBHost) ? false : true
        connectionProps = ConnectionProperties(host: host, port: Int16(port), secured: secured, username: username, password: password)
        
        setupDb()
    }
    
    public convenience init (service: Service) {
        let host: String
        let username: String?
        let password: String?
        let port: UInt16
        let databaseName: String = "foodtruckapi"
        
        if let credentials = service.credentials, let tempHost = credentials["host"] as? String, let tempUsername = credentials["username"] as? String, let tempPassword = credentials["password"] as? String, let tempPort = credentials["port"] as? Int {
            host = tempHost
            username = tempUsername
            password = tempPassword
            port = UInt16(tempPort)
            Log.info("using CF Service Credentials")
        } else {
            host = "localhost"
            username = "marni"
            password = "123456"
            port = UInt16(5984)
            Log.info("using service development credentials")
            
        }
        self.init(database: databaseName, host: host, port: port, username: username, password: password)
    }
    
    private func setupDb() {
        let couchClient = CouchDBClient(connectionProperties: self.connectionProps)
        couchClient.dbExists(dbName) { (exists, error) in
            if (exists ) {
                Log.info("DB exists")
            } else {
                Log.error("DB doesn't exist \(error)")
                couchClient.createDB(self.dbName, callback: { (db, error) in
                    if (db != nil ) {
                        Log.info("DB created")
                        self.setupDbDesign(db: db!)
                    } else {
                        Log.error("unable to create db \(self.dbName): Error \(error)")
                    }
                })
            }
        }
    }
    
    private func setupDbDesign(db: Database) {
        let design: [String: Any] = [
            "_id": "_design/foodtruckdesign",
            "views": [
                "all_documents": [
                    "map": "function(doc) { emit(doc._id, [doc._id, doc._rev]);  }"
                ],
                "all_trucks": [
                    "map": "function(doc) { if (doc.type == 'foodtruck') { emit(doc._id, [doc._id, doc.name, doc.foodtype, doc.avgcost, doc.latitude, doc.longitude]); }}"
                ],
                "total_trucks": [
                    "map": "function(doc) {if (doc.type == 'foodtruck') {emit(doc.id, 1); }}",
                    "reduce": "_count"
                ]
            ]
        ]
        db.createDesign(self.designName, document: JSON(design)) { (json, error) in
            if error != nil {
                Log.error("failed to create design: \(error)")
            } else {
                Log.info("design created: \(json)")
            }
        }
    }
    
    public func getAllTrucks(completion: @escaping ([FoodTruckItem]?, Error?) -> Void) {
        let couchClient = CouchDBClient(connectionProperties: connectionProps)
        let database = couchClient.database(dbName)
        
        database.queryByView("all_trucks", ofDesign: designName, usingParameters: [.descending(true), .includeDocs(true)]) { (doc, err) in
            
            if let doc = doc, err == nil {
                do {
                    let trucks = try self.parseTrucks(doc)
                    completion(trucks, nil)
                } catch {
                    completion(nil, err)
                }
            } else {
                completion(nil, err)
            }
        }
    }
    
    func parseTrucks(_ document: JSON) throws -> [FoodTruckItem] {
        guard let rows = document["rows"].array else {
            throw APICollectionError.ParseError
        }
        
        let trucks: [FoodTruckItem] = rows.flatMap {
            let doc = $0["value"]
            guard let id = doc[0].string,
                let name = doc[1].string,
                let foodType = doc[2].string,
                let avgCost = doc[3].float,
                let latitude = doc[4].float,
                let longitude = doc[5].float else {
                    return nil
            }
            return FoodTruckItem(docId: id, name: name, foodType: foodType, avgCost: avgCost, latitude: latitude, longitude: longitude)
        }
        return trucks
    }
    
    //Get specific Food Truck
    public func getTruck(docId: String, completion: @escaping (FoodTruckItem?, Error?) -> Void) {
        
        //setup db connection
        let couchClient = CouchDBClient(connectionProperties: connectionProps)
        let database = couchClient.database(dbName)
        
        database.retrieve(docId) { (doc, err) in
            guard let doc = doc,
                let docId = doc["_id"].string,
                let name = doc["name"].string,
                let foodType = doc["foodtype"].string,
                let avgCost = doc["avgcost"].float,
                let latitude = doc["latitude"].float,
                let longitude = doc["longitude"].float else {
            completion(nil, err)
            return
            }
            let truckItem = FoodTruckItem(docId: docId, name: name, foodType: foodType, avgCost: avgCost, latitude: latitude, longitude: longitude)
            completion(truckItem, nil)
        }
        
    }
    
    //Add Food Truck
    public func addTruck(name: String, foodType: String, avgCost: Float, latitude: Float, longitude: Float, completion: @escaping (FoodTruckItem?, Error?) -> Void) {
        let json: [String: Any] = [
            "type": "foodtruck",
            "name": name,
            "foodtype": foodType,
            "avgcost": avgCost,
            "latitude": latitude,
            "longitude": longitude
        ]
        //setup connection to db:
        let couchClient = CouchDBClient(connectionProperties: connectionProps)
        let database = couchClient.database(dbName)
        //id, revision, doc, err are all optional, need to unwrap:
        database.create(JSON(json)) { (id, revision, doc, err) in
            if let id = id {
                let truckItem = FoodTruckItem(docId: id, name: name, foodType: foodType, avgCost: avgCost, latitude: latitude, longitude: longitude)
                completion(truckItem, nil)
            } else {
                completion(nil, err)
            }
        }
    }
    
    //Remove all Food Trucks (for testing, need to be able to wipe all trucks in db)
    //won't make this available to client code, just for testing
    public func clearAll(completion: @escaping (Error?) -> Void) {
        
        let couchClient = CouchDBClient(connectionProperties: connectionProps)
        let database = couchClient.database(dbName)
        //query by view, get all docs
        database.queryByView("all_documents", ofDesign: "foodtruckdesign", usingParameters: [.descending(true), .includeDocs(true)]) { (doc, err) in
            
            //walk through and get id and revision for each to delete
            guard let doc = doc else {
                completion(err)
                return
            }
            guard let idAndRev = try? self.getIdAndRev(doc) else {
                completion(err)
                return
            }
            
            if idAndRev.count == 0 {
                completion(nil)
            } else {
                for i in 0...idAndRev.count - 1 {
                    let truck = idAndRev[i]
                    
                    database.delete(truck.0, rev: truck.1, callback: { (err) in
                        guard err == nil else {
                            completion(err)
                            return
                        }
                        completion(nil)
                    })
                }
            }
        }
    }
    
    func getIdAndRev(_ document: JSON) throws -> [(String, String)] {
        guard let rows = document["rows"].array else {
            throw APICollectionError.ParseError
        }
        return rows.flatMap {
            let doc = $0["doc"]
            let id = doc["_id"].stringValue
            let rev = doc["_rev"].stringValue
            return (id, rev)
        }
    }
    
    //Delete specific Food Truck
    public func deleteTruck(docId: String, completion: @escaping (Error?) -> Void) {
        let couchClient = CouchDBClient(connectionProperties: connectionProps)
        let database = couchClient.database(dbName)
        
        //fetch doc
        database.retrieve(docId) { (doc, err) in
            guard let doc = doc , err == nil else {
                completion(nil)
                return
                
            }
            
            //TODO: fetch all reviews
            
            //TODO: once have reviews, go through each and delete them:
            
            
            //get revision:
            let rev = doc["_rev"].stringValue
            
            //delete:
            database.delete(docId, rev: rev) { (err) in
                if err != nil {
                    completion(err)
                } else {
                    completion(nil)
                }
            }
        }
    }
}
