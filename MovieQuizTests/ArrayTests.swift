import Foundation
import XCTest
@testable import MovieQuiz

class ArrayTests: XCTestCase {
    
    func getValueInRange() throws {
        let array = [1, 2, 3, 4, 5]
        
        let value = array[safe: 2]
        
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 2)
    }
    
    func testGetValueOutOfRange() throws {
        let array = [1, 2, 3, 4, 5]
        
        let value = array[safe: 20]
        
        XCTAssertNil(value)
    }
    
}

