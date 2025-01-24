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
    struct IntroBlock: View {
        // MARK: - Dependencies

        let moduleName: String
        let moduleItemName: String
        let duration: String
        let dueDate: String
        let onBack: () -> Void
        let onMenu: () -> Void

        // MARK: - Init

        init(
            moduleName: String,
            moduleItemName: String,
            duration: String,
            dueDate: String,
            onBack: @escaping () -> Void,
            onMenu: @escaping () -> Void
        ) {
            self.moduleName = moduleName
            self.moduleItemName = moduleItemName
            self.duration = duration
            self.dueDate = dueDate
            self.onBack = onBack
            self.onMenu = onMenu
        }

        public var body: some View {
            VStack(spacing: .huiSpaces.primitives.small) {
                HStack {
                    backButton
                    Spacer()
                    moduleTitleView
                    Spacer()
                    menuButton
                }
                moduleInfoView
            }
            .padding(.horizontal, .huiSpaces.primitives.mediumSmall)
            .padding(.bottom, .huiSpaces.primitives.medium)
            .background {
                Rectangle()
                    .fill(Color.huiColors.surface.institution)
            }
        }

        private var moduleTitleView: some View {
            VStack(spacing: .huiSpaces.primitives.xxSmall) {
                Text(moduleName)
                    .huiTypography(.p3)
                    .lineLimit(1)

                Text(moduleItemName)
                    .huiTypography(.labelLargeBold)
                    .lineLimit(2)
            }
            .foregroundColor(Color.huiColors.text.surfaceColored)
            .multilineTextAlignment(.center)
        }

        private var backButton: some View {
            Button(action: onBack) {
                Image.huiIcons.arrowLeftAlt
                    .foregroundColor(Color.huiColors.icon.surfaceColored)
            }
            .frame(width: 24, height: 24)
        }

        private var menuButton: some View {
            Button(action: onMenu) {
                Image.huiIcons.listAlt
                    .foregroundColor(Color.huiColors.icon.surfaceColored)
            }
            .frame(width: 24, height: 24)
        }

        private var moduleInfoView: some View {
            HStack {
                Text(duration)
                Spacer()
                Text(dueDate)
            }
            .foregroundStyle(Color.huiColors.text.surfaceColored)
            .huiTypography(.p2)
            .padding(.horizontal, .huiSpaces.primitives.mediumSmall)
        }
    }
}

#Preview {
    HorizonUI.IntroBlock(
        moduleName: "Module Name Amet Adipiscing Elit",
        moduleItemName: "Learning Object Name Lorem Ipsum Dolor Learning Object Name Lorem Ipsum Dolor",
        duration: "XX Mins",
        dueDate: "Due XX/XX",
        onBack: {},
        onMenu: {}
    )
}
