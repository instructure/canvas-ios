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

// MARK: - Model

extension SubmissionStatusLabel {

    public struct Model: Equatable, Hashable {
        public let text: String
        public let icon: Image
        public let color: Color

        public init(text: String, icon: Image, color: Color) {
            self.text = text
            self.icon = icon
            self.color = color
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(text)
        }
    }
}

// MARK: - Status constants

extension SubmissionStatusLabel.Model {

    public static let excused = Self(
        text: String(localized: "Excused", bundle: .core),
        icon: .completeSolid,
        color: .textWarning
    )

    public static func custom(_ name: String) -> Self {
        .init(
            text: name,
            icon: .flagLine,
            color: .textInfo
        )
    }

    public static let late = Self(
        text: String(localized: "Late", bundle: .core),
        icon: .clockLine,
        color: .textWarning
    )

    public static let missing = Self(
        text: String(localized: "Missing", bundle: .core),
        icon: .noSolid,
        color: .textDanger
    )

    public static let graded = Self(
        text: String(localized: "Graded", bundle: .core),
        icon: .completeSolid,
        color: .textSuccess
    )

    public static let submitted = Self(
        text: String(localized: "Submitted", bundle: .core),
        icon: .completeLine,
        color: .textSuccess
    )

    public static let onPaper = Self(
        text: String(localized: "On Paper", bundle: .core),
        icon: .noSolid,
        color: .textDark
    )

    public static let noSubmission = Self(
        text: String(localized: "No Submission", bundle: .core),
        icon: .noSolid,
        color: .textDark
    )

    public static let notGradable = Self(
        text: String(localized: "Not Graded", bundle: .core),
        icon: .noSolid,
        color: .textDark
    )

    public static let notSubmitted = Self(
        text: String(localized: "Not Submitted", bundle: .core),
        icon: .noSolid,
        color: .textDark
    )
}

#if DEBUG

#Preview {
    PreviewContainer(spacing: 20) {
        SubmissionStatusLabel(
            model: .graded
        )

        SubmissionStatusLabel(
            model: .graded,
            iconSize: 24,
            font: .regular16
        )

        SubmissionStatusLabel(
            model: .notSubmitted
        )

        SubmissionStatusLabel(
            model: .init(text: .loremIpsumMedium, icon: .noSolid, color: .textDanger)
        )
    }
}

#endif
