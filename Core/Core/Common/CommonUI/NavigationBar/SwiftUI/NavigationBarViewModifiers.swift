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

@available(iOS, deprecated: 26)
protocol NavigationBarStyled: AnyObject {
    var navigationBarStyle: NavigationBarStyle { get set }
}

@available(iOS, deprecated: 26)
struct NavigationBarStyleModifier: ViewModifier {
    let style: NavigationBarStyle

    @Environment(\.viewController) var controller

    func body(content: Content) -> some View {
        (controller.value as? NavigationBarStyled)?.navigationBarStyle = style
        controller.value.navigationController?.navigationBar.useStyle(style)

        return content.overlay(Color?.none) // needs something modified to actually run
            .environment(\.navBarColors, .init(style: style))
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

@available(iOS, deprecated: 26)
struct GlobalNavigationBarModifier: ViewModifier {
    @Environment(\.viewController) var controller

    func body(content: Content) -> some View {
        controller.value.navigationItem.titleView = Brand.shared.headerImageView()
        return content.navigationBarStyle(.global)
    }
}

@available(iOS, deprecated: 26)
struct NavBarBackButtonModifier: ViewModifier {
    @Environment(\.viewController) private var controller

    func body(content: Content) -> some View {
        controller.value.navigationItem.backButtonDisplayMode = .generic
        controller.value.navigationItem.backButtonTitle = String(localized: "Back", bundle: .core)
        return content.overlay(Color?.none) // needs something modified to actually run
    }
}

extension View {

    @ViewBuilder
    public func navigationTitle(_ title: String, style: NavigationBarStyle) -> some View {
        // TODO: Replace with commented version after a11y issues are fixed (see comments for `NavigationBarTitleView`)
        self
            .navigationBarTitleView(title: title, subtitle: nil)
            .navigationBarStyle(style)

//        if #available(iOS 26, *) {
//            self
//                .navigationTitle(title)
//        } else {
//            self
//                .navigationBarTitleView(title: title, subtitle: nil)
//                .navigationBarStyle(style)
//        }
    }

    @ViewBuilder
    public func navigationTitles(title: String, subtitle: String?, style: NavigationBarStyle) -> some View {
        // TODO: Replace with commented version after a11y issues are fixed (see comments for `NavigationBarTitleView`)
        self
            .navigationBarTitleView(title: title, subtitle: subtitle)
            .navigationBarStyle(style)

//        if #available(iOS 26, *) {
//            if let subtitle {
//                self
//                    .navigationSubtitle(subtitle)
//                    .navigationTitle(title)
//            } else {
//                self
//                    .navigationTitle(title)
//            }
//        } else {
//            self
//                .navigationBarTitleView(title: title, subtitle: subtitle)
//                .navigationBarStyle(style)
//        }
    }

    /// Sets the navigation bar's background color, title color & font, button color & font.
    /// - Warning: Make sure to call this method AFTER calling `navigationBarTitleView()` to affect it.
    /// - Parameters:
    ///     - style:
    ///       - `.global` is used only on a few screens, typically on root screens of each tab.
    ///       - `.modal` is primarily used on modal screens, but also on some screen which doesn't belong to a context, but not considered global.
    ///       - `.color()` is used on non-modal screens within a context (typically a course or group), and in some other cases.
    ///       - Use `.color(nil)` to keep the navigation bar's current context background color but ensure the proper title color is set.
    @available(iOS, deprecated: 26)
    public func navigationBarStyle(_ style: NavigationBarStyle) -> some View {
        modifier(NavigationBarStyleModifier(style: style))
    }

    /// Sets the navigation bar's title and subtitle, using the proper fonts and arrangement.
    /// - Warning: Make sure to call `navigationBarStyle()` _**AFTER**_ this method to set the proper text colors.
    /// - Parameters:
    ///     - title: The line is always displayed, even if this is empty. (This should not happen normally.)
    ///     - subtitle: The subtitle line is only displayed if this is not empty.
    @available(iOS, deprecated: 26)
    private func navigationBarTitleView(title: String, subtitle: String?) -> some View {
        toolbar {
            ToolbarItem(placement: .principal) {
                InstUI.NavigationBarTitleView(title: title, subtitle: subtitle)
            }
        }
    }

    /// Sets the navigation bar's background color, button color to match the `Brand.shared` colors,
    /// sets the button font and sets the brand logo as the titleView.
    @available(iOS, deprecated: 26)
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
}
