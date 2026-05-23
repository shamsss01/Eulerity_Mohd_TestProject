//
//  FormScreenView.swift
//  TakeHomeExerciseProject
//
//  Created by Mohd Naqvi on 22/05/26.
//

import SwiftUI

struct FormScreenView: View {
    @StateObject private var viewModel = FormViewModel()
    @FocusState private var focusedFieldID: String?

    private var theme: Theme {
        viewModel.payload.theme
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 5) {
                if let loadErrorMessage = viewModel.loadErrorMessage {
                    Text(loadErrorMessage)
                        .font(.caption)
                        .foregroundStyle(theme.error)
                        .padding(.bottom, 4)
                }

                if viewModel.hasFormContent {
                    formContent
                } else {
                    Text("No form available")
                        .foregroundStyle(theme.text)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(theme.background)
        .dismissKeyboardOnTap()
        .alert("Form Submitted", isPresented: $viewModel.showAlert) {
            Button("OK") { }
        } message: {
            Text(viewModel.output)
        }
    }

    @ViewBuilder
    private var formContent: some View {
        if !viewModel.payload.formTitle.isEmpty {
            Text(viewModel.payload.formTitle)
                .font(.largeTitle.bold())
                .foregroundStyle(theme.text)
        }

        ForEach(viewModel.renderableFields) { field in
            fieldSection(for: field)
        }

        Button("Save") {
            focusedFieldID = nil
            hideKeyboard()
            viewModel.save()
        }
        .buttonStyle(.borderedProminent)
        .tint(theme.button)
        .padding(.top, 8)
    }

    @ViewBuilder
    private func fieldSection(for field: Field) -> some View {
        if !field.title.isEmpty {
            Text(field.title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(theme.text)
                .padding(.top, 10)
        }

        DynamicFieldView(
            field: field,
            value: Binding(
                get: { viewModel.values[field.id] },
                set: { viewModel.values[field.id] = $0 }
            ),
            error: viewModel.errors[field.id],
            theme: theme,
            focusedFieldID: $focusedFieldID,
            isLastKeyboardField: isLastKeyboardField(field.id),
            onKeyboardNext: { advanceFocus(from: field.id) }
        )
    }

    private var keyboardToolbarTitle: String {
        guard let focusedFieldID else { return "Done" }
        return isLastKeyboardField(focusedFieldID) ? "Done" : "Next"
    }

    private func isLastKeyboardField(_ fieldID: String) -> Bool {
        viewModel.keyboardNavigableFieldIDs.last == fieldID
    }

    private func advanceFocus(from fieldID: String) {
        let ids = viewModel.keyboardNavigableFieldIDs
        guard let index = ids.firstIndex(of: fieldID) else {
            dismissKeyboard()
            return
        }

        let nextIndex = index + 1
        if nextIndex < ids.count {
            focusedFieldID = ids[nextIndex]
        } else {
            dismissKeyboard()
        }
    }

    private func handleKeyboardToolbarAction() {
        guard let focusedFieldID else {
            dismissKeyboard()
            return
        }

        if isLastKeyboardField(focusedFieldID) {
            dismissKeyboard()
        } else {
            advanceFocus(from: focusedFieldID)
        }
    }

    private func dismissKeyboard() {
        focusedFieldID = nil
        hideKeyboard()
    }
}
