//
//  Models.swift
//  TakeHomeExerciseProject
//
//  Created by Mohd Naqvi on 22/05/26.
//

import Foundation

struct FormPayload: Codable {
    let theme: Theme
    let formTitle: String
    let fields: [Field]

    enum CodingKeys: String, CodingKey {
        case theme
        case formTitle = "form_title"
        case fields
    }
}

struct Theme: Codable {
    let backgroundColor: String
    let textColor: String
    let clickableTextColor: String
    let borderColor: String
    let errorColor: String
    let buttonColor: String

    enum CodingKeys: String, CodingKey {
        case backgroundColor = "background_color"
        case textColor = "text_color"
        case clickableTextColor = "clickable_text_color"
        case borderColor = "border_color"
        case errorColor = "error_color"
        case buttonColor = "button_color"
    }
}

struct Option: Codable, Identifiable {
    let id: String
    let label: String
}

enum TextSubtype: String, Codable {
    case plain = "PLAIN"
    case multiline = "MULTILINE"
    case number = "NUMBER"
    case uri = "URI"
    case secure = "SECURE"
}

enum FieldType: Codable, Equatable {
    case text
    case dropdown
    case toggle
    case checkbox
    case unknown(String)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)

        switch value {
        case "TEXT":
            self = .text
        case "DROPDOWN":
            self = .dropdown
        case "TOGGLE":
            self = .toggle
        case "CHECKBOX":
            self = .checkbox
        default:
            self = .unknown(value)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .text:
            try container.encode("TEXT")
        case .dropdown:
            try container.encode("DROPDOWN")
        case .toggle:
            try container.encode("TOGGLE")
        case .checkbox:
            try container.encode("CHECKBOX")
        case .unknown(let value):
            try container.encode(value)
        }
    }
}

struct Field: Codable, Identifiable {
    let id: String
    let order: Int
    let type: FieldType?
    let subtype: TextSubtype?
    let title: String
    let label: String
    let placeholder: String?
    let maxLength: Int?
    let errorMessage: String?
    let required: Bool?
    let allowMultiple: Bool?
    let defaultValues: [String]?
    let options: [Option]?
    let metadata: [String: String]?
    let clickableTextColor: String?
    let link: String?

    enum CodingKeys: String, CodingKey {
        case id
        case order
        case type
        case subtype
        case title
        case label
        case placeholder
        case maxLength = "max_length"
        case errorMessage = "error_message"
        case required
        case allowMultiple = "allow_multiple"
        case defaultValues = "default_values"
        case options
        case metadata
        case clickableTextColor = "clickable_text_color"
        case link = "link"
    }
}
