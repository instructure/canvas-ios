//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

import Core
import Foundation
import SwiftUI

struct GradeInputTextFieldCell: View {

    private let title: String
    private let subtitle: String?
    private let placeholder: String
    private let suffix: String

    @Binding private var externalText: String
    @State private var internalText: String

    @FocusState private var isFocused: Bool

    init(
        title: String,
        subtitle: String? = nil,
        placeholder: String,
        suffix: String,
        text: Binding<String>
    ) {
        self.title = title
        self.subtitle = subtitle
        self.placeholder = placeholder
        self.suffix = suffix
        self._externalText = text
        self.internalText = text.wrappedValue
    }

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Text(title)
                .textStyle(.cellLabel)
                .paddingStyle(.trailing, .standard)
                .accessibility(hidden: true)

            textField
                .frame(maxWidth: .infinity, alignment: .trailing)
                .focused($isFocused)
                .onChange(of: externalText) {
                    internalText = externalText
                }
                .onChange(of: isFocused) {
                    // on end editing: send current text
                    if !isFocused {
                        externalText = internalText
                    }
                }
        }
        .paddingStyle(set: .standardCell)
        .contentShape(Rectangle())
        .onTapGesture {
            isFocused = true
        }
    }

    private var textField: some View {
        TextField(
            "" as String, // to avoid localizing ""
            text: $internalText,
            prompt: Text(placeholder)
                .foregroundStyle(.textPlaceholder)
        )
        .font(externalText.isNotEmpty ? .semibold16 : .regular16, lineHeight: .fit)
        .foregroundStyle(.tint)
        .multilineTextAlignment(.trailing)
        .keyboardType(.decimalPad)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button(String(localized: "Done", bundle: .teacher)) {
                    isFocused = false
                }
                .font(.regular16, lineHeight: .fit)
            }
        }
        .onChange(of: isFocused) {
            // on begin editing: select text
            if isFocused && externalText.isNotEmpty {
                DispatchQueue.main.async {
                    UIApplication.shared.sendAction(#selector(UIResponder.selectAll(_:)), to: nil, from: nil, for: nil)
                }
            }
        }
    }
}
