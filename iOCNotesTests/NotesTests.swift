//
//  NotesTests.swift
//  iOCNotesTests
//
//  Created by Peter Hedlund on 10/20/19.
//  Copyright © 2019 Peter Hedlund. All rights reserved.
//

import XCTest
@testable import iOCNotes

class NotesTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAddNote() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let expectation = XCTestExpectation(description: "Note Expectation")
        let content = "Note added during test"
        NotesManager.shared.add(content: content, category: Constants.noCategory, completion: { note in
            XCTAssertNotNil(note, "Expected note to not be nil")
            XCTAssertTrue(note?.addNeeded == false, "Expected addNeeded to be false")
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 10.0)
    }

    func testAddNoteWithCategory() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let expectation = XCTestExpectation(description: "Note Expectation")
        let content = "Note with categorty added during test"
        let category = "Test Category"
        NotesManager.shared.add(content: content, category: category, completion: { note in
            XCTAssertNotNil(note, "Expected note to not be nil")
            XCTAssertTrue(note?.addNeeded == false, "Expected addNeeded to be false")
            XCTAssertEqual(note?.category, "Test Category", "Expected the category to be Test Category")
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 10.0)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
