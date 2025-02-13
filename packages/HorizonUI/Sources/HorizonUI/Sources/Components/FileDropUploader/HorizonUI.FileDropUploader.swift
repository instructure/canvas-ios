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

public extension HorizonUI {
    struct FileDropUploader: View {
        private let cornerRadius = CornerRadius.level2

        // MARK: - Dependencies

        private let acceptedFilesType: String
        private let onTap: () -> Void

        // MARK: - Init

        public init(
            acceptedFilesType: String,
            onTap: @escaping () -> Void
        ) {
            self.acceptedFilesType = acceptedFilesType
            self.onTap = onTap
        }

        public var body: some View {
            VStack(alignment: .center, spacing: .huiSpaces.primitives.medium) {
                HorizonUI.PrimaryButton("Upload File", type: .blue) {
                    onTap()
                }
                acceptedFilesView
            }
            .frame(height: 190)
            .frame(maxWidth: .infinity)
            .background(dashLineView)
        }

        private var dashLineView: some View {
            RoundedRectangle(cornerRadius: cornerRadius.attributes.radius)
                .fill(Color.huiColors.surface.cardPrimary)
                .stroke(Color.huiColors.lineAndBorders.lineStroke,
                        style: StrokeStyle(lineWidth: 1, dash: [6, 5]))
        }

        private var acceptedFilesView: some View {
            HStack(spacing: .huiSpaces.primitives.xxSmall) {
                Text("Accepted file types:")
                Text(acceptedFilesType)
            }
            .foregroundStyle(Color.huiColors.text.body)
            .huiTypography(.p2)
            .padding(.horizontal, .huiSpaces.primitives.mediumSmall)
        }
    }
}

#Preview {
    HorizonUI.FileDropUploader(acceptedFilesType: "pdf, docx") {

    }
}
