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

public class CoreHostingController<Content: View>: UIHostingController<CoreHostingBaseView<Content>> {
    public var navigationBarStyle = UINavigationBar.Style.modal
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
            .onPreferenceChange(UINavigationBar.Style.self) { style in
                controller.value?.navigationBarStyle = style
                controller.value?.navigationController?.navigationBar.useStyle(style)
            }
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
        get { self[UIViewController.self].value ?? AppEnvironment.shared.topViewController! }
        set { self[UIViewController.self] = WeakReference(newValue) }
    }
}

extension UINavigationBar.Style: PreferenceKey {
    public static var defaultValue = Self.modal
    public static func reduce(value: inout Self, nextValue: () -> Self) {
        value = nextValue()
    }
}

extension View {
    public func navigationBarStyle(_ style: UINavigationBar.Style) -> some View {
        preference(key: UINavigationBar.Style.self, value: style)
    }
}

public class WeakReference<Value: AnyObject> {
    public weak var value: Value?
    public init(_ value: Value? = nil) {
        self.value = value
    }
}
