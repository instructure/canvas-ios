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

import Combine
import Core
import Foundation
import SwiftUI

struct GradeInputTextFieldCell: View {

    private let title: String
    private let subtitle: String?
    private let placeholder: String
    private let suffix: String?

    @Binding private var externalText: String
    @State private var internalText: String

    @FocusState private var isFocused: Bool
    private let isSaving: CurrentValueSubject<Bool, Never>

    init(
        title: String,
        subtitle: String?,
        placeholder: String,
        suffix: String?,
        text: Binding<String>,
        isSaving: CurrentValueSubject<Bool, Never>
    ) {
        self.title = title
        self.subtitle = subtitle
        self.placeholder = placeholder
        self.suffix = suffix
        self._externalText = text
        self.internalText = text.wrappedValue
        self.isSaving = isSaving
    }

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Text(title)
                .textStyle(.cellLabel)
                .accessibility(hidden: true)

            if let subtitle {
                Text(subtitle)
                    .font(.regular16, lineHeight: .fit)
                    .foregroundStyle(.textDark)
            }

            textFieldViews
                .swapWithSpinner(onLoading: isSaving, alignment: .trailing)
        }
        .paddingStyle(set: .standardCell)
        .contentShape(Rectangle())
        .onTapGesture {
            isFocused = true
        }
    }

    @ViewBuilder
    private var textFieldViews: some View {
        HStack(alignment: .center, spacing: 8) {
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

            if let suffix {
                Text(suffix)
                    .font(.regular16, lineHeight: .fit)
                    .foregroundStyle(.textDark)
            }
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

extension GradeInputTextFieldCell {

    enum InputType {
        case points
        case percentage
    }

    init(
        title: String,
        inputType: InputType,
        pointsPossible: String,
        isExcused: Bool,
        text: Binding<String>,
        isSaving: CurrentValueSubject<Bool, Never>
    ) {
        let subtitle: String? = switch inputType {
        case .points: nil
        case .percentage: "(\(pointsPossible))"
        }

        let placeholder = switch inputType {
        case .points: String(localized: "Write score here", bundle: .teacher)
        case .percentage: String(localized: "Write percentage here", bundle: .teacher)
        }

        let suffix: String?
        if isExcused {
            suffix = nil
        } else {
            suffix = switch inputType {
            case .points: "/ \(pointsPossible)"
            case .percentage: "%"
            }
        }

        self.init(
            title: title,
            subtitle: subtitle,
            placeholder: placeholder,
            suffix: suffix,
            text: text,
            isSaving: isSaving
        )
    }
}

#if DEBUG

#Preview {
    @Previewable @State var textEmpty: String = ""
    @Previewable @State var textLong: String = .loremIpsumMedium
    @Previewable @State var textNumber: String = "24"

    VStack {
        InstUI.Divider()
        GradeInputTextFieldCell(
            title: "Label",
            subtitle: "(stuff)",
            placeholder: "Add text here",
            suffix: "The End",
            text: $textEmpty,
            isSaving: .init(false)
        )
        GradeInputTextFieldCell(
            title: "Label",
            subtitle: "Some subtitle",
            placeholder: "Add text here",
            suffix: "The End",
            text: $textLong,
            isSaving: .init(false)
        )
        GradeInputTextFieldCell(
            title: "Score",
            inputType: .points,
            pointsPossible: "42 pts",
            isExcused: false,
            text: $textNumber,
            isSaving: .init(false)
        )
        GradeInputTextFieldCell(
            title: "Grade",
            inputType: .percentage,
            pointsPossible: "42 pts",
            isExcused: false,
            text: $textNumber,
            isSaving: .init(false)
        )
        GradeInputTextFieldCell(
            title: "Grade",
            inputType: .percentage,
            pointsPossible: "42 pts",
            isExcused: false,
            text: $textNumber,
            isSaving: .init(true)
        )
    }
}

#endif
