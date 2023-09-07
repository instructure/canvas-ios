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

public class CoreHostingController<Content: View>: UIHostingController<CoreHostingBaseView<Content>>,
                                                   NavigationBarStyled,
                                                   TestTreeHolder,
                                                   DefaultViewProvider {
    // MARK: - UIViewController Overrides
    public override var shouldAutorotate: Bool { shouldAutorotateValue ?? super.shouldAutorotate }
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
    /** The value to be returned by the `shouldAutorotate` property. Nil reverts to the default behaviour of the UIViewController regarding that property. */
    public var shouldAutorotateValue: Bool?
    /** The value to be returned by the `supportedInterfaceOrientations` property. Nil reverts to the default behaviour of the UIViewController regarding that property. */
    public var supportedInterfaceOrientationsValue: UIInterfaceOrientationMask?
    /** This block can be used to add custom logic to decide what to return from the `preferredStatusBarStyle` property. */
    public var preferredStatusBarStyleOverride: ((UIViewController) -> UIStatusBarStyle)?

    // MARK: - Public Properties
    public var navigationBarStyle = UINavigationBar.Style.color(nil) // not applied until changed
    public var defaultViewRoute: String? {
        didSet {
            showDefaultDetailViewIfNeeded()
        }
    }

    // MARK: - Private Variables
    var testTree: TestTree?
    private var screenViewTracker: ScreenViewTrackerLive?

    public init(_ rootView: Content, customization: ((UIViewController) -> Void)? = nil) {
        let ref = WeakViewController()
        super.init(rootView: CoreHostingBaseView(content: rootView, controller: ref))
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

    public override func viewDidLoad() {
        super.viewDidLoad()
        isOpenDownloadsView()
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

    deinit {
        isClosedDownloadsView()
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

extension CoreHostingController: DownloadsProgressBarHidden {
    func isOpenDownloadsView() {
        if rootView is CoreHostingBaseView<DownloadsView> {
            debugLog("isDownloadsView = opened")
            NotificationCenter.default.post(name: .DownloadContentOpened, object: nil)
            toggleDownloadingBarView(hidden: true)
        }
    }

    func isClosedDownloadsView() {
        if rootView is CoreHostingBaseView<DownloadsView> {
            debugLog("isDownloadsView = closed")
            NotificationCenter.default.post(name: .DownloadContentClosed, object: nil)
            toggleDownloadingBarView(hidden: false)
        }
    }
}
