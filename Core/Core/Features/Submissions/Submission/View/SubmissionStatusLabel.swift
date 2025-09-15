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

public struct SubmissionStatusLabel: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private let model: Model
    private let iconSize: CGFloat
    private let font: UIFont.Name

    public init(
        model: Model,
        iconSize: CGFloat = 16,
        font: UIFont.Name = .regular14
    ) {
        self.model = model
        self.iconSize = iconSize
        self.font = font
    }

    public var body: some View {
        HStack(alignment: .center, spacing: 2) {
            model.icon
                .scaledIcon(size: iconSize)
                .accessibilityHidden(true)
            Text(model.text)
                .font(font, lineHeight: .fit)
        }
        .foregroundStyle(model.color)
    }
}

extension SubmissionStatusLabel {
    public struct Model: Equatable {
        let text: String
        let icon: Image
        let color: Color

        public init(text: String, icon: Image, color: Color) {
            self.text = text
            self.icon = icon
            self.color = color
        }
    }
}

extension SubmissionStatusLabel.Model {
    public init(status: SubmissionStatusOld) {
        self.init(
            text: status.text,
            icon: status.icon.asImage,
            color: status.color.asColor
        )
    }

    public init(stateDisplayProperties: SubmissionStateDisplayProperties) {
        self.init(
            text: stateDisplayProperties.text,
            icon: stateDisplayProperties.icon.asImage,
            color: stateDisplayProperties.color.asColor
        )
    }
}

#if DEBUG

#Preview {
    PreviewContainer(spacing: 20) {
        SubmissionStatusLabel(
            model: .init(text: "Graded", icon: .completeSolid, color: .textSuccess)
        )

        SubmissionStatusLabel(
            model: .init(text: "Graded", icon: .completeSolid, color: .textSuccess),
            iconSize: 24,
            font: .regular16
        )

        SubmissionStatusLabel(
            model: .init(text: "Not Submitted", icon: .noSolid, color: .textDark)
        )

        SubmissionStatusLabel(
            model: .init(text: .loremIpsumMedium, icon: .noSolid, color: .textDanger)
        )
    }
}

#endif
