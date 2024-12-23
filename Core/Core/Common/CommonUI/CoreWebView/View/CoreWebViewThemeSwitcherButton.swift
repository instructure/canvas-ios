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

final class CoreWebViewThemeSwitcherButton: UIButton {
    private struct Titles {
        static let currentlyLight = String(localized: "Switch To Dark Mode", bundle: .core)
        static let currentlyDark = String(localized: "Switch To Light Mode", bundle: .core)
    }

    /// Helper to simplify logic by removing `.unspecified`.
    private enum Style: Equatable {
        case light
        case dark

        var userInterfaceStyle: UIUserInterfaceStyle {
            switch self {
            case .light: .light
            case .dark: .dark
            }
        }
    }

    private var style: Style = .dark

    init(primaryAction: @escaping () -> Void) {
        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false
        addAction(UIAction(title: "", handler: { _ in primaryAction() }), for: .primaryActionTriggered)
        setupConfiguration()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupConfiguration() {
        var config = UIButton.Configuration.borderedProminent()
        config.cornerStyle = .capsule
        config.background.strokeWidth = 1.0
        config.image = .unionLine
        config.imagePadding = 9.5
        config.imagePlacement = .leading
        config.preferredSymbolConfigurationForImage = .init(scale: .medium)
        configuration = config
    }

    override func updateConfiguration() {
        var config = configuration

        config?.title = style == .light ? Titles.currentlyLight : Titles.currentlyDark

        let traitCollection = UITraitCollection(userInterfaceStyle: style.userInterfaceStyle)
        config?.background.backgroundColor = .backgroundLightest.resolvedColor(with: traitCollection)
        config?.background.strokeColor = .borderDarkest.resolvedColor(with: traitCollection)
        config?.baseForegroundColor = .textDarkest.resolvedColor(with: traitCollection)

        configuration = config
    }

    func invert() {
        switch style {
        case .light:
            style = .dark
        case .dark:
            style = .light
        }
        setNeedsUpdateConfiguration()
    }
}
