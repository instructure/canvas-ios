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

protocol TestTreeHolder: AnyObject {
    var testTree: TestTree? { get set }
}

public class CoreHostingController<Content: View>: UIHostingController<CoreHostingBaseView<Content>>, NavigationBarStyled, TestTreeHolder, DefaultViewProvider {
    public override var shouldAutorotate: Bool { shouldAutorotateValue ?? super.shouldAutorotate }
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask { supportedInterfaceOrientationsValue ?? super.supportedInterfaceOrientations }
    public var navigationBarStyle = UINavigationBar.Style.color(nil) // not applied until changed
    public var defaultViewRoute: String? {
        didSet {
            showDefaultDetailView()
        }
    }
    /** The value to be returned by the `shouldAutorotate` property. Nil reverts to the default behaviour of the UIViewController regarding that property. */
    public var shouldAutorotateValue: Bool?
    /** The value to be returned by the `supportedInterfaceOrientations` property. Nil reverts to the default behaviour of the UIViewController regarding that property. */
    public var supportedInterfaceOrientationsValue: UIInterfaceOrientationMask?
    var testTree: TestTree?

    public init(_ rootView: Content, customization: ((UIViewController) -> Void)? = nil) {
        let ref = WeakViewController()
        super.init(rootView: CoreHostingBaseView(content: rootView, controller: ref))
        customization?(self)
        ref.setValue(self)
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
    let controller: WeakViewController

    public var body: some View {
        content
            .testID()
            .accentColor(Color(Brand.shared.primary))
            .environment(\.appEnvironment, AppEnvironment.shared)
            .environment(\.viewController, controller)
            .onPreferenceChange(TestTree.self) { testTrees in
                guard let controller = controller.value as? TestTreeHolder else { return }
                controller.testTree = testTrees.first { $0.type == Content.self }
            }
    }
}
