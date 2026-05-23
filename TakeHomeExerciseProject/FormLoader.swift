//
//  FormLoader.swift
//  TakeHomeExerciseProject
//
//  Created by Mohd Naqvi on 22/05/26.
//

import Foundation

final class FormLoader {
    static func load() -> FormPayload {
        guard let url = Bundle.main.url(forResource: "form", withExtension: "json") else {
            fatalError("Missing form.json")
        }

        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(FormPayload.self, from: data)
        } catch {
            print("Failed to load JSON: \(error)")
            return FormPayload(theme: Theme(backgroundColor: "FFFFFF", textColor: "", clickableTextColor: "", borderColor: "", errorColor: "", buttonColor: ""), formTitle: "", fields: [])
        }
    }
}
