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

let HelmCanBecomeMaster = "canBecomeMaster"
let HelmPrefersModalPresentation = "prefersModalPresentation"
typealias HelmPreActionHandler = (HelmViewController) -> Void

public struct HelmViewControllerFactory {
    public typealias Props = [String: Any]
    public typealias Builder = (Props) -> UIViewController?
    
    public let builder: Builder
    
    public init(builder: @escaping Builder) {
        self.builder = builder
    }
}

public protocol HelmModule {
    var moduleName: String { get }
}

extension HelmViewController: HelmModule {}

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

    private var viewControllers = NSMapTable<NSString, HelmViewController>(keyOptions: .strongMemory, valueOptions: .weakMemory)
    @objc private(set) var defaultScreenConfiguration: [ModuleName: [String: Any]] = [:]
    @objc fileprivate(set) var masterModules = Set<ModuleName>()
    public var nativeViewControllerFactories: [ModuleName: HelmViewControllerFactory] = [:]
    public var registeredRoutes: Set<String> = []

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

    @objc open func reactWillReload() {
        // Clean up happens on log out for UI tests
        if uiTesting {
            onReactReload()
        } else {
            self.cleanup() { [weak self] in
                self?.onReactReload()
            }
        }
    }

    //  MARK: - Screen Configuration

    @objc open func registerNativeViewController(for moduleName: ModuleName, factory: @escaping HelmViewControllerFactory.Builder) {
        nativeViewControllerFactories[moduleName] = HelmViewControllerFactory(builder: factory)
    }

    func register<T: HelmViewController>(screen: T) {
        viewControllers.setObject(screen, forKey: screen.screenInstanceID as NSString)
    }

    @objc open func registerRoute(_ template: String) {
        registeredRoutes.insert(template)
    }

    @objc open func setScreenConfig(_ config: [String: Any], forScreenWithID screenInstanceID: String, hasRendered: Bool) {
        if let vc = viewControllers.object(forKey: screenInstanceID as NSString) {
            vc.screenConfig = HelmScreenConfig(config: config)
            vc.screenConfigRendered = hasRendered

            // Only handle the styles if the view is visible, so it doesn't happen a bunch of times
            if (vc.isVisible) {
                vc.handleStyles()
            }
        }
    }

    @objc open func setDefaultScreenConfig(_ config: [String: Any], forModule module: ModuleName) {
        defaultScreenConfiguration[module] = config
    }

    //  MARK: - Navigation

    @objc public func openInSafariViewController(_ url : URL, completion: @escaping () -> Void) {
        guard let topViewController = topMostViewController() else { return completion() }
        let safari = SFSafariViewController(url: url)
        safari.transitioningDelegate = ResetTransitionDelegate.shared
        topViewController.present(safari, animated: true, completion: completion)
    }

    @objc public func pushFrom(_ sourceModule: ModuleName, destinationModule: ModuleName, withProps props: [String: Any], options: [String: Any], callback: (() -> Void)? = nil) {
        guard let topViewController = topMostViewController() else { return }

        let viewController: UIViewController
        let pushOntoNav: (UINavigationController) -> Void
        let replaceInNav: (UINavigationController) -> Void
        let pushToReplace = options["replace"] as? Bool ?? false
        let detail = options["detail"] as? Bool == true

        // The views need to know when they are shown modaly and potentially other options
        // Doing it here instead of in JS so that native routing will also work
        var propsFRD = props
        propsFRD[PropKeys.navigatorOptions] = options

        if let factory = nativeViewControllerFactories[destinationModule]?.builder {
            guard let vc = factory(propsFRD) else { return }
            viewController = vc

            if pushToReplace {
                pushOntoNav = { nav in
                    var stack = nav.viewControllers
                    stack[max(stack.count - 1, 0)] = viewController
                    nav.viewControllers = stack
                    nav.navigationBar.isTranslucent = false
                }
            } else {
                pushOntoNav = { nav in
                    nav.pushViewController(viewController, animated: true)
                    nav.navigationBar.isTranslucent = false
                }
            }
            replaceInNav = { nav in
                nav.viewControllers = [viewController]
                nav.navigationBar.isTranslucent = false
            }
        } else {
            let helmViewController = HelmViewController(moduleName: destinationModule, props: propsFRD)
            viewController = helmViewController
            viewController.edgesForExtendedLayout = [.left, .right]

            pushOntoNav = { nav in
                helmViewController.loadViewIfNeeded()
                if pushToReplace {
                    helmViewController.onReadyToPresent = { [weak nav, helmViewController] in
                        guard let nav = nav else { return }
                        var stack = nav.viewControllers
                        stack[max(stack.count - 1, 0)] = helmViewController
                        nav.setViewControllers(stack, animated: false)
                    }
                } else {
                    helmViewController.onReadyToPresent = { [weak nav, helmViewController] in
                        nav?.pushViewController(helmViewController, animated: options["animated"] as? Bool ?? true)
                    }
                }
            }

            replaceInNav = { nav in
                helmViewController.loadViewIfNeeded()
                helmViewController.onReadyToPresent = { [weak nav, helmViewController] in
                    nav?.setViewControllers([helmViewController], animated: false)
                }
            }
        }

        if let splitViewController = topViewController as? HelmSplitViewController {
            let canBecomeMaster = options["canBecomeMaster"] as? Bool ?? false
            if canBecomeMaster {
                masterModules.insert(destinationModule)
            }
            
            // Determine whether a view controller should be pushed on the current nav controller
            // or be set as the root and only view controller.
            // We also have to figure out if an expand/collapse button is to be shown so that a detail view can occupy
            // the entire screen.
            if let nav = navigationControllerForSplitViewControllerPush(splitViewController: splitViewController, sourceModule: sourceModule, destinationModule: destinationModule, props: propsFRD, options: options) {
                
                // Check to see if a view controller can show the expand/collapse menu item
                // We only want to show it if a view can't become the master and both the master and detail view controllers are set/visible
                // This button will show to the right of the Back button if the Back button is visible
                let sideBySideViews = splitViewController.viewControllers.count > 1
                let viewCanExpandCollapse = !canBecomeMaster && sideBySideViews
                if (viewCanExpandCollapse) {
                    viewController.navigationItem.leftBarButtonItem = splitViewController.prettyDisplayModeButtonItem(splitViewController.displayMode)
                    viewController.navigationItem.leftItemsSupplementBackButton = true
                    let backButton = UIBarButtonItem(title: NSLocalizedString("Back", comment: ""), style: .plain, target: nil, action: nil)
                    backButton.accessibilityLabel = NSLocalizedString("Back on detailed view", comment: "")
                    viewController.navigationItem.backBarButtonItem = backButton
                }
                
                // Check to see if the master view is the one pushing this view controller onto the detail view.
                // If this condition is true, we will replace the details nav stack below and make it the starting
                // view controller of the detail nav stack.
                let sourceViewController = splitViewController.sourceController(moduleName: sourceModule)
                let clickedFromMaster = splitViewController.masterTopViewController == sourceViewController
                
                // When the all courses list is displayed as the master, an EmptyViewController is shown on the detail.
                // We check for this state and use it when deciding whether to push onto or replace the nav stack.
                // This isn't really necessary per se, but it is strange UI to have a Back button in the detail nav that
                // takes you back to an empty state view controller
                var onlyDetailVCWasEmptyVC = false
                if !canBecomeMaster,
                    !clickedFromMaster,
                    sideBySideViews,
                    let detailNav = splitViewController.detailNavigationController,
                    detailNav.viewControllers.count == 1,
                    detailNav.viewControllers[0] is EmptyViewController
                {
                    onlyDetailVCWasEmptyVC = true
                }
                
                // Determine whether we replace the nav stack or push onto it using the checks above.
                // Resetting or replacing the nav stack just means we set the new view controller as the only
                // view controller on that nav stack. The Back button will not be shown after a replaceInNav call
                // because there is no other view controller to navigate back to. pushOnToNav will be called if
                // a VC can be master or this navigation event was initiated from a non-empty detail view. A Back
                // button will be shown after pushOnToNav is called...as long as the nav.viewControllers.count > 1.
                let resetDetailNavStack = sideBySideViews && !canBecomeMaster && (clickedFromMaster || onlyDetailVCWasEmptyVC || detail)
                if (resetDetailNavStack) {
                    replaceInNav(nav)
                    callback?()
                } else {
                    pushOntoNav(nav)
                    callback?()
                }

                return
            }
        }

        if let navigationController = topViewController.navigationController {
            pushOntoNav(navigationController)
            callback?()
        }
        else if let split = topViewController as? UISplitViewController, let navigationController = split.masterNavigationController {
            pushOntoNav(navigationController)
            callback?()
        }
            //  This is a hack to fix coming from native assignment detail
            //  navigating to a child group discussion
            //  As more code moves to RN this will probably lose it's need here,
        else if let replace = options["replace"] as? Bool, replace,
            let svc = topMostViewController() as? HelmSplitViewController,
            let nav = svc.viewControllers.last as? UINavigationController,
            let helmViewController = viewController as? HelmViewController {
                var viewControllers = nav.viewControllers
                viewControllers.removeLast()
                viewControllers.append(helmViewController)
                nav.setViewControllers(viewControllers, animated: false)
                helmViewController.loadViewIfNeeded()
                helmViewController.onReadyToPresent = {}
                callback?()
        }
        else {
            assertionFailure("\(#function) invalid controller: \(topViewController)")
        }
    }

    @objc open func popFrom(_ sourceModule: ModuleName, callback: (() -> Void)? = nil) {
        guard let topViewController = topMostViewController() else {
            callback?()
            return
        }

        var nav: UINavigationController? = nil
        var replaceWithEmpty = false
        if let splitViewController = topViewController as? HelmSplitViewController {
            let sourceViewController = splitViewController.sourceController(moduleName: sourceModule)
            if sourceViewController == splitViewController.detailTopViewController {
                nav = splitViewController.detailNavigationController
                replaceWithEmpty = (nav?.viewControllers.count ?? 1) <= 1
            }
            else if sourceViewController == splitViewController.masterTopViewController {
                nav = splitViewController.masterNavigationController
            }
        } else if let navigationController = topViewController.navigationController {
            nav = navigationController
        } else {
            assertionFailure("\(#function) invalid controller: \(topViewController)")
            return
        }
        if replaceWithEmpty {
            nav?.viewControllers = [EmptyViewController(nibName: nil, bundle: nil)]
        } else {
            nav?.popViewController(animated: true)
        }
        callback?()
    }

    @objc public func present(_ module: ModuleName, withProps props: [String: Any], options: [String: Any], callback: (() -> Void)? = nil) {
        guard let current = topMostViewController() else {
            callback?()
            return
        }

        func configureModalProps(for viewController: UIViewController) {
            if let modalPresentationStyle = options[PropKeys.modalPresentationStyle] as? String {
                switch modalPresentationStyle {
                case "fullscreen": viewController.modalPresentationStyle = .fullScreen
                case "pagesheet": viewController.modalPresentationStyle = .pageSheet
                case "formsheet": viewController.modalPresentationStyle = .formSheet
                case "currentContext": viewController.modalPresentationStyle = .currentContext
                case "overCurrentContext": viewController.modalPresentationStyle = .overCurrentContext
                case "drawer":
                    viewController.modalPresentationStyle = .custom
                    viewController.transitioningDelegate = SideMenuTransitioningDelegate.shared
                default: viewController.modalPresentationStyle = .fullScreen
                }
            }

            if let modalTransitionStyle = options[PropKeys.modalTransitionStyle] as? String {
                switch modalTransitionStyle {
                case "flip": viewController.modalTransitionStyle = .flipHorizontal
                case "fade": viewController.modalTransitionStyle = .crossDissolve
                case "curl": viewController.modalTransitionStyle = .partialCurl
                default: viewController.modalTransitionStyle = .coverVertical
                }
            }
        }

        // The views need to know when they are shown modaly and potentially other options
        // Doing it here instead of in JS so that native routing will also work
        var propsFRD = props
        propsFRD[PropKeys.navigatorOptions] = options

        if let factory = nativeViewControllerFactories[module] {
            let builder = factory.builder
            guard let viewController = builder(propsFRD) else {
                callback?()
                return
            }

            var toPresent: UIViewController = viewController
            let nav = toPresent as? UINavigationController
            if let embedInNavigationController = options["embedInNavigationController"] as? Bool,
                embedInNavigationController,
                nav == nil {
                toPresent = HelmNavigationController(rootViewController: viewController)
                viewController.navigationController?.navigationBar.useModalStyle()
            }

            configureModalProps(for: toPresent)
            if options[PropKeys.disableDismissOnSwipe] as? Bool == true {
                toPresent.presentationController?.delegate = self
            }
            current.present(toPresent, animated: options["animated"] as? Bool ?? true, completion: {
                viewController.addModalDismissButton(buttonTitle: nil)
                callback?()
            })
        } else {
            var toPresent: UIViewController
            var helmVC: HelmViewController

            let vc = HelmViewController(moduleName: module, props: propsFRD)
            toPresent = vc
            helmVC = vc
            if let embedInNavigationController: Bool = options["embedInNavigationController"] as? Bool, embedInNavigationController {
                toPresent = HelmNavigationController(rootViewController: vc)
                vc.navigationController?.navigationBar.useModalStyle()
                if let disableSwipeDownToDismissModal: Bool = options[PropKeys.disableDismissOnSwipe] as? Bool,
                    disableSwipeDownToDismissModal,
                    vc.modalPresentationStyle == .formSheet || vc.modalPresentationStyle == .pageSheet
                {
                    toPresent.presentationController?.delegate = self
                }

            }

            configureModalProps(for: toPresent)

            helmVC.loadViewIfNeeded()
            helmVC.onReadyToPresent = { [weak current, toPresent] in
                current?.present(toPresent, animated: options["animated"] as? Bool ?? true, completion: callback)
            }
        }
    }

    @objc open func dismiss(_ options: [String: Any], callback: (() -> Void)? = nil) {
        // TODO: maybe not always dismiss the top - UIKit allows dismissing things not the top, dismisses all above
        guard let vc = topMostViewController() else { return }
        let animated = options["animated"] as? Bool ?? true
        vc.dismiss(animated: animated, completion: callback)
    }

    @objc open func dismissAllModals(_ options: [String: Any], callback: (() -> Void)? = nil) {
        // TODO: maybe not always dismiss the top - UIKit allows dismissing things not the top, dismisses all above
        guard let vc = AppEnvironment.shared.window?.rootViewController, vc.presentedViewController != nil else {
            callback?()
            return
        }
        
        let animated = options["animated"] as? Bool ?? true
        vc.dismiss(animated: animated, completion: callback)
    }

    @objc public func traitCollection(_ moduleName: String, callback: @escaping RCTResponseSenderBlock) {
        let result = [ "window": WindowTraits.current() ]
        callback([result])
    }
    
    @objc public func cleanup(callback: (() -> Void)?) {
        dismissAllModals(["animated": false]) { [weak self] in
            // Cleanup is mainly used in rn reload situations or in ui testing
            // There is a bug where the view controllers are sometimes leaked, and I cannot for the life of me figure out why
            // This prevents weird rn behavior in cases where those leaks occur
            let enumerator = self?.viewControllers.objectEnumerator()
            while let object = enumerator?.nextObject() {
                guard let vc = object as? HelmViewController else { continue }
                vc.view = UIView() // nil causes `loadView` to be called again during the dismiss process
            }
            self?.viewControllers.removeAllObjects()
            callback?()
        }
    }

    public func routeHandlers(_ routeMap: KeyValuePairs<String, RouteHandler.ViewFactory?>) -> [RouteHandler] {
        var routes: [RouteHandler] = []
        for (template, handler) in routeMap {
            if let factory = handler {
                let route = RouteHandler(template, factory: factory)
                registerNativeViewController(for: template, factory: { props in
                    guard
                        let location = props["location"] as? [String: Any],
                        let url = (location["href"] as? String).flatMap(URLComponents.parse),
                        let params = route.match(url)
                    else { return nil }
                    return route.factory(url, params, props)
                })
                routes.append(route)
            } else {
                routes.append(RouteHandler(template) { url, params, userInfo in
                    return HelmViewController(moduleName: template, url: url, params: params, userInfo: userInfo)
                })
            }
        }
        return routes
    }
}

