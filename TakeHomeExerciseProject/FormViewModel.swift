//
//  FormViewModel.swift
//  TakeHomeExerciseProject
//
//  Created by Mohd Naqvi on 22/05/26.
//

import Foundation
internal import Combine

final class FormViewModel: ObservableObject {
    @Published var payload: FormPayload
    @Published var values: [String: Any] = [:]
    @Published var errors: [String: String] = [:]
    @Published var showAlert = false
    @Published var output = ""
    @Published var loadErrorMessage: String?

    init() {
        switch FormLoader.loadResult() {
        case .success(let payload):
            self.payload = payload
        case .failure(let message):
            self.payload = .empty
            self.loadErrorMessage = message
        }

        seedDefaultValues()
    }

    var sortedFields: [Field] {
        payload.fields.sorted { $0.order < $1.order }
    }

    var renderableFields: [Field] {
        sortedFields.filter { field in
            guard let type = field.type else { return false }
            return type.isSupported
        }
    }

    var keyboardNavigableFieldIDs: [String] {
        renderableFields
            .filter(\.acceptsKeyboardFocus)
            .map(\.id)
    }

    var hasFormContent: Bool {
        !renderableFields.isEmpty
    }

    private func seedDefaultValues() {
        for field in payload.fields {
            guard let defaults = field.defaultValues, !defaults.isEmpty else { continue }

            switch field.type {
            case .dropdown where field.allowMultiple == true:
                values[field.id] = defaults
            case .dropdown:
                values[field.id] = defaults.first
            default:
                if defaults.count == 1, field.type != .dropdown {
                    values[field.id] = defaults[0]
                } else {
                    values[field.id] = defaults
                }
            }
        }

        for field in renderableFields where values[field.id] == nil {
            switch field.type {
            case .toggle, .checkbox:
                values[field.id] = false
            case .dropdown where field.allowMultiple == true:
                values[field.id] = [String]()
            default:
                break
            }
        }
    }

    func validate() -> Bool {
        errors.removeAll()

        for field in renderableFields {
            if field.required == true {
                let value = values[field.id]

                switch value {
                case let text as String:
                    if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        errors[field.id] = field.errorMessage ?? "Required"
                    }

                case let array as [String]:
                    if array.isEmpty {
                        errors[field.id] = field.errorMessage ?? "Required"
                    }

                case let bool as Bool:
                    if !bool {
                        errors[field.id] = field.errorMessage ?? "Required"
                    }

                default:
                    errors[field.id] = field.errorMessage ?? "Required"
                }
            }

            if field.subtype == .uri {
                if let text = values[field.id] as? String,
                   !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                   !isValidURI(text) {
                    errors[field.id] = "Entered URL is not valid"
                }
            }
        }
        return errors.isEmpty
    }

    func save() {
        if validate() {
            output = formattedOutput()
            showAlert = true
        }
    }

    private func isValidURI(_ text: String) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let url = URL(string: trimmed), let scheme = url.scheme?.lowercased() else {
            return false
        }
        return scheme == "http" || scheme == "https"
    }

    private func formattedOutput() -> String {
        renderableFields.compactMap { field -> String? in
            guard let value = values[field.id] else { return nil }
            return "\(field.id): \(describe(value))"
        }
        .joined(separator: "\n")
    }

    private func describe(_ value: Any) -> String {
        switch value {
        case let text as String:
            return text
        case let array as [String]:
            return array.joined(separator: ", ")
        case let bool as Bool:
            return bool ? "true" : "false"
        default:
            return String(describing: value)
        }
    }
}
