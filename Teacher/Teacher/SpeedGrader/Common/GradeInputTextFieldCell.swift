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
    private let customAccessibilityLabel: String?
    private let placeholder: String
    private let suffix: String?
    private let customAccessibilitySuffix: String?

    @Binding private var externalText: String
    @State private var internalText: String

    @FocusState private var isFocused: Bool
    private let isSaving: CurrentValueSubject<Bool, Never>

    init(
        title: String,
        subtitle: String?,
        customAccessibilityLabel: String? = nil,
        placeholder: String,
        suffix: String?,
        customAccessibilitySuffix: String? = nil,
        text: Binding<String>,
        isSaving: CurrentValueSubject<Bool, Never>
    ) {
        self.title = title
        self.subtitle = subtitle
        self.customAccessibilityLabel = customAccessibilityLabel
        self.placeholder = placeholder
        self.suffix = suffix
        self.customAccessibilitySuffix = customAccessibilitySuffix
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
                    .accessibility(hidden: true)
            }

            textFieldViews
                .swapWithSpinner(onSaving: isSaving, alignment: .trailing)
                .accessibilityLabel(isSaving.value ? accessibilityLabel : nil)
        }
        .paddingStyle(set: .standardCell)
        .contentShape(Rectangle())
        .onTapGesture {
            isFocused = true
        }
        .onChange(of: externalText) {
            // This onChange didn't trigger sometimes when it was called on `numericTextField`.
            internalText = externalText
        }
    }

    @ViewBuilder
    private var textFieldViews: some View {
        HStack(alignment: .center, spacing: 8) {
            numericTextField
                .frame(maxWidth: .infinity, alignment: .trailing)
                .focused($isFocused)
                .onChange(of: isFocused) {
                    // on end editing: send current text
                    if !isFocused {
                        externalText = internalText
                    }
                }
                .accessibilityLabel(accessibilityLabel)
                .accessibilityValue(accessibilityValue)

            if let suffix {
                Text(suffix)
                    .font(.regular16, lineHeight: .fit)
                    .foregroundStyle(.textDark)
                    .accessibility(hidden: true)
            }
        }
    }

    private var numericTextField: some View {
        InstUI.NumericTextField(
            text: $internalText,
            placeholder: placeholder,
            style: .init(
                textColor: .tintColor,
                textFont: .semibold16,
                placeholderFont: .regular16,
                textAlignment: .right
            )
        )
    }

    private var accessibilityLabel: String {
        customAccessibilityLabel
            ?? [title, subtitle].accessibilityJoined()
    }

    private var accessibilityValue: String {
        [
            "", // adding pause before `value`
            internalText.nilIfEmpty ?? placeholder,
            customAccessibilitySuffix ?? suffix
        ].accessibilityJoined()
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
        pointsPossibleText: String,
        pointsPossibleAccessibilityText: String,
        isExcused: Bool,
        text: Binding<String>,
        isSaving: CurrentValueSubject<Bool, Never>
    ) {
        let subtitle: String? = switch inputType {
        case .points: nil
        case .percentage: "(\(pointsPossibleText))"
        }
        let a11ySubtitle: String? = switch inputType {
        case .points: nil
        case .percentage: String(localized: "\(pointsPossibleAccessibilityText) maximum", bundle: .teacher, comment: "Example: '10 points maximum'")
        }

        let placeholder = switch inputType {
        case .points: String(localized: "Write score here", bundle: .teacher)
        case .percentage: String(localized: "Write percentage here", bundle: .teacher)
        }

        let suffix: String?
        let a11ySuffix: String?
        if isExcused {
            suffix = nil
            a11ySuffix = nil
        } else {
            suffix = switch inputType {
            case .points: "/ \(pointsPossibleText)"
            case .percentage: "%"
            }
            a11ySuffix = switch inputType {
            case .points: String(localized: "out of \(pointsPossibleAccessibilityText)", bundle: .teacher, comment: "Example: 'out of 10 points'")
            case .percentage: "%"
            }
        }

        self.init(
            title: title,
            subtitle: subtitle,
            customAccessibilityLabel: [title, a11ySubtitle].accessibilityJoined(),
            placeholder: placeholder,
            suffix: suffix,
            customAccessibilitySuffix: a11ySuffix,
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
            pointsPossibleText: "42 pts",
            pointsPossibleAccessibilityText: "42 points",
            isExcused: false,
            text: $textNumber,
            isSaving: .init(false)
        )
        GradeInputTextFieldCell(
            title: "Grade",
            inputType: .percentage,
            pointsPossibleText: "42 pts",
            pointsPossibleAccessibilityText: "42 points",
            isExcused: false,
            text: $textNumber,
            isSaving: .init(false)
        )
        GradeInputTextFieldCell(
            title: "Grade",
            inputType: .percentage,
            pointsPossibleText: "42 pts",
            pointsPossibleAccessibilityText: "42 points",
            isExcused: false,
            text: $textNumber,
            isSaving: .init(true)
        )
    }
}

#endif
