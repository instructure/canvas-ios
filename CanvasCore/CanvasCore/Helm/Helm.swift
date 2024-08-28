//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
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
import SafariServices
import React
import Core

public typealias ModuleName = String

public struct HelmViewControllerFactory {
    public typealias Props = [String: Any]
    public typealias Builder = (Props) -> UIViewController?
}


@objc(HelmManager)
open class HelmManager: NSObject {

    @objc public static let shared = HelmManager()
    @objc public var bridge: RCTBridge!
    @objc public var onReactLoginComplete: () -> Void = {}
    @objc public var onReactReload: () -> Void = {}

    @objc
    public func loginComplete() {
        onReactLoginComplete()
    }

    //  MARK: - Init

    override init() {
        super.init()
        setupNotifications()
    }

    @objc func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(reactWillReload), name: Notification.Name("RCTJavaScriptWillStartLoadingNotification"), object: nil)
    }

    @objc open func reload() {
        RCTTriggerReloadCommandListeners("reload called")
    }

    @objc open func reactWillReload() {}

    //  MARK: - Screen Configuration

    @objc open func registerNativeViewController(for moduleName: ModuleName, factory: @escaping HelmViewControllerFactory.Builder) {}

    func register<T: UIViewController>(screen: T) {}

    @objc open func registerRoute(_ template: String) {}

    @objc open func setScreenConfig(_ config: [String: Any], forScreenWithID screenInstanceID: String, hasRendered: Bool) {}

    @objc open func setDefaultScreenConfig(_ config: [String: Any], forModule module: ModuleName) {}

    //  MARK: - Navigation

    @objc public func openInSafariViewController(_ url : URL, completion: @escaping () -> Void) {}

    @objc public func pushFrom(_ sourceModule: ModuleName, destinationModule: ModuleName, withProps props: [String: Any], options: [String: Any], callback: (() -> Void)? = nil) {}

    @objc open func popFrom(_ sourceModule: ModuleName, callback: (() -> Void)? = nil) {}

    @objc public func present(_ module: ModuleName, withProps props: [String: Any], options: [String: Any], callback: (() -> Void)? = nil) {}

    @objc open func dismiss(_ options: [String: Any], callback: (() -> Void)? = nil) {}

    @objc open func dismissAllModals(_ options: [String: Any], callback: (() -> Void)? = nil) {}

    @objc public func traitCollection(_ moduleName: String, callback: @escaping RCTResponseSenderBlock) {}
    
    @objc public func cleanup(callback: (() -> Void)?) {}

    public func routeHandlers(_ routeMap: KeyValuePairs<String, RouteHandler.ViewFactory?>) -> [RouteHandler] { [] }
}

extension HelmManager {
    @objc open func topMostViewController() -> UIViewController? {
        return AppEnvironment.shared.window?.rootViewController?.topMostViewController()
    }
}
