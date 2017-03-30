//
//  Config.swift
//  FoodTruckAPI
//
//  Created by Marni Brewster on 3/30/17.
//
//

import Foundation
import LoggerAPI
import CouchDB
import CloudFoundryEnv

struct ConfigError: LocalizedError {
    var errorDescription: String? {
        return "Could not retrieve config info"
    }
}

func getConfig() throws -> Service {
    var appEnv: AppEnv?
    
    do {
        Log.warning("attempting to retrieve CF Env")
        appEnv = try CloudFoundryEnv.getAppEnv()
        
        let services = appEnv!.getServices()
        let servicePair = services.filter { element in element.value.label == "cloudantNoSQLDB"}.first
        
        guard let service = servicePair?.value else {
            throw ConfigError()
        }
        return service
    } catch {
        Log.warning("an error occured while trying to retrieve configs")
        throw ConfigError()
    }
}
