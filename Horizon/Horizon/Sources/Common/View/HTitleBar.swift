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

import Core
import HorizonUI
import SwiftUI

struct HTitleBar: View {

    // MARK: - Types
    typealias Callback = (Action) -> Void

    /// These are the possible actions that can be taken on the title bar
    enum Action {
        case back
        case close
        case createMessage
        case inbox
        case notebook
        case notifications
    }

    /// These are the possible states for each action
    /// These can be passed in to modify the styling of the action button
    enum ActionState {
        case disabled
        case enabled
        case hidden
    }

    /// These are the possible pages that the title bar can be used on
    enum Page {
        case assist
        case assistQuiz
        case assistFlashCards
        case createMessage
        case dashboard
        case inbox
        case inboxAnnouncement
        case inboxMessageDetails
        case note
        case notebook
        case notifications
        case settingsAdvanced
        case settingsNotifications
        case settingsProblemReport
        case settingsProfile
        case skillspace
    }

    // MARK: - Constants
    /// Configuring the icons for each action
    private static let actionIcon: [Action: Image] = [
        .back: .huiIcons.arrowBack,
        .close: .huiIcons.close,
        .inbox: .huiIcons.mail,
        .notebook: .huiIcons.menuBookNotebook,
        .notifications: .huiIcons.notifications
    ]

    /// Configuring the background color for each page
    private static let backgroundColorMap: [Page: Color] = [
        .assist: .clear,
        .createMessage: HorizonUI.colors.surface.pageSecondary
    ]

    /// configuring which pages have a back button
    private static let backButtonPages: [Page] = [
        .assistFlashCards,
        .assistQuiz,
        .inbox,
        .inboxAnnouncement,
        .inboxMessageDetails,
        .notebook,
        .notifications,
        .settingsAdvanced,
        .settingsNotifications,
        .settingsProblemReport,
        .settingsProfile
    ]

    /// configuring which pages have trailing buttons and what those buttons are
    private static let trailingButtonPages: [Page: [Action]] = [
        .assist: [.back, .close],
        .createMessage: [.close],
        .dashboard: [
            .notebook,
            .notifications,
            .inbox
        ],
        .note: [.close]
    ]

    /// configuring the button type for each page's action buttons
    private static let actionButtonType: [Page: HorizonUI.ButtonStyles.ButtonType] = [
        .assist: .whiteOutline
    ]

    /// configuring the icon for each page title, when a page has an icon in the title
    private static let iconPages: [Page: Image] = [
        .assist: .huiIcons.aiFilled,
        .inboxAnnouncement: .huiIcons.announcement,
        .note: .huiIcons.menuBookNotebook,
        .notebook: .huiIcons.menuBookNotebook
    ]

    /// configuring which pages show the institution logo in the leading position
    private static let institutionLogoPages: [Page] = [
        .dashboard,
        .skillspace
    ]

    /// configuring the titles for each page
    private static let titles: [Page: String] = [
        .createMessage: .init(localized: "Create message", bundle: .horizon),
        .note: .init(localized: "Notebook", bundle: .horizon),
        .notebook: .init(localized: "Notebook", bundle: .horizon),
        .notifications: .init(localized: "Notifications", bundle: .horizon),
        .settingsAdvanced: .init(localized: "Advanced", bundle: .horizon),
        .settingsNotifications: .init(localized: "Notifications", bundle: .horizon),
        .settingsProblemReport: .init(localized: "Report a problem", bundle: .horizon),
        .settingsProfile: .init(localized: "Profile", bundle: .horizon)
    ]

    // MARK: - Dependencies
    private let background: Color
    private let leading: AnyView?
    private let title: AnyView?
    private let trailing: AnyView?
    private let trailingSpace: CGFloat

    // MARK: - Init
    init(
        page: Page,
        title: String? = nil,
        actionStates: [Action: ActionState] = [:],
        callback: Callback? = nil
    ) {
        // background
        self.background = HTitleBar.backgroundColorMap[page] ?? HorizonUI.colors.surface.pagePrimary

        // leading
        if HTitleBar.institutionLogoPages.contains(page) {
            self.leading = AnyView(InstitutionLogo())
        } else if HTitleBar.backButtonPages.contains(page) {
            self.leading = HTitleBar.button(
                action: .back,
                state: actionStates[.back] ?? .enabled,
                callback: callback
            )
            .map { AnyView($0) }
        } else if page == .assist {
            self.leading = AnyView(HTitleBar.assistTitle)
        } else {
            self.leading = nil
        }

        // title
        self.title = (title ?? HTitleBar.titles[page])
            .map { HTitleBar.titleText($0, icon: HTitleBar.iconPages[page]) }
            .map { AnyView($0) }

        // trailing
        if HTitleBar.trailingButtonPages.keys.contains(page) {
            let actions = HTitleBar.trailingButtonPages[page] ?? []
            self.trailing = AnyView(
                HStack(spacing: .huiSpaces.space8) {
                    ForEach(actions.indices, id: \.self) { index in
                        HTitleBar.button(
                            action: actions[index],
                            state: actionStates[actions[index]] ?? .enabled,
                            type: HTitleBar.actionButtonType[page] ?? .darkOutline,
                            callback: callback
                        )
                    }
                }
            )
        } else if page == .inbox {
            self.trailing = AnyView(
                HorizonUI.PrimaryButton(
                    String(localized: "Create message", bundle: .horizon),
                    type: .institution,
                    leading: HorizonUI.icons.editSquare,
                    action: { callback.map { $0(.createMessage) } }
                )
                .frame(width: 200)
            )
        } else {
            self.trailing = nil
        }

        // trailing space
        self.trailingSpace = page == .inbox ?
            .huiSpaces.space8 :
            .huiSpaces.space24
    }

    // MARK: - Body
    var body: some View {
        let leadingView = leading == nil && trailing != nil ? AnyView(trailing?.opacity(0)) : leading
        let trailingView = trailing == nil && leading != nil ? AnyView(leading?.opacity(0)) : trailing
        let title = title ?? AnyView(Spacer())
        HStack(spacing: .zero) {
            leadingView
            title.frame(maxWidth: .infinity)
            trailingView
        }
        .padding(.vertical, .huiSpaces.space12)
        .padding(.leading, .huiSpaces.space24)
        .padding(.trailing, trailingSpace)
        .background(background)
    }

    // MARK: - Private
    @ViewBuilder
    private static func button(
        action: Action = .close,
        state: ActionState = .enabled,
        type: HorizonUI.ButtonStyles.ButtonType = .darkOutline,
        callback: Callback?
    ) -> (some View)? {
        callback.map { fn in
            HorizonUI.IconButton(
                HTitleBar.actionIcon[action] ?? .huiIcons.close,
                type: type,
                isSmall: true,
                action: { fn(action) }
            )
            .opacity(state == .hidden ? 0.0 : 1.0)
            .disabled(state == .disabled)
        }
    }

    @ViewBuilder
    private static func titleText(_ text: String?, icon: Image? = nil) -> (some View)? {
        text.map { text in
            HStack(
                alignment: .center,
                spacing: .huiSpaces.space8
            ) {
                icon
                Text(text)
                    .lineLimit(1)
                    .huiTypography(.h3)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private static var assistTitle: some View {
        HStack {
            HorizonUI.icons.aiFilled
            Text(String(localized: "IgniteAI", bundle: .horizon))
                .huiTypography(.h4)

        }
        .foregroundStyle(Color.textLightest)
        .foregroundStyle(Color.huiColors.text.surfaceColored)
    }
}
