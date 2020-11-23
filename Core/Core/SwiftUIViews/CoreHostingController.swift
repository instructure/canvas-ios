//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

public class CoreHostingController<Content: View>: UIHostingController<CoreHostingBaseView<Content>>, NavigationBarStyled {
    public var navigationBarStyle = UINavigationBar.Style.color(nil) // not applied until changed
    var testTree: TestTree?

    public init(_ rootView: Content) {
        let ref = WeakReference<CoreHostingController<Content>>()
        super.init(rootView: CoreHostingBaseView(content: rootView, controller: ref))
        ref.value = self
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.useStyle(navigationBarStyle)
    }
}

public struct CoreHostingBaseView<Content: View>: View {
    public var content: Content
    let controller: WeakReference<CoreHostingController<Content>>

    public var body: some View {
        content
            .testID()
            .accentColor(Color(Brand.shared.primary))
            .environment(\.appEnvironment, AppEnvironment.shared)
            .environment(\.viewController, controller.value ?? UIViewController())
            .onPreferenceChange(TestTree.self) { testTrees in
                controller.value?.testTree = testTrees.first { $0.type == Content.self }
            }
    }
}

extension AppEnvironment: EnvironmentKey {
    public static var defaultValue: AppEnvironment { AppEnvironment.shared }
}

extension UIViewController: EnvironmentKey {
    public static var defaultValue: WeakReference<UIViewController> { WeakReference() }
}

extension EnvironmentValues {
    public var appEnvironment: AppEnvironment {
        get { self[AppEnvironment.self] }
        set { self[AppEnvironment.self] = newValue }
    }

    public var viewController: UIViewController {
        get { self[UIViewController.self].value ?? AppEnvironment.shared.topViewController ?? UIViewController() }
        set { self[UIViewController.self] = WeakReference(newValue) }
    }
}

protocol NavigationBarStyled: class {
    var navigationBarStyle: UINavigationBar.Style { get set }
}
struct NavigationBarStyleModifier: ViewModifier {
    let style: UINavigationBar.Style

    @Environment(\.viewController) var controller

    func body(content: Content) -> some View {
        (controller as? NavigationBarStyled)?.navigationBarStyle = style
        if #available(iOS 14, *) {
            controller.navigationController?.navigationBar.useStyle(style)
        } else { DispatchQueue.main.async {
            controller.navigationController?.navigationBar.useStyle(style)
        } }
        return content.overlay(Color?.none) // needs something modified to actually run
    }
}

struct TitleSubtitleModifier: ViewModifier {
    let title: String
    let subtitle: String?

    @Environment(\.viewController) var controller

    func body(content: Content) -> some View {
        let view = controller.navigationItem.titleView as? TitleSubtitleView ?? {
            let view = TitleSubtitleView.create()
            controller.navigationItem.titleView = view
            return view
        }()
        view.title = title
        view.subtitle = subtitle
        return content.navigationBarTitle(Text(title))
    }
}

struct GlobalNavigationBarModifier: ViewModifier {
    @Environment(\.viewController) var controller

    func body(content: Content) -> some View {
        controller.navigationItem.titleView = Brand.shared.headerImageView()
        return content.navigationBarStyle(.global)
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
}

public class WeakReference<Value: AnyObject> {
    public weak var value: Value?
    public init(_ value: Value? = nil) {
        self.value = value
    }
}
