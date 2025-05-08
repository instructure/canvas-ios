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

import HorizonUI
import SwiftUI

struct IntroBlock: View {
    // MARK: - Dependencies

    let moduleName: String
    let moduleItemName: String
    let duration: String?
    let countOfPoints: String?
    let dueDate: String?
    let isOverdue: Bool
    let attemptCount: String?
    let backgroundColor: Color
    let foregroundColor: Color
    let isMenuButtonVisible: Bool
    let onBack: () -> Void
    let onMenu: () -> Void

    // MARK: - Init

    public init(
        moduleName: String,
        moduleItemName: String,
        duration: String?,
        countOfPoints: String? = nil,
        dueDate: String?,
        isOverdue: Bool = false,
        attemptCount: String? = nil,
        backgroundColor: Color = Color.huiColors.surface.institution,
        foregroundColor: Color = Color.huiColors.text.surfaceColored,
        isMenuButtonVisible: Bool = true,
        onBack: @escaping () -> Void,
        onMenu: @escaping () -> Void
    ) {
        self.moduleName = moduleName
        self.moduleItemName = moduleItemName
        self.duration = duration
        self.countOfPoints = countOfPoints
        self.dueDate = dueDate
        self.isOverdue = isOverdue
        self.attemptCount = attemptCount
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.isMenuButtonVisible = isMenuButtonVisible
        self.onBack = onBack
        self.onMenu = onMenu
    }

    public var body: some View {
        VStack(spacing: .huiSpaces.space12) {
            HStack {
                backButton
                Spacer()
                moduleTitleView
                Spacer()
                menuButton
            }
            moduleInfoView
            if let attemptsAllowed = attemptsAllowed {
                Text(attemptsAllowed)
                    .huiTypography(.p2)
                    .foregroundStyle(foregroundColor)
            }
            if isOverdue {
                HorizonUI.Pill(
                    title: String(localized: "Overdue", bundle: .horizon),
                    style: .outline(.init(borderColor: foregroundColor, textColor: foregroundColor, iconColor: foregroundColor)),
                    isUppercased: true,
                    icon: nil
                )
            }
        }
        .padding(.horizontal, .huiSpaces.space24)
        .padding(.bottom, .huiSpaces.space24)
        .background {
            Rectangle()
                .fill(backgroundColor)
        }
    }

    private var moduleTitleView: some View {
        VStack(spacing: .huiSpaces.space4) {
            Text(moduleName)
                .huiTypography(.p3)
                .lineLimit(1)

            Text(moduleItemName)
                .huiTypography(.labelLargeBold)
                .lineLimit(2)
        }
        .foregroundColor(foregroundColor)
        .multilineTextAlignment(.center)
    }

    private var backButton: some View {
        Button(action: onBack) {
            Image.huiIcons.arrowLeftAlt
                .foregroundColor(foregroundColor)
        }
        .frame(width: .huiSpaces.space24, height: .huiSpaces.space24)
    }

    @ViewBuilder
    private var menuButton: some View {
        if isMenuButtonVisible {
            Button(action: onMenu) {
                Image.huiIcons.listAlt
                    .foregroundColor(foregroundColor)
            }
            .frame(width: .huiSpaces.space24, height: .huiSpaces.space24)
        }
    }

    private var moduleInfoView: some View {
        Text(moduleItemInfo)
            .foregroundStyle(foregroundColor)
            .huiTypography(.p2)
            .padding(.horizontal, .huiSpaces.space16)
    }

    private var moduleItemInfo: String {
        let dueText = dueDate.map { "\(String(localized: "Due", bundle: .horizon)) \($0)" }
        let pointsText = countOfPoints.map { "\($0) \(String(localized: "Points Possible", bundle: .horizon))" }
        let items = [duration, dueText, pointsText].compactMap { $0 }
        return items.joined(separator: items.count == 1 ? "" : " | ")
    }

    private var attemptsAllowed: String? {
        guard let attemptCount = attemptCount,
              let attempts = Int(attemptCount) else {
            return nil
        }
        return String(
            localized: "\(attempts) Attempts Allowed",
            comment: "The number of attempts allowed for this assignment."
        )
    }
}

#Preview {
    IntroBlock(
        moduleName: "Module Name Amet Adipiscing Elit",
        moduleItemName: "Learning Object Name Lorem Ipsum Dolor Learning Object Name Lorem Ipsum Dolor",
        duration: "XX Mins",
        countOfPoints: "10",
        dueDate: "Due 10/12",
        isOverdue: true,
        attemptCount: "Three",
        onBack: {},
        onMenu: {}
    )
}
