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

public struct KeywordHighlightingText: View {

    public struct Customization {
        public var font: UIFont
        public var backgroundColor: UIColor
        public var lineLimit: Int?
        public var compareOptions: String.CompareOptions

        public init(
            font: UIFont = .scaledNamedFont(.regular14),
            lineLimit: Int? = 3,
            backgroundColor: UIColor = .green,
            compareOptions: String.CompareOptions = [.caseInsensitive, .diacriticInsensitive]
        ) {
            self.font = font
            self.lineLimit = lineLimit
            self.backgroundColor = backgroundColor
            self.compareOptions = compareOptions
        }

        fileprivate var keywordAttributes: AttributeContainer {
            AttributeContainer([
                .backgroundColor: backgroundColor,
                .font: font
            ])
        }

        fileprivate var textAttributes: AttributeContainer {
            AttributeContainer([
                .font: font
            ])
        }
    }

    let text: String
    let keyword: String
    var customization = Customization()

    private var attributedText: AttributedString {
        let options = customization.compareOptions
        let keywordAttributes = customization.keywordAttributes
        let textAttributes = customization.textAttributes

        var string = AttributedString(text, attributes: textAttributes)
        string.highlight(keyword: keyword, with: keywordAttributes, options: options)

        // Re-adjust
        if let lineLimit = customization.lineLimit {
            let maxCount = string.numberOfCharacters(in: size, lineLimit: lineLimit)
            let target = text.truncated(around: keyword, maxLength: maxCount, options: options)

            string = AttributedString(target, attributes: textAttributes)
            string.highlight(keyword: keyword, with: keywordAttributes, options: options)
        }

        return string
    }

    @State var size: CGSize = .zero

    public var body: some View {
        Text(attributedText)
            .lineLimit(customization.lineLimit)
            .measuringSizeOnce($size)
    }
}

#Preview {
    KeywordHighlightingText(
        // swiftlint:disable:next line_length
        text: """
Canvas is used by schools, allowing students to submit assignments, answer discussions, access and upload media using Canvas Studio, and retrieve files from their Google Drive after linking Canvas with their Google Account. Like students, Canvas allows teachers to create assignments, discussions, pages, and modules. Teachers can also integrate supported external tools such as Turnitin.
""",
        keyword: "Canvas"
    )
}
