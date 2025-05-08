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

import UIKit

protocol CoreWebViewThemeSwitcher {
    var currentHeight: CGFloat { get }
    var isThemeInverted: Bool { get }
    func pinHostAndButton(inside parent: UIView, leading: CGFloat?, trailing: CGFloat?, top: CGFloat?, bottom: CGFloat?)
    func updateUserInterfaceStyle(with style: UIUserInterfaceStyle)
}

extension CoreWebViewThemeSwitcher {
    func pinHostAndButton(
        inside parent: UIView,
        leading: CGFloat? = 0,
        trailing: CGFloat? = 0,
        top: CGFloat? = 0,
        bottom: CGFloat? = 0
    ) {
        pinHostAndButton(inside: parent, leading: leading, trailing: trailing, top: top, bottom: bottom)
    }
}

final class CoreWebViewThemeSwitcherLive: CoreWebViewThemeSwitcher {
    private struct Constants {
        static let buttonHeight: CGFloat = 38
        static let topPadding: CGFloat = 16
        static let horizontalPadding: CGFloat = 16
    }

    private weak var host: UIView?

    private var themeSwitcherButton: CoreWebViewThemeSwitcherButton?
    private var themeSwitcherButtonHeightConstraint: NSLayoutConstraint?
    private var themeSwitcherButtonTopConstraint: NSLayoutConstraint?

    private var userInterfaceStyleDidChangeObserver: NSObjectProtocol?

    private var isInverted = false
    private var isThemeDark = false

    var currentHeight: CGFloat {
        isThemeDark ? Constants.buttonHeight + Constants.topPadding : 0
    }

    var isThemeInverted: Bool {
        isInverted
    }

    init(host: UIView) {
        self.host = host
    }

    /**
     Adds a theme switcher button to parent and sets up constraints between the webview, the button and parent.
     - parameters:
        - leading: The leading padding between the webview and the parent view. If nil is passed then it's the caller's responsibility to add this constraint. Default is 0.
        - trailing: The trailing padding between the webview and the parent view. If nil is passed then it's the caller's responsibility to add this constraint. Default is 0.
        - top: The top padding between the webview and the theme switcher button. If nil is passed then it's the caller's responsibility to add this constraint. Default is 0.
        - bottom: The bottom padding between the webview and the parent view. If nil is passed then it's the caller's responsibility to add this constraint. Default is 0.
     */
    func pinHostAndButton(
        inside parent: UIView,
        leading: CGFloat? = 0,
        trailing: CGFloat? = 0,
        top: CGFloat? = 0,
        bottom: CGFloat? = 0
    ) {
        guard let host else { return }

        let button = CoreWebViewThemeSwitcherButton { [weak self] in
            self?.didTapThemeSwitcherButton()
        }
        parent.addSubview(button)

        // pin button
        let heightConstraint = button.heightAnchor.constraint(equalToConstant: 0)
        let topConstraint = button.topAnchor.constraint(equalTo: parent.topAnchor, constant: 0)
        NSLayoutConstraint.activate([
            heightConstraint,
            topConstraint,
            button.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: Constants.horizontalPadding),
            button.trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: -Constants.horizontalPadding),
            button.bottomAnchor.constraint(equalTo: host.topAnchor, constant: 0)
        ])

        // pin webView
        NSLayoutConstraint.activate([
            leading.map { host.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: $0) },
            trailing.map { parent.trailingAnchor.constraint(equalTo: host.trailingAnchor, constant: $0)},
            top.map { host.topAnchor.constraint(equalTo: button.bottomAnchor, constant: $0) },
            bottom.map { parent.bottomAnchor.constraint(equalTo: host.bottomAnchor, constant: $0) }
        ].compactMap { $0 })

        themeSwitcherButton = button
        themeSwitcherButtonHeightConstraint = heightConstraint
        themeSwitcherButtonTopConstraint = topConstraint
    }

    private func didTapThemeSwitcherButton() {
        themeSwitcherButton?.invert()

        isInverted.toggle()
        updateOverrideUserInterfaceStyle()
    }

    private func addUserInterfaceStyleDidChangeObserver() {
        userInterfaceStyleDidChangeObserver = NotificationCenter.default.addObserver(
            forName: .windowUserInterfaceStyleDidChange,
            object: nil,
            queue: .main,
            using: { [weak self] in
                self?.updateUserInterfaceStyle(with: $0.userInfo?["style"] as? UIUserInterfaceStyle ?? .unspecified)
            }
        )
    }

    func updateUserInterfaceStyle(with style: UIUserInterfaceStyle) {
        let definiteStyle = style == .unspecified ? .current : style
        isThemeDark = definiteStyle == .dark
        updateOverrideUserInterfaceStyle()

        // show/hide Theme Switcher
        themeSwitcherButton?.isHidden = !isThemeDark
        themeSwitcherButtonHeightConstraint?.constant = isThemeDark ? Constants.buttonHeight : 0
        themeSwitcherButtonTopConstraint?.constant = isThemeDark ? Constants.topPadding : 0
    }

    private func updateOverrideUserInterfaceStyle() {
        let currentStyle: UIUserInterfaceStyle = isThemeDark ? (isInverted ? .light : .dark) : .light

        /// Though we are registered to user interface changes In CoreWebView and updateUserInterfaceStyle should be triggered
        /// on trait changes, but it's not happening when overrideUserInterfaceStyle is not unspecified, so we still need this workaround.
        /// Latest check was with iOS 18.4.
        if host?.overrideUserInterfaceStyle == .unspecified && currentStyle != .unspecified {
            addUserInterfaceStyleDidChangeObserver()
        }
        // override style, based on current settings
        host?.overrideUserInterfaceStyle = currentStyle

        // also update parent backgroundColor accordingly
        let traitCollection = UITraitCollection(userInterfaceStyle: currentStyle)
        themeSwitcherButton?.superview?.backgroundColor = .backgroundLightest.resolvedColor(with: traitCollection)
    }
}
