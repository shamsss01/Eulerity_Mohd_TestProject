//
//  DynamicFieldView.swift
//  TakeHomeExerciseProject
//
//  Created by Mohd Naqvi on 22/05/26.
//

import SwiftUI

struct DynamicFieldView: View {
    let field: Field
    @Binding var value: Any?
    let error: String?
    let theme: Theme
    var focusedFieldID: FocusState<String?>.Binding
    let isLastKeyboardField: Bool
    let onKeyboardNext: () -> Void

    @State private var text: String = ""
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            switch field.type {
            case .text:
                textFieldView

            case .dropdown:
                dropdownView

            case .toggle:
                Toggle(
                    field.label.isEmpty ? " " : field.label,
                    isOn: Binding(
                        get: { value as? Bool ?? false },
                        set: { value = $0 }
                    )
                )
                .tint(theme.button)

            case .checkbox:
                checkboxView

            case .unknown, .none:
                EmptyView()
            }

            if let error, !error.isEmpty {
                Text(error)
                    .foregroundStyle(theme.error)
                    .font(.caption)
            }
        }
        .foregroundStyle(theme.text)
    }

    // MARK: - Text fields

    @ViewBuilder
    private var textFieldView: some View {
        VStack(alignment: .leading) {
            switch field.subtype {
            case .secure:
                applyKeyboardNavigation(to:
                    SecureField(field.placeholder ?? "", text: $text)
                )

            case .multiline:
                applyKeyboardNavigation(to: multilineEditor)

            default:
                applyKeyboardNavigation(to:
                    TextField(field.placeholder ?? "", text: $text)
                        .keyboardType(keyboardType)
                )
            }

            if let max = field.maxLength {
                characterCounter(max: max)
            }
        }
        .onAppear {
            text = value as? String ?? ""
        }
        .onChange(of: text) { newValue in
            let limited = limit(newValue, maxLength: field.maxLength)
            if limited != text {
                text = limited
            }
            value = text
        }
    }

    private var multilineEditor: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty, let placeholder = field.placeholder, !placeholder.isEmpty {
                Text(placeholder)
                    .foregroundStyle(theme.text.opacity(0.45))
                    .padding(.top, 8)
                    .padding(.leading, 5)
                    .allowsHitTesting(false)
            }

            TextEditor(text: $text)
                .frame(minHeight: 100)
                .scrollContentBackground(.hidden)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(theme.border, lineWidth: 1)
                )
                .keyboardType(.default)
        }
    }

    @ViewBuilder
    private func applyKeyboardNavigation<Content: View>(to content: Content) -> some View {
        content
            .focused(focusedFieldID, equals: field.id)
            .submitLabel(isLastKeyboardField ? .done : .next)
            .onSubmit(onKeyboardNext)
            .foregroundStyle(theme.text)
            .background(.clear)
            .textFieldStyle(.plain)
            .padding(.horizontal, 8)
            .frame(minHeight: field.subtype == .multiline ? nil : 40)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(theme.border, lineWidth: field.subtype == .multiline ? 0 : 1)
            )
    }

    @ViewBuilder
    private func characterCounter(max: Int) -> some View {
        let count = (value as? String ?? "").count
        HStack {
            Spacer()
            Text("\(count)/\(max)")
                .font(.caption)
                .foregroundStyle(count <= max ? theme.text.opacity(0.6) : theme.error)
        }
    }

    // MARK: - Checkbox

    private var checkboxView: some View {
        HStack(alignment: .center) {
            Image(systemName: (value as? Bool ?? false) ? "checkmark.square.fill" : "square")
                .frame(width: 25, height: 25)
                .onTapGesture {
                    value = !(value as? Bool ?? false)
                }

            if let link = field.link,
               !link.isEmpty,
               let url = URL(string: link) {
                Link(destination: url) {
                    Text(field.label)
                        .underline()
                        .foregroundStyle(theme.clickableText)
                }
            } else {
                Text(field.label)
                    .foregroundStyle(theme.text)
            }
        }
    }

    // MARK: - Dropdown

    private var dropdownView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                focusedFieldID.wrappedValue = nil
                hideKeyboard()
                withAnimation {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Text(dropdownSummary)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                }
                .foregroundStyle(theme.text)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            if isExpanded {
                VStack(spacing: 0) {
                    Divider()
                    ForEach(field.options ?? []) { option in
                        Button {
                            selectOption(option.id)
                        } label: {
                            HStack {
                                Text(option.label)
                                    .foregroundStyle(theme.text)
                                Spacer()
                                if isSelected(option.id) {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(theme.text)
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(minHeight: 40)
                        Divider()
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(theme.border, lineWidth: 1)
        )
    }

    // MARK: - Helpers

    private var keyboardType: UIKeyboardType {
        switch field.subtype {
        case .number:
            return .numberPad
        case .uri:
            return .URL
        default:
            return .default
        }
    }

    private var dropdownSummary: String {
        if field.allowMultiple == true {
            let labels = selectedOptionLabels
            return labels.isEmpty ? "Select options" : labels.joined(separator: ", ")
        }

        guard
            let selected = value as? String,
            let option = field.options?.first(where: { $0.id == selected })
        else {
            return "Select option"
        }
        return option.label
    }

    private var selectedOptionLabels: [String] {
        let current = value as? [String] ?? []
        return field.options?
            .filter { current.contains($0.id) }
            .map(\.label) ?? []
    }

    private func isSelected(_ id: String) -> Bool {
        if field.allowMultiple == true {
            return (value as? [String] ?? []).contains(id)
        }
        return (value as? String) == id
    }

    private func selectOption(_ id: String) {
        if field.allowMultiple == true {
            var current = value as? [String] ?? []
            if current.contains(id) {
                current.removeAll { $0 == id }
            } else {
                current.append(id)
            }
            value = current
        } else {
            value = id
            withAnimation {
                isExpanded = false
            }
        }
    }

    private func limit(_ string: String, maxLength: Int?) -> String {
        guard let maxLength, string.count > maxLength else { return string }
        return String(string.prefix(maxLength))
    }
}
