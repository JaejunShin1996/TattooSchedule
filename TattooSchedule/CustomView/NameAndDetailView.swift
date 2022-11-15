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

                TextField("Detail and Comment", text: $detail)
                    .focused($focusedField, equals: .design)
                    .submitLabel(.done)
                    .font(.headline)

                Divider()

                HStack {
                    Text("A$")
                        .font(.title)
                        .bold()

                    TextField("Price", text: $price)
                        .focused($focusedField, equals: .price)
                        .keyboardType(.numberPad)
                        .submitLabel(.done)
                        .font(.title)
                        .bold()
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                Spacer()

                                Button("Done") {
                                    focusedField = .none
                                }
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
