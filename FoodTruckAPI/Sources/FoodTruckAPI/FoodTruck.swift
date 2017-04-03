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
    }
    
    
}
