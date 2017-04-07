import XCTest
@testable import FoodTruckAPI

class FoodTruckAPITests: XCTestCase {
    
    static var allTests : [(String, (FoodTruckAPITests) -> () throws -> Void)] {
        return [
            ("testAddTruck", testAddAndGetTruck),
        ]
    }
    
    var trucks: FoodTruck?
    
    //setup function
    override func setUp() {
        trucks = FoodTruck()
        super.setUp()
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
}
