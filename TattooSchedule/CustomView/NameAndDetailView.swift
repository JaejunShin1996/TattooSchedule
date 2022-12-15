//
//  NameAndDetailView.swift
//  TattooSchedule
//
//  Created by Jaejun Shin on 15/11/2022.
//

import SwiftUI

struct NameAndDetailView: View {
    @FocusState private var focusedField: Field?
    @Binding var name: String
    @Binding var detail: String
    @Binding var price: String

    var body: some View {
        VStack {
            Text("Detail")
                .font(.headline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack {
                TextField("Name", text: $name)
                    .focused($focusedField, equals: .clientName)
                    .submitLabel(.done)
                    .font(.headline)

                Divider()

                HStack {
                    Text("A$")
                        .font(.headline)

                    TextField("Price", text: $price)
                        .focused($focusedField, equals: .price)
                        .keyboardType(.numberPad)
                        .submitLabel(.done)
                        .font(.headline)
                }

                Divider()

                TextField("Any comment", text: $detail, axis: .vertical)
                    .lineLimit(3, reservesSpace: true)
                    .focused($focusedField, equals: .design)
                    .submitLabel(.next)
                    .font(.headline)
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()

                            Button("Done") {
                                focusedField = .none
                            }
                        }
                    }
            }
            .padding()
            .background(.gray.opacity(0.3))
            .cornerRadius(20)
            .shadow(radius: 20)
        }
        .onSubmit {
            switch focusedField {
            case .clientName:
                focusedField = .design
            case .design:
                focusedField = .price
            default:
                print("Creating account…")
            }
        }
        .scrollDismissesKeyboard(.interactively)
    }
}
