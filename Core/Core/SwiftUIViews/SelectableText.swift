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

public struct SelectableText: View {
    // MARK: - Properties
    @State private var height: CGFloat = 0.0
    private let text: AttributedString
    private let font: UIFont.Name
    private let textColor: Color

    // MARK: - Init
    public init(
        text: AttributedString,
        font: UIFont.Name,
        textColor: Color
    ) {
        self.text = text
        self.font = font
        self.textColor = textColor
    }

    public var body: some View {
        Text(text)
            .font(Font(UIFont.scaledNamedFont(font)))
            .foregroundStyle(Color.clear)
            .readingFrame(coordinateSpace: .local) { frame in
                height = frame.height + 5 // Adding 5 to make it more fit.
            }
            .overlay(alignment: .topLeading) {
                SelectableTextViewWrapper(
                    textType: .attributedText(
                        value: text
                    ),
                    font: font,
                    textColor: textColor
                )
                .frame(height: height)
            }
    }
}
