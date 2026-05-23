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

    init() {
        self.payload = FormLoader.load()

        for field in payload.fields {
            if let defaults = field.defaultValues {
                values[field.id] = defaults
            }
        }
    }

    var sortedFields: [Field] {
        payload.fields.sorted { $0.order < $1.order }
    }
    
    var focusedFields: [Field] {
        payload.fields.sorted { $0.order < $1.order }.filter { $0.type == .text}
    }

    func validate() -> Bool {
        errors.removeAll()

        for field in sortedFields {
            guard field.type != nil else { continue }

            if field.required == true {
                let value = values[field.id]

                switch value {
                case let text as String:
                    if text.trimmingCharacters(in: .whitespaces).isEmpty {
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
            
            if field.subtype == .uri{
                let value = values[field.id]
                switch value {
                case let text as String:
                    if !text.contains("http"){
                        errors[field.id] = "Entered URL is not valid"
                    }
                default: break
                }
            }
        }
        return errors.isEmpty
    }

    func save() {
        if validate() {
            output = values.description
            print(values)
            showAlert = true
        }
    }
}
