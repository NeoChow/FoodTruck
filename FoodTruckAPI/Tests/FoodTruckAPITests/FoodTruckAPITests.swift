import XCTest
@testable import FoodTruckAPI

class FoodTruckAPITests: XCTestCase {
    
    static var allTests : [(String, (FoodTruckAPITests) -> () throws -> Void)] {
        return [
            ("testAddTruck", testAddAndGetTruck),
            ("testUpdateTruck", testUpdateTruck),
            ("testClearAll", testClearAll),
            ("testDeleteTruck", testDeleteTruck)
        ]
    }
    
    var trucks: FoodTruck?
    
    //setup function
    override func setUp() {
        trucks = FoodTruck()
        super.setUp()
    }
    
    //runs when test finishes: clear db
    override func tearDown() {
        guard let trucks = trucks else {
            return
        }
        trucks.clearAll { (err) in
            guard err == nil else {
                return
            }
        }
    }
    
    //add and get a specific truck:
    func testAddAndGetTruck() {
        guard let trucks = trucks else {
            XCTFail()
            return
        }
        
        //(async calls: add an expectation)
        let addExpectation = expectation(description: "Add truck item")
        
        //add new truck
        trucks.addTruck(name: "testAdd", foodType: "testType", avgCost: 0, latitude: 0, longitude: 0) { (addedTruck, err) in
            
            guard err == nil else {
                XCTFail()
                return
            }
            if let addedTruck = addedTruck {
                trucks.getTruck(docId: addedTruck.docId, completion: { (returnedTruck, err) in
                    //assert that added truck == returned truck:
                    XCTAssertEqual(addedTruck, returnedTruck)
                    addExpectation.fulfill()
                })
            }
        }
        waitForExpectations(timeout: 5) { (err) in
            XCTAssertNil(err, "addTruck timeout")
        }
    }
    
    func testUpdateTruck() {
        guard let trucks = trucks else {
            XCTFail()
            return
        }
        let updateExpectation = expectation(description: "update truck item")
        
        //first add new truck
        trucks.addTruck(name: "testUpdate", foodType: "testUpdate", avgCost: 0, latitude: 0, longitude: 0) { (addedTruck, err) in
            guard err == nil else {
                XCTFail()
                return
            }
            if let addedTruck = addedTruck {
                //we know original truck bc we just added it, now update: 
                trucks.updateTruck(docId: addedTruck.docId, name: "updatedtruck", foodType: nil, avgCost: nil, latitude: nil, longitude: nil, completion: { (updatedTruck, err) in
                    guard err == nil else {
                        XCTFail()
                        return
                    }
                    if let updatedTruck = updatedTruck {
                        //fetch truck from database
                        trucks.getTruck(docId: addedTruck.docId, completion: { (fetchedTruck, err) in
                            //assert that added truck and fetched truck are same:
                            XCTAssertEqual(fetchedTruck, updatedTruck)
                            updateExpectation.fulfill()
                            
                        })
                    }
                })
            }
            
        }
        waitForExpectations(timeout: 5) { (err) in
            XCTAssertNil(err, "update truck timeout")
        }
    }
    
    func testClearAll() {
        guard let trucks = trucks else {
            XCTFail()
            return
        }
        let clearExpectation = expectation(description: "clear all db docs")
        
        trucks.clearAll { (err) in
            
            
        }
        trucks.countTrucks { (count, err) in
            XCTAssertEqual(count, 0)
            
            //todo: countReviews, clear reviews
            
            clearExpectation.fulfill()
            
        }
        waitForExpectations(timeout: 5) { (err) in
            XCTAssertNil(err, "clearAll Timeout")
        }
    }
    
    //Delete Truck
    func testDeleteTruck() {
        guard let trucks = trucks else {
            XCTFail()
            return
        }
        
        let deleteExpectation = expectation(description: "delete a specific truck")
        
        //1) add truck, then 2) delete
        trucks.addTruck(name: "testDelete", foodType: "testDelete", avgCost: 0, latitude: 0, longitude: 0) { (addedTruck, err) in
            guard err == nil else {
                XCTFail()
                return
            }
            if let addedTruck = addedTruck {
                //todo: second add a review
                
                //now delete truck:
                trucks.deleteTruck(docId: addedTruck.docId, completion: { (err) in
                    guard err == nil else {
                        XCTFail()
                        return
                    }
                    
                })
                //count trucks and reviews to assert that count == 0
                trucks.countTrucks(completion: { (count, err) in
                    XCTAssertEqual(count, 0)
                
                    deleteExpectation.fulfill()
                })
                
            }
        }
        waitForExpectations(timeout: 5) { (err) in
            XCTAssertNil(err, "delete truck timeout")
        }
    }

}
