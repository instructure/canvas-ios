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

public extension HorizonUI.LearningObjectItem {
    enum RequirementType {
        case optional
        case required

        var title: String {
            switch self {
            case .optional: return String(localized: "Optional")
            case .required: return String(localized: "Required")
            }
        }
    }

    enum Status {
        case completed
        case locked
    }
}

extension HorizonUI.LearningObjectItem {
    struct StatusView: View {
        // MARK: - Properties

        @State private var isTooltipVisible = false

        // MARK: - Dependencies

        let lockedMessage: String?
        let status: Status?
        let requirement: RequirementType

        // MARK: - Init

        init(
            status: Status?,
            requirement: RequirementType,
            lockedMessage: String?
        ) {
            self.lockedMessage = lockedMessage
            self.requirement = requirement
            self.status = status
        }

        var body: some View {
            if let status {
                statusView(for: status)
            } else if requirement == .required {
                requiredImage
            }
        }

        @ViewBuilder
        private func statusView(for status: Status) -> some View {
            switch status {
            case .completed: completedImage
            case .locked: lockedButton
            }
        }

        private var requiredImage: some View {
            Image.huiIcons.circle
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundStyle(Color.huiColors.lineAndBorders.lineStroke)
        }

        @ViewBuilder
        private var completedImage: some View {
            if requirement == .required {
                Image.huiIcons.checkCircleFull
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(Color.huiColors.surface.institution)
            }
        }

        private var lockedButton: some View {
            Button {
                isTooltipVisible.toggle()
            } label: {
                lockIcon
            }
            .huiTooltip(isPresented: $isTooltipVisible, arrowEdge: .bottom, style: .primary) {
                Text(lockedMessage ?? "")
                    .foregroundStyle(Color.huiColors.text.surfaceColored)
                    .huiTypography(.p2)
            }
        }

        private var lockIcon: some View {
            Image.huiIcons.lock
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundStyle(Color.huiColors.surface.institution)
        }
    }
}

#Preview {
    HorizonUI.LearningObjectItem.StatusView(
        status: .locked,
        requirement: .required,
        lockedMessage: "Jan XX at XX:XX."
    )
}
