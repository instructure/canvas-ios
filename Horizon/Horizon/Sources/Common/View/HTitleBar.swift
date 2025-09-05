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

/// A callback with no parameters
public typealias Callback = () -> Void

struct HTitleBar: View {

    // MARK: - Dependencies

    private var background: Color = HorizonUI.colors.surface.pagePrimary
    private let leading: AnyView?
    private let title: AnyView?
    private let trailing: AnyView?
    private var trailingSpace: CGFloat = .huiSpaces.space24

    // MARK: - Init

    init(
        title: String? = nil,
        icon: Image? = nil,
        color: Color = HorizonUI.colors.surface.pagePrimary,
        back: Callback? = nil,
        close: Callback? = nil
    ) {
        self.leading = HTitleBar.button(back: back).map { AnyView($0) }
        self.trailing = HTitleBar.button(close: close).map { AnyView($0) }
        self.title = HTitleBar.titleText(title, icon: icon).map { AnyView($0) }
    }

    /// Initializer for Dashboard and Skillspace views
    /// - Parameters:
    ///   - notebook: Optional callback for notebook button action
    ///   - notifications: Optional callback for notifications button action
    ///   - inbox: Optional callback for inbox button action
    init(
        notebook: Callback? = nil,
        notifications: Callback? = nil,
        inbox: Callback? = nil
    ) {
        self.title = nil
        self.leading = AnyView(InstitutionLogo())

        // Create button configurations
        let buttonConfigs = [
            (icon: HorizonUI.icons.menuBookNotebook, action: notebook),
            (icon: HorizonUI.icons.notifications, action: notifications),
            (icon: HorizonUI.icons.mail, action: inbox)
        ]

        self.trailing = AnyView(
            HStack(spacing: .huiSpaces.space8) {
                ForEach(buttonConfigs.indices, id: \.self) { index in
                    if let action = buttonConfigs[index].action {
                        HorizonUI.IconButton(
                            buttonConfigs[index].icon,
                            type: .darkOutline,
                            isSmall: true,
                            action: action
                        )
                    }
                }
            }
        )
    }

    /// Initializer for HInboxView
    /// - Parameters:
    ///   - back: Callback for back button action
    ///   - createMessage: Callback for create message button action
    init(
        back: @escaping Callback,
        createMessage: @escaping Callback
    ) {
        self.leading = HTitleBar.button(back: back).map { AnyView($0) }
        self.trailing = AnyView(
            HorizonUI.PrimaryButton(
                String(localized: "Create message", bundle: .horizon),
                type: .institution,
                leading: HorizonUI.icons.editSquare,
                action: createMessage
            )
            .frame(width: 200)
        )
        self.title = nil
        self.trailingSpace = .huiSpaces.space8
    }

    init(close: @escaping Callback, back: Callback? = nil) {
        self.leading = AnyView(HTitleBar.assistTitle)
        self.trailing = AnyView(
            HStack {
                HTitleBar.button(back: back, type: .whiteOutline)
                HTitleBar.button(close: close, type: .whiteOutline)
            }
        )
        self.background = .clear
        self.title = nil
    }

    /// Initializer for HCreateMessageView
    /// - Parameters:
    ///   - title: The title to display
    ///   - close: Callback for close button action
    init(
        title: String,
        close: Callback? = nil
    ) {
        self.trailing = HTitleBar.button(close: close).map { AnyView($0) }
        self.leading = HTitleBar.titleText(title).map { AnyView($0) }
        self.title = nil
        self.background = HorizonUI.colors.surface.pageSecondary
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
        back: Callback?,
        type: HorizonUI.ButtonStyles.ButtonType = .darkOutline
    ) -> (some View)? {
        back.map {
            HorizonUI.IconButton(
                .huiIcons.arrowBack,
                type: type,
                isSmall: true,
                action: $0
            )
        }
    }

    @ViewBuilder
    private static func button(
        close: Callback?,
        type: HorizonUI.ButtonStyles.ButtonType = .darkOutline
    ) -> (some View)? {
        close.map {
            HorizonUI.IconButton(
                .huiIcons.close,
                type: type,
                isSmall: true,
                action: $0
            )
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
