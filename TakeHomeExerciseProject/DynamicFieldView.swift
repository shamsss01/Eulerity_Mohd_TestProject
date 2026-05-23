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
    @State private var text: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            switch field.type {
            case .text:
                textFieldView
                
            case .dropdown:
                dropdownView
                
            case .toggle:
                Toggle(
                    field.label,
                    isOn: Binding(
                        get: { value as? Bool ?? false },
                        set: { value = $0 }
                    )
                )
                
            case .checkbox:
                HStack(alignment: .center) {
                    Image(systemName: (value as? Bool ?? false) == true
                          ? "checkmark.square"
                          : "square")
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
                                .foregroundColor(Color(hex: theme.clickableTextColor))
                        }
                    } else {
                        Text(field.label)
                            .foregroundColor(Color(hex: theme.textColor))
                    }
                }
                
            case .unknown:
                EmptyView()
                
            case .none:
                EmptyView()
                
            }
            
            if let error {
                Text(error)
                    .foregroundColor(Color(hex: theme.errorColor))
                    .font(.caption)
            }
        }
        .foregroundStyle(Color(hex: theme.textColor))
    }
    
    @ViewBuilder
    var textFieldView: some View {
        VStack(alignment: .leading) {
            switch field.subtype {
            case .secure:
                SecureField(
                    field.placeholder ?? "",
                    text: $text
                )
                .onAppear {
                    text = value as? String ?? ""
                }
                .onChange(of: text) { newValue in
                    if let max = field.maxLength,
                       newValue.count > max {
                        text = String(newValue.prefix(max))
                    }
                    value = text
                }
                .foregroundStyle(Color(hex: theme.textColor))
                .frame(height: 40)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(
                            Color(hex: theme.borderColor),
                            lineWidth: 1
                        )
                )
            case .multiline:
                ZStack(alignment: .topLeading) {
                    if text.isEmpty {
                        Text(field.placeholder ?? "")
                            .foregroundColor(.gray)
                            .padding(.top, 6)
                            .padding(.leading, 5)
                            .opacity(0.6)
                    }
                    TextEditor(
                        text: $text
                    )
                    .onAppear {
                        text = value as? String ?? ""
                    }
                    .onChange(of: text) { newValue in
                        if let max = field.maxLength,
                           newValue.count > max {
                            
                            text = String(newValue.prefix(max))
                        }
                        value = text
                    }
                    .foregroundStyle(Color(hex: theme.textColor))
                    .frame(height: 100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(
                                Color(hex: theme.borderColor),
                                lineWidth: 1
                            )
                    )
                    .scrollContentBackground(.hidden)
                }
            default:
                TextField(
                    field.placeholder ?? "",
                    text: $text
                )
                .onAppear {
                    text = value as? String ?? ""
                }
                .onChange(of: text) { newValue in
                    if let max = field.maxLength,
                       newValue.count > max {
                        
                        text = String(newValue.prefix(max))
                    }
                    value = text
                }
                .keyboardType(keyboardType)
                .foregroundStyle(Color(hex: theme.textColor))
                .frame(height: 40)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(
                            Color(hex: theme.borderColor),
                            lineWidth: 1
                        )
                )
            }
            if let max = field.maxLength {
                HStack {
                    Spacer()
                    Text("\((value as? String ?? "").count)/\(max)")
                        .font(.caption)
                        .foregroundStyle(
                            ((value as? String ?? "").count <= max)
                            ? Color(hex: theme.textColor)
                            : Color(hex: theme.errorColor)
                        )
                        .opacity(0.6)
                }
            }
        }
    }
    
    @State private var isExpanded = false
    var dropdownView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                withAnimation {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    if field.allowMultiple == true {
                        Text(selectedMultiTitles.isEmpty
                             ? "Select options"
                             : selectedMultiTitles)
                    } else {
                        Text(selectedSingleTitle.isEmpty
                             ? "Select option"
                             : selectedSingleTitle)
                    }
                    Spacer()
                    Image(systemName: isExpanded
                          ? "chevron.up"
                          : "chevron.down")
                    
                }
                .foregroundStyle(Color(hex: theme.textColor))
                .padding()
                .frame(maxWidth: .infinity)
            }
            if isExpanded {
                VStack(spacing: 0) {
                    Divider()
                    ForEach(field.options ?? []) { option in
                        Button {
                            if field.allowMultiple == true {
                                toggleSelection(option.id)
                            } else {
                                value = option.id
                                withAnimation {
                                    isExpanded = false
                                }
                            }
                        } label: {
                            HStack {
                                Text(option.label)
                                    .foregroundStyle(Color(hex: theme.textColor))
                                Spacer()
                                if isSelected(option.id) {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(Color(hex: theme.textColor))
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                        }
                        .frame(height: 40)
                        Divider()
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    Color(hex: theme.borderColor),
                    lineWidth: 1
                )
        )
    }
    
    var keyboardType: UIKeyboardType {
        switch field.subtype {
        case .number:
            return .numberPad
        case .uri:
            return .URL
        default:
            return .default
        }
    }
    
    func isSelected(_ id: String) -> Bool {
        let current = value as? [String] ?? []
        return current.contains(id)
    }
    
    func toggleSelection(_ id: String) {
        var current = value as? [String] ?? []
        if current.contains(id) {
            current.removeAll { $0 == id }
        } else {
            current.append(id)
        }
        value = current
    }
    
    var selectedMultiTitles: String {
        let current = value as? [String] ?? []
        let labels = field.options?
            .filter { current.contains($0.id) }
            .map(\.label) ?? []
        return labels.isEmpty
        ? "Select options"
        : (isExpanded ? "Select options" : labels.joined(separator: ", "))
    }
    
    var selectedSingleTitle: String {
        guard
            let selected = value as? String,
            let option = field.options?.first(where: { $0.id == selected })
        else {
            return "Select option"
        }
        return option.label
    }
}
