 import Foundation
 import Kitura
 import HeliumLogger
 import LoggerAPI
 import LoggerAPI
 import CloudFoundryEnv
 import FoodTruckAPI
 
 HeliumLogger.use()
 
 let trucks: FoodTruck
 
 do {
    Log.info("attempting to init with CF environment")
    let service = try getConfig()
    Log.info("Init with Service")
    trucks = FoodTruck(service: service)
    
 } catch {
    Log.info("Could not retrieve CV env: init with defaults")
    trucks = FoodTruck()
 }
 
 let controller = FoodTruckController(backend: trucks)
 
 do {
    let port = try CloudFoundryEnv.getAppEnv().port
    Log.verbose("assigned port \(port)")

    Kitura.addHTTPServer(onPort: port, with: controller.router)
    Kitura.run()
 } catch {
    Log.error("server failed to start")
 }
 
 
