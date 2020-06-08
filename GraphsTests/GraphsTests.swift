//
//  GraphsTests.swift
//  GraphsTests
//
//  Created by Connor Barnes on 4/23/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import XCTest
@testable import Graphs

class GraphsTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testIndiciesOf() throws {
			// The array's elements are equal to its indicies, so the indicies should match
			let array = (0..<100).map { $0 }
			let indicies = [5, 21, 26, 29, 50]
			XCTAssertEqual(array.indicies(of: indicies).map { $0 }, indicies)
			
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
