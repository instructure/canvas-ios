//
//  Helm.swift
//  Teacher
//
//  Created by Ben Kraus on 4/28/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import UIKit


public typealias ModuleName = String

let HelmCanBecomeMaster = "canBecomeMaster"
let HelmPrefersModalPresentation = "prefersModalPresentation"
typealias HelmPreActionHandler = (HelmViewController) -> Void

@objc(Helm)
open class Helm: NSObject {
    static let shared = Helm()

    open var bridge: RCTBridge!
    open var rootViewController: UIViewController?
    private var viewControllers = NSMapTable<NSString, HelmViewController>(keyOptions: .strongMemory, valueOptions: .weakMemory)
    private(set) var defaultScreenConfiguration: [ModuleName: [String: Any]] = [:]

    //  MARK: - Init

    override init() {
        super.init()
        setupNotifications()
    }

    func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(reactWillReload), name: Notification.Name("RCTJavaScriptWillStartLoadingNotification"), object: nil)
    }

    open func reactWillReload() {
        guard let topViewController = type(of: self).shared.topMostViewController() else { return }
        var nav: UINavigationController? = nil
        if let splitViewController = topViewController as? UISplitViewController {

            if let navigationController = splitViewController.detailNavigationController  {
                nav = navigationController
                nav?.popToRootViewController(animated: false)
                splitViewController.primeEmptyDetailNavigationController()
            }

            if let navigationController = splitViewController.masterNavigationController {
                nav = navigationController
                nav?.popToRootViewController(animated: false)
            }
        } else if let navigationController = topViewController.navigationController {
            nav = navigationController
        } else {
            assertionFailure("\(#function) invalid controller: \(topViewController)")
            return
        }
        nav?.popToRootViewController(animated: false)
        
        //  get rid of modals on ipad
        if let rootViewController = rootViewController {
            rootViewController.dismiss(animated: false, completion: nil)
        }
    }

    //  MARK: - Screen Configuration

    func register<T: HelmViewController>(screen: T) where T: HelmScreen {
        Helm.shared.viewControllers.setObject(screen, forKey: screen.screenInstanceID as NSString)
    }
    
    open func setScreenConfig(_ config: [String: Any], forScreenWithID screenInstanceID: String, hasRendered: Bool) {
        DispatchQueue.main.async {
            if let vc = Helm.shared.viewControllers.object(forKey: screenInstanceID as NSString) {
                vc.screenConfig = config
                vc.screenConfigRendered = hasRendered
                
                // Only handle the styles if the view is visible, so it doesn't happen a bunch of times
                if (vc.isVisible) {
                    vc.handleStyles()
                }
            }
        }
    }
    
    open func setDefaultScreenConfig(_ config: [String: Any], forModule module: ModuleName) {
        DispatchQueue.main.async {
            Helm.shared.defaultScreenConfiguration[module] = config
        }
    }

    //  MARK: - Navigation
    open func pushFrom(_ sourceModule: ModuleName, destinationModule: ModuleName, withProps props: [String: Any], options: [String: Any]) {
        pushFrom(sourceModule, destinationModule: destinationModule, withProps: props, options: options, handler: nil)
    }
    
    func pushFrom(_ sourceModule: ModuleName, destinationModule: ModuleName, withProps props: [String: Any], options: [String: Any], handler: HelmPreActionHandler?) {
        DispatchQueue.main.async {
            guard let topViewController = type(of: self).shared.topMostViewController() else { return }

            let viewController = HelmViewController(moduleName: destinationModule, props: props)
            viewController.edgesForExtendedLayout = [.left, .right]

            var nav: UINavigationController? = nil
            if let splitViewController = topViewController as? UISplitViewController {
                nav = self.navigationControllerForSplitViewControllerPush(splitViewController: splitViewController, sourceModule: sourceModule, destinationModule: destinationModule, props: props, options: options)
            } else if let navigationController = topViewController.navigationController {
                nav = navigationController
            } else {
                assertionFailure("\(#function) invalid controller: \(topViewController)")
                return
            }
            
            viewController.loadViewIfNeeded()
            viewController.onReadyToPresent = { [weak nav, viewController] in
                nav?.pushViewController(viewController, animated: options["animated"] as? Bool ?? true)
            }
            handler?(viewController)
        }
    }

    open func popFrom(_ sourceModule: ModuleName) {
        DispatchQueue.main.async {
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
    }

    public func present(_ module: ModuleName, withProps props: [String: Any], options: [String: Any]) {
        present(module, withProps: props, options: options, handler: nil)
    }
    
    func present(_ module: ModuleName, withProps props: [String: Any], options: [String: Any], handler: HelmPreActionHandler?) {
        DispatchQueue.main.async {
            guard let current = type(of: self).shared.topMostViewController() else {
                return
            }
            let vc = HelmViewController(moduleName: module, props: props)
            var toPresent: UIViewController = vc
            if let embedInNavigationController: Bool = options["embedInNavigationController"] as? Bool, embedInNavigationController {
                toPresent = UINavigationController(rootViewController: vc)
            }

            if let modalPresentationStyle = options["modalPresentationStyle"] as? String {
                switch modalPresentationStyle {
                    case "fullscreen": toPresent.modalPresentationStyle = .fullScreen
                    case "formsheet": toPresent.modalPresentationStyle = .formSheet
                    default: toPresent.modalPresentationStyle = .fullScreen
                }
            }

            vc.loadViewIfNeeded()
            vc.onReadyToPresent = { [weak current, toPresent] in
                current?.present(toPresent, animated: options["animated"] as? Bool ?? true, completion: nil)
            }
            handler?(vc)
        }
    }

    open func dismiss(_ options: [String: Any]) {
        DispatchQueue.main.async {
            // TODO: maybe not always dismiss the top - UIKit allows dismissing things not the top, dismisses all above
            guard let vc = type(of: self).shared.topMostViewController() else { return }
            let animated = options["animated"] as? Bool ?? true
            vc.dismiss(animated: animated, completion: nil)
        }
    }
    
    open func dismissAllModals(_ options: [String: Any]) {
        DispatchQueue.main.async {
            // TODO: maybe not always dismiss the top - UIKit allows dismissing things not the top, dismisses all above
            guard let vc = type(of: self).shared.topMostViewController() else { return }
            let animated = options["animated"] as? Bool ?? true
            vc.dismiss(animated: animated, completion: {
                self.dismiss(options)
            })
        }
    }
    func traitCollection(_ callback: @escaping RCTResponseSenderBlock) {
        DispatchQueue.main.async {
            let horizontalSizeClass = type(of: self).shared.topMostViewController()?.traitCollection.horizontalSizeClass ?? .unspecified
            let verticalSizeClass  = type(of: self).shared.topMostViewController()?.traitCollection.verticalSizeClass ?? .unspecified
            let horizontalKey = "horizontal"
            let verticalKey = "vertical"
            let sizeClasses = [horizontalKey: horizontalSizeClass.description, verticalKey: verticalSizeClass.description]
            callback([sizeClasses])
        }
    }
}

extension Helm {
    func navigationControllerForSplitViewControllerPush(splitViewController: UISplitViewController?, sourceModule: ModuleName, destinationModule: ModuleName, props: [String: Any], options: [String: Any]) -> HelmNavigationController? {

        if let detailViewController = splitViewController?.detailTopViewController, detailViewController.moduleName == sourceModule {
            return splitViewController?.detailNavigationController
        } else {
            let sourceViewController = splitViewController?.sourceController(moduleName: sourceModule)
            var canBecomeMaster = false
            let resetDetailNavStackIfClickedFromMaster = splitViewController?.masterTopViewController == sourceViewController
            if let canBecomeMasterNumberValue = options["canBecomeMaster"] as? NSNumber {
                canBecomeMaster = canBecomeMasterNumberValue.boolValue
            }

            if canBecomeMaster || (splitViewController?.traitCollection.horizontalSizeClass ?? .compact) == .compact {
                return splitViewController?.masterNavigationController
            } else {
                if (splitViewController?.detailNavigationController == nil || resetDetailNavStackIfClickedFromMaster) {
                    splitViewController?.primeEmptyDetailNavigationController()
                }
                return splitViewController?.detailNavigationController
            }
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
        } else {
            return self
        }
    }
}

