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

@available(iOSApplicationExtension 13.0.0, *)
public class CoreHostingController<InnerContent: View>: UIHostingController<CoreHostingBaseView<InnerContent>> {
    public var navBarStyle = NavBarStyle.global
    var testTree: TestTree?

    public init(_ rootView: InnerContent, env: AppEnvironment = .shared) {
        let selfBox = Box()
        super.init(rootView: CoreHostingBaseView(rootView: rootView, env: env) {
            selfBox.value
        })
        selfBox.value = self
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyNavBarStyle()
    }

    func applyNavBarStyle(_ style: NavBarStyle? = nil) {
        navBarStyle = style ?? navBarStyle
        switch navBarStyle {
        case .global:
            self.navigationController?.navigationBar.useGlobalNavStyle()
        case .color(let color):
            self.navigationController?.navigationBar.useContextColor(color)
        }
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private class Box {
        weak var value: CoreHostingController<InnerContent>?
        init() { }
    }

}

@available(iOSApplicationExtension 13.0.0, *)
public struct CoreHostingBaseView<Content: View>: View {
    var rootView: Content
    let env: AppEnvironment
    let controller: () -> CoreHostingController<Content>?

    public var body: some View {
        rootView
            .testID()
            .environment(\.appEnvironment, env)
            .environment(\.viewController, controller)
            .onPreferenceChange(NavBarStyle.self) { style in
                self.controller()?.applyNavBarStyle(style)
            }.onPreferenceChange(TestTree.self) { testTrees in
                self.controller()?.testTree = testTrees.first { $0.type == Content.self }
            }
    }
}
