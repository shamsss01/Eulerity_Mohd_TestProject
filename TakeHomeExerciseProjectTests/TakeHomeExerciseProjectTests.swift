//
//  TakeHomeExerciseProjectTests.swift
//  TakeHomeExerciseProjectTests
//
//  Created by Mohd Naqvi on 22/05/26.
//

import XCTest
@testable import TakeHomeExerciseProject

final class TakeHomeExerciseProjectTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
        // XCTest Documentation
        // https://developer.apple.com/documentation/xctest
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testFieldParsing() throws {
        let payload = FormLoader.load()

        XCTAssertEqual(payload.formTitle, "Campaign Setup")
        XCTAssertEqual(payload.fields.count, 4)
    }

    func testUnknownTypeDoesNotCrash() throws {
        let json = """
        {
          "theme": {
            "background_color": "#FFFFFF",
            "text_color": "#111827",
            "border_color": "#D1D5DB",
            "error_color": "#B91C1C"
          },
          "form_title": "Test",
          "fields": [
            {
              "id": "unknown",
              "order": 1,
              "type": "DATE_PICKER",
              "label": "Date"
            }
          ]
        }
        """

        let data = json.data(using: .utf8)!

        let payload = try JSONDecoder().decode(FormPayload.self, from: data)

        XCTAssertNil(payload.fields.first?.type)
    }

}