extension HelmManager {
    @objc func navigationControllerForSplitViewControllerPush(splitViewController: HelmSplitViewController?, sourceModule: ModuleName, destinationModule: ModuleName, props: [String: Any], options: [String: Any]) -> UINavigationController? {
        let canBecomeMaster = options["canBecomeMaster"] as? Bool == true
        if canBecomeMaster, let masterNav = splitViewController?.masterNavigationController {
            return masterNav
        } else if (splitViewController?.detailTopViewController as? HelmModule)?.moduleName == sourceModule {
            return splitViewController?.detailNavigationController
        } else {
            if (splitViewController?.traitCollection.horizontalSizeClass ?? UIUserInterfaceSizeClass.compact) == UIUserInterfaceSizeClass.compact {
                return splitViewController?.masterNavigationController
            }

            let isDeepLink = options["deepLink"] as? Bool ?? false
            if (splitViewController?.detailNavigationController == nil && !isDeepLink) {
                splitViewController?.showDetailViewController(HelmNavigationController(), sender: nil)
            }

            return splitViewController?.detailNavigationController
        }
    }
}

extension HelmManager {
    @objc open func topMostViewController() -> UIViewController? {
        return AppEnvironment.shared.window?.rootViewController?.topMostViewController()
    }

    @objc open func topNavigationController() -> UINavigationController? {
        return topMostViewController()?.navigationController
    }

    @objc open func topTabBarController() -> UITabBarController? {
        return topMostViewController()?.tabBarController
    }
}

extension UIViewController {
    @objc func topMostViewController() -> UIViewController? {
        if let presented = presentedViewController {
            return presented.topMostViewController()
        } else if let tabBarSelected = (self as? UITabBarController)?.selectedViewController {
            return tabBarSelected.topMostViewController()
        } else if let navVisible = (self as? UINavigationController)?.visibleViewController {
            return navVisible.topMostViewController()
        } else {
            return self
        }
    }
}

extension HelmManager: UIAdaptivePresentationControllerDelegate {
    public func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        return false
    }
}
