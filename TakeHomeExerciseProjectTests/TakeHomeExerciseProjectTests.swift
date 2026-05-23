//
//  TakeHomeExerciseProjectTests.swift
//  TakeHomeExerciseProjectTests
//
//  Created by Mohd Naqvi on 22/05/26.
//

import XCTest
@testable import TakeHomeExerciseProject

final class TakeHomeExerciseProjectTests: XCTestCase {

    func testFieldParsing() throws {
        let payload = FormLoader.load()

        XCTAssertEqual(payload.formTitle, "About Yourself")
        XCTAssertFalse(payload.fields.isEmpty)
        XCTAssertEqual(payload.theme.backgroundColor, "#EEEAB5")
    }

    func testUnknownTypeDoesNotCrash() throws {
        let json = """
        {
          "theme": {
            "background_color": "#FFFFFF",
            "text_color": "#111827",
            "clickable_text_color": "#000000",
            "border_color": "#D1D5DB",
            "error_color": "#B91C1C",
            "button_color": "#2563EB"
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

        if case .unknown(let rawType) = payload.fields.first?.type {
            XCTAssertEqual(rawType, "DATE_PICKER")
        } else {
            XCTFail("Expected unknown field type")
        }
    }

    func testRenderableFieldsExcludeUnknownTypes() {
        let viewModel = FormViewModel()
        XCTAssertTrue(viewModel.renderableFields.allSatisfy { $0.type?.isSupported == true })
        XCTAssertFalse(viewModel.renderableFields.contains { $0.id == "unknown_1" })
    }

    func testPartialThemeUsesDefaults() throws {
        let json = """
        {
          "theme": {
            "background_color": "#ABCDEF"
          },
          "form_title": "Partial",
          "fields": []
        }
        """

        let payload = try JSONDecoder().decode(FormPayload.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(payload.theme.backgroundColor, "#ABCDEF")
        XCTAssertEqual(payload.theme.textColor, Theme.default.textColor)
    }

    func testMalformedJSONThrowsOnDecode() {
        let data = "{ invalid json".data(using: .utf8)!
        XCTAssertThrowsError(try JSONDecoder().decode(FormPayload.self, from: data))
    }

    func testURIValidationAllowsEmptyOptionalField() {
        let viewModel = FormViewModel()
        guard let portfolioField = viewModel.renderableFields.first(where: { $0.id == "portfolio" }) else {
            return
        }

        viewModel.values[portfolioField.id] = ""
        XCTAssertTrue(viewModel.validate())
    }
}
