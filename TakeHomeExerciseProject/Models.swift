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

    init(theme: Theme, formTitle: String, fields: [Field]) {
        self.theme = theme
        self.formTitle = formTitle
        self.fields = fields
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        theme = (try? container.decode(Theme.self, forKey: .theme)) ?? .default
        formTitle = (try? container.decode(String.self, forKey: .formTitle)) ?? ""
        fields = (try? container.decode([Field].self, forKey: .fields)) ?? []
    }

    static let empty = FormPayload(theme: .default, formTitle: "", fields: [])
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

    init(
        backgroundColor: String,
        textColor: String,
        clickableTextColor: String,
        borderColor: String,
        errorColor: String,
        buttonColor: String
    ) {
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.clickableTextColor = clickableTextColor
        self.borderColor = borderColor
        self.errorColor = errorColor
        self.buttonColor = buttonColor
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        backgroundColor = container.decodeString(forKey: .backgroundColor, default: Self.default.backgroundColor)
        textColor = container.decodeString(forKey: .textColor, default: Self.default.textColor)
        clickableTextColor = container.decodeString(forKey: .clickableTextColor, default: Self.default.clickableTextColor)
        borderColor = container.decodeString(forKey: .borderColor, default: Self.default.borderColor)
        errorColor = container.decodeString(forKey: .errorColor, default: Self.default.errorColor)
        buttonColor = container.decodeString(forKey: .buttonColor, default: Self.default.buttonColor)
    }

    static let `default` = Theme(
        backgroundColor: "FFFFFF",
        textColor: "111827",
        clickableTextColor: "000000",
        borderColor: "D1D5DB",
        errorColor: "B91C1C",
        buttonColor: "2563EB"
    )
}

struct Option: Codable, Identifiable {
    let id: String
    let label: String

    init(id: String, label: String) {
        self.id = id
        self.label = label
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = (try? container.decode(String.self, forKey: .id)) ?? UUID().uuidString
        label = (try? container.decode(String.self, forKey: .label)) ?? ""
    }

    enum CodingKeys: String, CodingKey {
        case id
        case label
    }
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
        let value = (try? container.decode(String.self)) ?? ""

        switch value {
        case "TEXT":
            self = .text
        case "DROPDOWN":
            self = .dropdown
        case "TOGGLE":
            self = .toggle
        case "CHECKBOX":
            self = .checkbox
        case "":
            self = .unknown("INVALID")
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

    var isSupported: Bool {
        switch self {
        case .text, .dropdown, .toggle, .checkbox:
            return true
        case .unknown:
            return false
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

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = (try? container.decode(String.self, forKey: .id)) ?? UUID().uuidString
        order = (try? container.decode(Int.self, forKey: .order)) ?? 0
        type = try? container.decode(FieldType.self, forKey: .type)
        subtype = try? container.decode(TextSubtype.self, forKey: .subtype)
        title = (try? container.decode(String.self, forKey: .title)) ?? ""
        label = (try? container.decode(String.self, forKey: .label)) ?? ""
        placeholder = try? container.decode(String.self, forKey: .placeholder)
        maxLength = try? container.decode(Int.self, forKey: .maxLength)
        errorMessage = try? container.decode(String.self, forKey: .errorMessage)
        required = try? container.decode(Bool.self, forKey: .required)
        allowMultiple = try? container.decode(Bool.self, forKey: .allowMultiple)
        defaultValues = try? container.decode([String].self, forKey: .defaultValues)
        options = try? container.decode([Option].self, forKey: .options)
        metadata = try? container.decode([String: String].self, forKey: .metadata)
        clickableTextColor = try? container.decode(String.self, forKey: .clickableTextColor)
        link = try? container.decode(String.self, forKey: .link)
    }

    var acceptsKeyboardFocus: Bool {
        type == .text
    }
}

private extension KeyedDecodingContainer {
    func decodeString(forKey key: Key, default defaultValue: String) -> String {
        (try? decode(String.self, forKey: key)) ?? defaultValue
    }
}
