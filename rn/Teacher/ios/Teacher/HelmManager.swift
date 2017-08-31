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


public typealias ModuleName = String

let HelmCanBecomeMaster = "canBecomeMaster"
let HelmPrefersModalPresentation = "prefersModalPresentation"
typealias HelmPreActionHandler = (HelmViewController) -> Void

@objc(HelmManager)
open class HelmManager: NSObject {
    static let shared = HelmManager()
    static var branding: Brand?
    open var bridge: RCTBridge!
    open var rootViewController: UIViewController?
    private var viewControllers = NSMapTable<NSString, HelmViewController>(keyOptions: .strongMemory, valueOptions: .weakMemory)
    private(set) var defaultScreenConfiguration: [ModuleName: [String: Any]] = [:]
    fileprivate(set) var masterModules = Set<ModuleName>()
    
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
        self.showLoadingState()
    }

    //  MARK: - Screen Configuration

    func register<T: HelmViewController>(screen: T) where T: HelmScreen {
        Helm.shared.viewControllers.setObject(screen, forKey: screen.screenInstanceID as NSString)
    }
    
    open func setScreenConfig(_ config: [String: Any], forScreenWithID screenInstanceID: String, hasRendered: Bool) {
        if let vc = Helm.shared.viewControllers.object(forKey: screenInstanceID as NSString) {
            vc.screenConfig = config
            vc.screenConfigRendered = hasRendered
            
            // Only handle the styles if the view is visible, so it doesn't happen a bunch of times
            if (vc.isVisible) {
                vc.handleStyles()
            }
        }
    }
    
    open func setDefaultScreenConfig(_ config: [String: Any], forModule module: ModuleName) {
        Helm.shared.defaultScreenConfiguration[module] = config
    }

    //  MARK: - Navigation
    
    public func pushFrom(_ sourceModule: ModuleName, destinationModule: ModuleName, withProps props: [String: Any], options: [String: Any]) {
        guard let topViewController = type(of: self).shared.topMostViewController() else { return }

        let viewController = HelmViewController(moduleName: destinationModule, props: props)
        viewController.edgesForExtendedLayout = [.left, .right]
        
        func push(helmViewController: HelmViewController, onto nav: UINavigationController) {
            helmViewController.loadViewIfNeeded()
            helmViewController.onReadyToPresent = { [weak nav, helmViewController] in
                nav?.pushViewController(helmViewController, animated: options["animated"] as? Bool ?? true)
            }
        }
        
        func replace(helmViewController: HelmViewController, in nav: UINavigationController) {
            helmViewController.loadViewIfNeeded()
            helmViewController.onReadyToPresent = { [weak nav, helmViewController] in
                nav?.setViewControllers([helmViewController], animated: false)
            }
        }

        if let splitViewController = topViewController as? UISplitViewController {
            let canBecomeMaster = (options["canBecomeMaster"] as? NSNumber)?.boolValue ?? false
            if canBecomeMaster {
                Helm.shared.masterModules.insert(destinationModule)
            }
            
            let sourceViewController = splitViewController.sourceController(moduleName: sourceModule)
            let resetDetailNavStackIfClickedFromMaster = splitViewController.masterTopViewController == sourceViewController
            
            if let nav = self.navigationControllerForSplitViewControllerPush(splitViewController: splitViewController, sourceModule: sourceModule, destinationModule: destinationModule, props: props, options: options) {
                if (resetDetailNavStackIfClickedFromMaster && !canBecomeMaster && splitViewController.viewControllers.count > 1) {
                    viewController.navigationItem.leftBarButtonItem = splitViewController.prettyDisplayModeButtonItem
                    viewController.navigationItem.leftItemsSupplementBackButton = true
                    replace(helmViewController: viewController, in: nav)
                } else {
                    push(helmViewController: viewController, onto: nav)
                }
            }
        } else if let navigationController = topViewController.navigationController {
            push(helmViewController: viewController, onto: navigationController)
        } else {
            assertionFailure("\(#function) invalid controller: \(topViewController)")
            return
        }
    }

    open func popFrom(_ sourceModule: ModuleName) {
        guard let topViewController = type(of: self).shared.topMostViewController() else { return }
        
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
        guard let current = type(of: self).shared.topMostViewController() else {
            return
        }
        
        func configureModalProps(for viewController: UIViewController) {
            if let modalPresentationStyle = options["modalPresentationStyle"] as? String {
                switch modalPresentationStyle {
                case "fullscreen": viewController.modalPresentationStyle = .fullScreen
                case "formsheet": viewController.modalPresentationStyle = .formSheet
                case "currentContext": viewController.modalPresentationStyle = .currentContext
                default: viewController.modalPresentationStyle = .fullScreen
                }
            }
            
            if let modalTransitionStyle = options["modalTransitionStyle"] as? String {
                switch modalTransitionStyle {
                case "flip": viewController.modalTransitionStyle = .flipHorizontal
                case "fade": viewController.modalTransitionStyle = .crossDissolve
                case "curl": viewController.modalTransitionStyle = .partialCurl
                case "push":
                    viewController.transitioningDelegate = Helm.shared.pushTransitioningDelegate
                default: viewController.modalTransitionStyle = .coverVertical
                }
            }
        }
        
        var toPresent: UIViewController
        var helmVC: HelmViewController
        if let canBecomeMaster = (options["canBecomeMaster"] as? NSNumber)?.boolValue, canBecomeMaster {
            let split = HelmSplitViewController()
            let master = HelmViewController(moduleName: module, props: props)
            helmVC = master
            
            // TODO: making some possibly incorredct assumptions here that every time we want both master and detail in a nav controller. Works now, but may need to change
            let emptyNav = HelmNavigationController(rootViewController: EmptyViewController())

            split.preferredDisplayMode = .allVisible
            split.viewControllers = [HelmNavigationController(rootViewController: master), emptyNav]
            
            if (options["modalPresentationStyle"] as? String) == "currentContext" {
                let wrapper = HelmSplitViewControllerWrapper()
                wrapper.addChildViewController(split)
                wrapper.view.addSubview(split.view)
                split.didMove(toParentViewController: wrapper)
                configureModalProps(for: wrapper)
                toPresent = wrapper
                wrapper.modalPresentationCapturesStatusBarAppearance = true
            } else {
                configureModalProps(for: split)
                toPresent = split
            }
        } else {
            let vc = HelmViewController(moduleName: module, props: props)
            toPresent = vc
            helmVC = vc
            if let embedInNavigationController: Bool = options["embedInNavigationController"] as? Bool, embedInNavigationController {
                toPresent = UINavigationController(rootViewController: vc)
            }
            
            configureModalProps(for: toPresent)
        }

        helmVC.loadViewIfNeeded()
        helmVC.onReadyToPresent = { [weak current, toPresent] in
            current?.present(toPresent, animated: options["animated"] as? Bool ?? true, completion: nil)
        }
    }

    open func dismiss(_ options: [String: Any]) {
        // TODO: maybe not always dismiss the top - UIKit allows dismissing things not the top, dismisses all above
        guard let vc = type(of: self).shared.topMostViewController() else { return }
        let animated = options["animated"] as? Bool ?? true
        vc.dismiss(animated: animated, completion: nil)
    }
    
    open func dismissAllModals(_ options: [String: Any]) {
        // TODO: maybe not always dismiss the top - UIKit allows dismissing things not the top, dismisses all above
        guard let vc = type(of: self).shared.topMostViewController() else { return }
        let animated = options["animated"] as? Bool ?? true
        vc.dismiss(animated: animated, completion: {
            self.dismiss(options)
        })
    }
    
    func traitCollection(_ screenInstanceID: String, moduleName: String, callback: @escaping RCTResponseSenderBlock) {
        var top = type(of: self).shared.topMostViewController()
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
    
    func methodQueue() -> DispatchQueue {
        return .main
    }
    
    open func initLoadingStateIfRequired() {
        
        if let _ = UIApplication.shared.keyWindow?.rootViewController as? CKMDomainPickerViewController {
            return
        }
        
        self.showLoadingState()
    }
    
    open func initTabs() {
        let tabs = RootTabBarController(branding: Helm.branding)
        Helm.shared.rootViewController = tabs
        UIApplication.shared.keyWindow?.rootViewController = tabs
    }
    
    open func showLoadingState() {
        let controller = LoadingStateViewController()
        Helm.shared.rootViewController = controller
        UIApplication.shared.keyWindow?.rootViewController = controller
    }
}

extension Helm {
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

extension Helm {
    open func topMostViewController() -> UIViewController? {
        return rootViewController?.topMostViewController()
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
        if let presented = self.presentedViewController {
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

