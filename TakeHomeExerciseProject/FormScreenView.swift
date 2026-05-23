//
//  FormScreenView.swift
//  TakeHomeExerciseProject
//
//  Created by Mohd Naqvi on 22/05/26.
//

import SwiftUI

struct FormScreenView: View {
    @StateObject private var viewModel = FormViewModel()
    
    var body: some View {
        ScrollView {
            if viewModel.sortedFields.count > 0 {
                VStack(alignment: .leading, spacing: 5) {
                    Text(viewModel.payload.formTitle)
                        .font(.largeTitle.bold())
                        .foregroundStyle(Color(hex: viewModel.payload.theme.textColor))
                    
                    ForEach(viewModel.sortedFields.filter { $0.type != nil }) { field in
                        if !field.title.isEmpty {
                            Text(field.title)
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(Color(hex: viewModel.payload.theme.textColor))
                                .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
                        }
                        DynamicFieldView(
                            field: field,
                            value: Binding(
                                get: {
                                    viewModel.values[field.id]
                                },
                                set: {
                                    viewModel.values[field.id] = $0
                                }
                            ),
                            error: viewModel.errors[field.id],
                            theme: viewModel.payload.theme
                        )
                    }
                    
                    Button("Save") {
                        viewModel.save()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color(hex: viewModel.payload.theme.buttonColor))
                }
                .padding()
            }else{
                Text("No Form Exist")
            }
        }
        .background(Color(hex: viewModel.payload.theme.backgroundColor))
        .alert("Form Submitted", isPresented: $viewModel.showAlert) {
            Button("OK") { }
        } message: {
            Text(viewModel.output)
        }
    }
}
