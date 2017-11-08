//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import UIKit
import CanvasKeymaster
import React

public typealias ModuleName = String

let HelmCanBecomeMaster = "canBecomeMaster"
let HelmPrefersModalPresentation = "prefersModalPresentation"
typealias HelmPreActionHandler = (HelmViewController) -> Void

@objc(HelmManager)
open class HelmManager: NSObject {

    public static let shared = HelmManager()
    public var bridge: RCTBridge!
    public var showsLoadingState = true
    public var onReactLoginComplete: () -> Void = {}
    
    @objc
    public func loginComplete() {
        onReactLoginComplete()
    }

    private var viewControllers = NSMapTable<NSString, HelmViewController>(keyOptions: .strongMemory, valueOptions: .weakMemory)
    private(set) var defaultScreenConfiguration: [ModuleName: [String: Any]] = [:]
    fileprivate(set) var masterModules = Set<ModuleName>()
    private var nativeViewControllerFactories: [ModuleName: (factory: ([String: Any])->UIViewController?, customPresentation: ((_ current: UIViewController, _ new: UIViewController)->())?)] = [:]
    
    fileprivate var pushTransitioningDelegate = PushTransitioningDelegate()

    //  MARK: - Init

    override init() {
        super.init()
        setupNotifications()
    }

    func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(reactWillReload), name: Notification.Name("RCTJavaScriptWillStartLoadingNotification"), object: nil)
    }

    open func reactWillReload() {
        showLoadingState()
    }

    //  MARK: - Screen Configuration
    
    open func registerNativeViewController(for moduleName: ModuleName, factory: @escaping ([String: Any]) -> UIViewController?, withCustomPresentation presentation: ((_ current: UIViewController, _ new: UIViewController)->())? = nil) {
        nativeViewControllerFactories[moduleName] = (factory, presentation)
    }

    func register<T: HelmViewController>(screen: T) {
        viewControllers.setObject(screen, forKey: screen.screenInstanceID as NSString)
    }
    
    open func setScreenConfig(_ config: [String: Any], forScreenWithID screenInstanceID: String, hasRendered: Bool) {
        if let vc = viewControllers.object(forKey: screenInstanceID as NSString) {
            vc.screenConfig = config
            vc.screenConfigRendered = hasRendered
            
            // Only handle the styles if the view is visible, so it doesn't happen a bunch of times
            if (vc.isVisible) {
                vc.handleStyles()
            }
        }
    }
    
    open func setDefaultScreenConfig(_ config: [String: Any], forModule module: ModuleName) {
        defaultScreenConfiguration[module] = config
    }

    //  MARK: - Navigation
    
    public func pushFrom(_ sourceModule: ModuleName, destinationModule: ModuleName, withProps props: [String: Any], options: [String: Any]) {
        guard let topViewController = topMostViewController() else { return }
        
        let viewController: UIViewController
        let pushOntoNav: (UINavigationController) -> Void
        let replaceInNav: (UINavigationController) -> Void
        
        if let factory = nativeViewControllerFactories[destinationModule]?.factory {
            guard let vc = factory(props) else { return }
            viewController = vc
            
            pushOntoNav = { nav in
                nav.pushViewController(viewController, animated: true)
            }
            replaceInNav = { nav in
                nav.viewControllers = [viewController]
            }
        } else {
            let helmViewController = HelmViewController(moduleName: destinationModule, props: props)
            viewController = helmViewController
            viewController.edgesForExtendedLayout = [.left, .right]
            
            pushOntoNav = { nav in
                helmViewController.loadViewIfNeeded()
                helmViewController.onReadyToPresent = { [weak nav, helmViewController] in
                    nav?.pushViewController(helmViewController, animated: options["animated"] as? Bool ?? true)
                }
            }
            
            replaceInNav = { nav in
                helmViewController.loadViewIfNeeded()
                helmViewController.onReadyToPresent = { [weak nav, helmViewController] in
                    nav?.setViewControllers([helmViewController], animated: false)
                }
            }
        }
        
        if let splitViewController = topViewController as? UISplitViewController {
            let canBecomeMaster = (options["canBecomeMaster"] as? NSNumber)?.boolValue ?? false
            if canBecomeMaster {
                masterModules.insert(destinationModule)
            }
            
            let sourceViewController = splitViewController.sourceController(moduleName: sourceModule)
            let resetDetailNavStackIfClickedFromMaster = splitViewController.masterTopViewController == sourceViewController
            
            if let nav = navigationControllerForSplitViewControllerPush(splitViewController: splitViewController, sourceModule: sourceModule, destinationModule: destinationModule, props: props, options: options) {
                if (resetDetailNavStackIfClickedFromMaster && !canBecomeMaster && splitViewController.viewControllers.count > 1) {
                    viewController.navigationItem.leftBarButtonItem = splitViewController.prettyDisplayModeButtonItem
                    viewController.navigationItem.leftItemsSupplementBackButton = true
                    replaceInNav(nav)
                } else {
                    pushOntoNav(nav)
                }
            }
        } else if let navigationController = topViewController.navigationController {
            pushOntoNav(navigationController)
        } else {
            assertionFailure("\(#function) invalid controller: \(topViewController)")
            return
        }
    }

    open func popFrom(_ sourceModule: ModuleName) {
        guard let topViewController = topMostViewController() else { return }
        
        var nav: UINavigationController? = nil
        if let splitViewController = topViewController as? UISplitViewController {
            let sourceViewController = splitViewController.sourceController(moduleName: sourceModule)
            if sourceViewController == splitViewController.detailTopViewController {
                nav = splitViewController.detailNavigationController
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
        nav?.popViewController(animated: true)
    }
    
    public func present(_ module: ModuleName, withProps props: [String: Any], options: [String: Any]) {
        guard let current = topMostViewController() else {
            return
        }
        
        func configureModalProps(for viewController: UIViewController) {
            if let modalPresentationStyle = options["modalPresentationStyle"] as? String {
                switch modalPresentationStyle {
                case "fullscreen": viewController.modalPresentationStyle = .fullScreen
                case "formsheet": viewController.modalPresentationStyle = .formSheet
                case "currentContext": viewController.modalPresentationStyle = .currentContext
                case "overCurrentContext": viewController.modalPresentationStyle = .overCurrentContext
                default: viewController.modalPresentationStyle = .fullScreen
                }
            }
            
            if let modalTransitionStyle = options["modalTransitionStyle"] as? String {
                switch modalTransitionStyle {
                case "flip": viewController.modalTransitionStyle = .flipHorizontal
                case "fade": viewController.modalTransitionStyle = .crossDissolve
                case "curl": viewController.modalTransitionStyle = .partialCurl
                default: viewController.modalTransitionStyle = .coverVertical
                }
            }
        }
        
        if let stuff = nativeViewControllerFactories[module] {
            let factory = stuff.factory
            guard let viewController = factory(props) else { return }
            
            var toPresent: UIViewController = viewController
            if let embedInNavigationController: Bool = options["embedInNavigationController"] as? Bool, embedInNavigationController, stuff.customPresentation == nil {
                toPresent = HelmNavigationController(rootViewController: viewController)
            }
            
            configureModalProps(for: toPresent)
            
            if let customPresentation = stuff.customPresentation {
                customPresentation(current, viewController)
            } else {
                current.present(viewController, animated: options["animated"] as? Bool ?? true, completion: nil)
            }
        } else {
            var toPresent: UIViewController
            var helmVC: HelmViewController
            
            let vc = HelmViewController(moduleName: module, props: props)
            toPresent = vc
            helmVC = vc
            if let embedInNavigationController: Bool = options["embedInNavigationController"] as? Bool, embedInNavigationController {
                toPresent = HelmNavigationController(rootViewController: vc)
            }
            
            configureModalProps(for: toPresent)
            
            helmVC.loadViewIfNeeded()
            helmVC.onReadyToPresent = { [weak current, toPresent] in
                current?.present(toPresent, animated: options["animated"] as? Bool ?? true, completion: nil)
            }
        }
    }

    open func dismiss(_ options: [String: Any], callback: RCTResponseSenderBlock? = nil) {
        // TODO: maybe not always dismiss the top - UIKit allows dismissing things not the top, dismisses all above
        guard let vc = topMostViewController() else { return }
        let animated = options["animated"] as? Bool ?? true
        vc.dismiss(animated: animated) {
            callback?([])
        }
    }
    
    open func dismissAllModals(_ options: [String: Any]) {
        // TODO: maybe not always dismiss the top - UIKit allows dismissing things not the top, dismisses all above
        guard let vc = topMostViewController() else { return }
        let animated = options["animated"] as? Bool ?? true
        vc.dismiss(animated: animated, completion: {
            self.dismiss(options)
        })
    }
    
    public func traitCollection(_ screenInstanceID: String, moduleName: String, callback: @escaping RCTResponseSenderBlock) {
        var top = topMostViewController()
        //  FIXME: - fix sourceController method, something named more appropriate
        if let svc = top as? HelmSplitViewController, let sourceController = svc.sourceController(moduleName: moduleName) {
            top = sourceController
        }
        
        let screenSizeClassInfo = top?.sizeClassInfoForJavascriptConsumption()
        let windowSizeClassInfo = UIApplication.shared.keyWindow?.sizeClassInfoForJavascriptConsumption()
        
        var result: [String: [String: String]] = [:]
        if let screenSizeClassInfo = screenSizeClassInfo {
            result["screen"] = screenSizeClassInfo
        }
        if let windowSizeClassInfo = windowSizeClassInfo {
            result["window"] = windowSizeClassInfo
        }
        
        callback([result])
    }
    
    open func initLoadingStateIfRequired() {
        
        if let _ = UIApplication.shared.keyWindow?.rootViewController as? CKMDomainPickerViewController {
            return
        }
        
        showLoadingState()
    }
    
    open func showLoadingState() {
        guard showsLoadingState == true else { return }
        if UIApplication.shared.keyWindow?.rootViewController is LoadingStateViewController { return }
        cleanup()
        let controller = LoadingStateViewController()
        UIApplication.shared.keyWindow?.rootViewController = controller
    }
    
    func cleanup() {
        
        // Cleanup is mainly used in rn reload situations or in ui testing
        // There is a bug where the view controllers are sometimes leaked, and I cannot for the life of me figure out why
        // This prevents weird rn behavior in cases where those leaks occur
        let enumerator = viewControllers.objectEnumerator()
        while let object = enumerator?.nextObject() {
            guard let vc = object as? HelmViewController else { continue }
            vc.view = nil
        }
        viewControllers.removeAllObjects()
        dismissAllModals(["animated": false])
        UIApplication.shared.keyWindow?.rootViewController = UIViewController()
    }
}

extension HelmManager {
    func navigationControllerForSplitViewControllerPush(splitViewController: UISplitViewController?, sourceModule: ModuleName, destinationModule: ModuleName, props: [String: Any], options: [String: Any]) -> HelmNavigationController? {

        if let detailViewController = splitViewController?.detailTopViewController, detailViewController.moduleName == sourceModule {
            return splitViewController?.detailNavigationController
        } else {
            let canBecomeMaster = (options["canBecomeMaster"] as? NSNumber)?.boolValue ?? false

            if canBecomeMaster || (splitViewController?.traitCollection.horizontalSizeClass ?? .compact) == .compact {
                return splitViewController?.masterNavigationController
            }
            
            if (splitViewController?.detailNavigationController == nil) {
                splitViewController?.primeEmptyDetailNavigationController()
            }
            
            return splitViewController?.detailNavigationController
        }
    }
}

extension HelmManager {
    open func topMostViewController() -> UIViewController? {
        return UIApplication.shared.keyWindow?.rootViewController?.topMostViewController()
    }

    open func topNavigationController() -> UINavigationController? {
        return topMostViewController()?.navigationController
    }

    open func topTabBarController() -> UITabBarController? {
        return topMostViewController()?.tabBarController
    }
}

extension UIViewController {
    func topMostViewController() -> UIViewController? {
        if let presented = presentedViewController {
            return presented.topMostViewController()
        } else if let tabBarSelected = (self as? UITabBarController)?.selectedViewController {
            return tabBarSelected.topMostViewController()
        } else if let navVisible = (self as? UINavigationController)?.visibleViewController {
            return navVisible.topMostViewController()
        } else if let wrapper = (self as? HelmSplitViewControllerWrapper) {
            return wrapper.childViewControllers.last?.topMostViewController()
        } else {
            return self
        }
    }
}

