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

import SwiftUI

struct HighlightedText: View {
    typealias OnTap = () -> Void

    // MARK: - Dependencies

    private let text: String
    private let types: [CourseNoteLabel]

    // MARK: - Computed Properties

    private var firstType: CourseNoteLabel {
        types.first ?? .important
    }

    // MARK: - Init

    init(_ text: String, ofTypes: [CourseNoteLabel]) {
        self.text = text
        self.types = ofTypes
    }

    var body: some View {
        Text(text)
            .padding(.horizontal, .huiSpaces.space2)
            .padding(.top, .huiSpaces.space2)
            .huiTypography(.p1)
            .overlay(
                Rectangle()
                    .frame(height: 2)
                    .foregroundColor(firstType.color),
                alignment: .bottom
            )
            .background(firstType.color.opacity(0.2))
    }
}
