//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import SwiftUI

private struct OccurrencesCountInputAlertViewModifier: ViewModifier {

    @Binding var isPresented: Bool
    @StateObject var inputModel: OccurrencesCountInputModel

    init(isPresented: Binding<Bool>, count: Binding<Int>) {
        self._isPresented = isPresented
        self._inputModel = StateObject(
            wrappedValue: OccurrencesCountInputModel(submitted: count)
        )
    }

    func body(content: Content) -> some View {
        content
            .alert(String(localized: "Number of Occurrences", bundle: .core),
                   isPresented: $isPresented) {

                TextField("Occurrences",
                          value: $inputModel.value,
                          formatter: formatter)
                .keyboardType(.asciiCapableNumberPad)

                Button(role: .cancel, action: {
                    isPresented = false
                }, label: {
                    Text("Cancel", bundle: .core)
                })

                Button(action: {
                    inputModel.submit()
                    isPresented = false
                }, label: {
                    Text("Done", bundle: .core)
                })
                .disabled(inputModel.isValid == false)

            } message: {
                Text("How many times would you like to repeat? (Max 400)", bundle: .core)
            }
            .onChange(of: isPresented) { _ in
                inputModel.update()
            }
    }

    private var formatter: Formatter {
        let formatter = NumberFormatter()
        formatter.zeroSymbol = ""
        formatter.allowsFloats = false
        return formatter
    }
}

extension View {

    func occurrencesCountInputDialog(
        isPresented: Binding<Bool>,
        value: Binding<Int>) -> some View {
        modifier(OccurrencesCountInputAlertViewModifier(isPresented: isPresented, count: value))
    }
}
