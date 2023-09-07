//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

protocol NavigationBarStyled: AnyObject {
    var navigationBarStyle: UINavigationBar.Style { get set }
}

struct NavigationBarStyleModifier: ViewModifier {
    let style: UINavigationBar.Style

    @Environment(\.viewController) var controller

    func body(content: Content) -> some View {
        (controller.value as? NavigationBarStyled)?.navigationBarStyle = style
        controller.value.navigationController?.navigationBar.useStyle(style)
        return content.overlay(Color?.none) // needs something modified to actually run
    }
}

struct TitleSubtitleModifier: ViewModifier {
    let title: String
    let subtitle: String?

    @Environment(\.viewController) var controller

    func body(content: Content) -> some View {
        let view = controller.value.navigationItem.titleView as? TitleSubtitleView ?? {
            let view = TitleSubtitleView.create()
            controller.value.navigationItem.titleView = view
            return view
        }()
        view.title = title
        view.subtitle = subtitle
        var combinedTitle = title
        if let subtitle = subtitle, subtitle != "" {
            combinedTitle += ", \(subtitle)"
        }
        return content.navigationBarTitle(Text(combinedTitle))
    }
}

struct RightBarButtonItemModifier: ViewModifier {
    let barButtonItems: () -> [UIBarButtonItemWithCompletion]

    @Environment(\.viewController) var controller

    func body(content: Content) -> some View {
        controller.value.navigationItem.setRightBarButtonItems(barButtonItems(), animated: false)
        return content.overlay(Color?.none) // needs something modified to actually run
    }
}

struct GlobalNavigationBarModifier: ViewModifier {
    @Environment(\.viewController) var controller

    func body(content: Content) -> some View {
        controller.value.navigationItem.titleView = Brand.shared.headerImageView()
        return content.navigationBarStyle(.global)
    }
}

struct NavBarBackButtonModifier: ViewModifier {
    @Environment(\.viewController) private var controller

    func body(content: Content) -> some View {
        controller.value.navigationItem.backButtonDisplayMode = .generic
        controller.value.navigationItem.backButtonTitle = NSLocalizedString("Back", bundle: .core, comment: "")
        return content.overlay(Color?.none) // needs something modified to actually run
    }
}

struct HideBackButtonModifier: ViewModifier {
    @Environment(\.viewController) private var controller

    func body(content: Content) -> some View {
        controller.value.navigationItem.hidesBackButton = true
        controller.value.navigationItem.leftBarButtonItems = []
        return content.overlay(Color?.none) // needs something modified to actually run
    }
}

extension View {
    public func navigationBarStyle(_ style: UINavigationBar.Style) -> some View {
        modifier(NavigationBarStyleModifier(style: style))
    }

    public func navigationTitle(_ title: String, subtitle: String?) -> some View {
        modifier(TitleSubtitleModifier(title: title, subtitle: subtitle))
    }

    public func navigationBarGlobal() -> some View {
        modifier(GlobalNavigationBarModifier())
    }

    /// Adds a list of `UIBarButtonItem` to the SwiftUI view's hosting controller. Use this modifier when you want to avoid passing SwiftUI ToolbarItems between UIViewControllers.
    /// Otherwise, use the `SwiftUI.View.navBarItems` function.
    public func rightBarButtonItems(_ barButtonItems: @escaping () -> [UIBarButtonItemWithCompletion]) -> some View {
        modifier(RightBarButtonItemModifier(barButtonItems: barButtonItems))
    }

    /** Make the next view controller in the navigation stack to display a standard < Back button. */
    public func navigationBarGenericBackButton() -> some View {
        modifier(NavBarBackButtonModifier())
    }

    public func hideBackButton() -> some View {
        modifier(HideBackButtonModifier())
    }
}
