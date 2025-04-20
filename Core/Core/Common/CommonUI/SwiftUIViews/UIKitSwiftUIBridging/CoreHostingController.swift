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
import Combine

protocol TestTreeHolder: AnyObject {
    var testTree: TestTree? { get set }
}

public protocol CoreHostingControllerProtocol: UIViewController {
    var didAppearPublisher: AnyPublisher<Void, Never> { get }
}

public class CoreHostingController<Content: View>: UIHostingController<CoreHostingBaseView<Content>>,
                                                   NavigationBarStyled,
                                                   TestTreeHolder,
                                                   DefaultViewProvider,
                                                   CoreHostingControllerProtocol {
    // MARK: - UIViewController Overrides
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        supportedInterfaceOrientationsValue ?? super.supportedInterfaceOrientations
    }
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        if let override = preferredStatusBarStyleOverride {
            return override(self)
        } else {
            return super.preferredStatusBarStyle
        }
    }

    // MARK: - Support Variables For Overrides
    /** The value to be returned by the `supportedInterfaceOrientations` property. Nil reverts to the default behaviour of the UIViewController regarding that property. */
    public var supportedInterfaceOrientationsValue: UIInterfaceOrientationMask?
    /** This block can be used to add custom logic to decide what to return from the `preferredStatusBarStyle` property. */
    public var preferredStatusBarStyleOverride: ((UIViewController) -> UIStatusBarStyle)?

    // MARK: - Public Properties
    public var navigationBarStyle = NavigationBarStyle.color(nil) // not applied until changed
    public private(set) var defaultViewRoute: DefaultViewRouteParameters?

    // MARK: - Private Variables
    var testTree: TestTree?
    private var screenViewTracker: ScreenViewTrackerLive?
    private var didAppearSubject = PassthroughSubject<Void, Never>()

    public init(_ rootView: Content, env: AppEnvironment = .shared, customization: ((UIViewController) -> Void)? = nil) {
        let ref = WeakViewController()
        super.init(
            rootView: CoreHostingBaseView(
                content: rootView,
                controller: ref,
                env: env
            )
        )
        customization?(self)
        ref.setValue(self)

        if let screenViewTrackable = rootView as? ScreenViewTrackable {
            screenViewTracker = ScreenViewTrackerLive(
                parameters: screenViewTrackable.screenViewTrackingParameters
            )
        }
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.useStyle(navigationBarStyle)
        screenViewTracker?.startTrackingTimeOnViewController()
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        screenViewTracker?.stopTrackingTimeOnViewController()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        didAppearSubject.send()
    }

    public var didAppearPublisher: AnyPublisher<Void, Never> {
        didAppearSubject.eraseToAnyPublisher()
    }

    public func setDefaultViewRoute(_ route: DefaultViewRouteParameters?, updating: Bool) {
        defaultViewRoute = route
        if updating { showDefaultDetailViewIfNeeded() }
    }
}

public struct CoreHostingBaseView<Content: View>: View {
    public var content: Content
    let controller: WeakViewController
    let env: AppEnvironment

    public var body: some View {
        content
            .testID()
            .accentColor(Color(Brand.shared.primary))
            .environment(\.appEnvironment, env)
            .environment(\.viewController, controller)
            .onPreferenceChange(TestTree.self) { testTrees in
                guard let controller = controller.value as? TestTreeHolder else { return }
                controller.testTree = testTrees.first { $0.type == Content.self }
            }
    }
}

// MARK: - Appearance View Modifiers

private struct DidAppearViewModifier: ViewModifier {
    @Environment(\.viewController) private var controller

    let action: () -> Void

    private var publisher: AnyPublisher<Void, Never> {
        if let coreHost = controller.value as? CoreHostingControllerProtocol {
            return coreHost.didAppearPublisher
        } else {
            return Empty().eraseToAnyPublisher()
        }
    }

    func body(content: Content) -> some View {
        content.onReceive(publisher, perform: action)
    }
}

extension View {
    func onDidAppear(perform action: @escaping () -> Void) -> some View {
        modifier(DidAppearViewModifier(action: action))
    }
}
