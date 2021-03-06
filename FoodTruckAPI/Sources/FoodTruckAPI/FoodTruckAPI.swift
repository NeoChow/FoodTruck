public protocol FoodTruckAPI {
    // MARK: Trucks
    // Get all Food Trucks
    func getAllTrucks(completion: @escaping ([FoodTruckItem]?, Error?) -> Void)
    
    //Get specific Food Truck
    func getTruck(docId: String, completion: @escaping (FoodTruckItem?, Error?) -> Void)
    
    //Add Food Truck
    func addTruck(name: String, foodType: String, avgCost: Float, latitude: Float, longitude: Float, completion: @escaping (FoodTruckItem?, Error?) -> Void)
    
    //Remove all Food Trucks (for testing, need to be able to wipe all trucks in db)
    func clearAll(completion: @escaping (Error?) -> Void)
    
    //Delete specific Food Truck
    func deleteTruck(docId: String, completion: @escaping (Error?) -> Void)
    
    //Update specific Food Truck
    func updateTruck(docId: String, name: String?, foodType: String?, avgCost: Float?, latitude: Float?, longitude: Float?, completion: @escaping (FoodTruckItem?, Error?) -> Void )
    
    //Get count of all Food Trucks
    func countTrucks(completion: @escaping (Int?, Error?) -> Void)
}
