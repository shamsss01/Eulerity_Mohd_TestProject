//
//  FormLoader.swift
//  TakeHomeExerciseProject
//
//  Created by Mohd Naqvi on 22/05/26.
//

import Foundation

enum FormLoadResult {
    case success(FormPayload)
    case failure(String)
}

final class FormLoader {
    static func load() -> FormPayload {
        switch loadResult() {
        case .success(let payload):
            return payload
        case .failure(let message):
            print("FormLoader: \(message)")
            return .empty
        }
    }

    static func loadResult() -> FormLoadResult {
        guard let url = Bundle.main.url(forResource: "form", withExtension: "json") else {
            return .failure("form.json not found in bundle")
        }

        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            return .failure("Could not read form.json: \(error.localizedDescription)")
        }

        guard !data.isEmpty else {
            return .failure("form.json is empty")
        }

        do {
            let payload = try JSONDecoder().decode(FormPayload.self, from: data)
            return .success(payload)
        } catch {
            return .failure("Could not parse form.json: \(error.localizedDescription)")
        }
    }
}
