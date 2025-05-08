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

import Foundation
import SwiftUI

public extension HorizonUI {
    struct UploadedFile: View {
        public enum ActionType {
            case delete
            case download
            case loading

            var image: Image {
                switch self {
                case .delete: HorizonUI.icons.delete
                case .download: HorizonUI.icons.download
                case .loading: HorizonUI.icons.close
                }
            }
        }

        // MARK: - Dependencies

        private let actionType: ActionType
        private let fileName: String
        private let isSelected: Bool
        private let onTap: () -> Void
        private let cornerRadius: CornerRadius = .level3

        // MARK: - Init

        public init(
            fileName: String,
            actionType: ActionType,
            isSelected: Bool = false,
            onTap: @escaping () -> Void
        ) {
            self.fileName = fileName
            self.actionType = actionType
            self.isSelected = isSelected
            self.onTap = onTap
        }

        public var body: some View {
            HStack(spacing: .huiSpaces.space10) {
                if actionType == .delete {
                    HorizonUI.icons.checkCircleFull
                        .foregroundStyle(Color.huiColors.icon.success)
                }
                if actionType == .loading {
                    HorizonUI.Spinner(size: .xSmall, showBackground: true)
                }
                Text(fileName)
                    .huiTypography(.p1)
                    .foregroundStyle(Color.huiColors.text.body)

                Spacer()
                HorizonUI.IconButton(actionType.image, type: .white) {
                    onTap()
                }
            }
            .padding(.huiSpaces.space16)
            .huiBorder(
                level: .level1,
                color: isSelected
                ? Color.huiColors.surface.institution
                : Color.huiColors.lineAndBorders.lineStroke,
                radius: cornerRadius.attributes.radius
            )
        }
    }
}

#Preview {
    HorizonUI.UploadedFile(fileName: "LoremIpsumFileName.xxx", actionType: .delete) {}
        .padding()
}
