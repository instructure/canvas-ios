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

extension HorizonUI.Controls {
    struct ToggleDescriptionView: View {
        // MARK: - Dependencies

        let title: String
        let description: String?
        let errorMessage: String?
        let isRequired: Bool

        // MARK: - Init

        init(
            title: String,
            description: String? = nil,
            errorMessage: String? = nil,
            isRequired: Bool = false
        ) {
            self.title = title
            self.description = description
            self.errorMessage = errorMessage
            self.isRequired = isRequired
        }

        var body: some View {
            VStack(alignment: .leading, spacing: .huiSpaces.primitives.xxSmall) {
                HStack(alignment: .top, spacing: .huiSpaces.primitives.xxxSmall) {
                    Text(title)
                    if isRequired {
                        Text(verbatim: "*")
                    }
                }
                .foregroundStyle(Color.huiColors.text.body)

                if let description {
                    Text(description)
                        .foregroundStyle(Color.huiColors.text.dataPoint)
                }
                errorMessageView
            }
        }

        @ViewBuilder
        private var errorMessageView: some View {
            if let errorMessage {
                HStack(spacing: .huiSpaces.primitives.xxxSmall) {
                    Image.huiIcons.error
                        .resizable()
                        .frame(width: 14, height: 14)

                    Text(errorMessage)
                        .huiTypography(.p2)

                }
                .foregroundStyle(Color.huiColors.text.error)
            }
        }
    }
}

#Preview {
    HorizonUI.Controls.ToggleDescriptionView(
        title: "Content",
        description: "Description",
        isRequired: true
    )
}
