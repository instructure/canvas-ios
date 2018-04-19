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
import SVGKit

public typealias ModuleName = String

let HelmCanBecomeMaster = "canBecomeMaster"
let HelmPrefersModalPresentation = "prefersModalPresentation"
let DrawerTransition = DrawerTransitionDelegate()
typealias HelmPreActionHandler = (HelmViewController) -> Void

public struct HelmViewControllerFactory {
    public typealias Props = [String: Any]
    public typealias Builder = (Props) -> UIViewController?
    public typealias Presenter = (UIViewController, UIViewController) -> ()
    
    public let builder: Builder
    public let presenter: Presenter?
    
    public init(builder: @escaping Builder, presenter: Presenter? = nil) {
        self.builder = builder
        self.presenter = presenter
    }
}

@objc(HelmManager)
open class HelmManager: NSObject {

    public static let shared = HelmManager()
    public var bridge: RCTBridge!
    public var onReactLoginComplete: () -> Void = {}
    public var onReactReload: () -> Void = {}

    @objc
    public func loginComplete() {
        onReactLoginComplete()
    }

    private var viewControllers = NSMapTable<NSString, HelmViewController>(keyOptions: .strongMemory, valueOptions: .weakMemory)
    private(set) var defaultScreenConfiguration: [ModuleName: [String: Any]] = [:]
    fileprivate(set) var masterModules = Set<ModuleName>()
    private var nativeViewControllerFactories: [ModuleName: HelmViewControllerFactory] = [:]

    fileprivate var pushTransitioningDelegate = PushTransitioningDelegate()

    //  MARK: - Init

    override init() {
        super.init()
        setupNotifications()
    }

    func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(reactWillReload), name: Notification.Name("RCTJavaScriptWillStartLoadingNotification"), object: nil)
    }

    open func reload() {
        bridge.reload()
    }

    open func reactWillReload() {
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

    open func registerNativeViewController(for moduleName: ModuleName, factory: @escaping HelmViewControllerFactory.Builder, withCustomPresentation presentation: HelmViewControllerFactory.Presenter? = nil) {
        nativeViewControllerFactories[moduleName] = HelmViewControllerFactory(builder: factory, presenter: presentation)
    }

    func register<T: HelmViewController>(screen: T) {
        viewControllers.setObject(screen, forKey: screen.screenInstanceID as NSString)
    }

    open func setScreenConfig(_ config: [String: Any], forScreenWithID screenInstanceID: String, hasRendered: Bool) {
        if let vc = viewControllers.object(forKey: screenInstanceID as NSString) {
            vc.screenConfig = HelmScreenConfig(config: config)
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

    public func pushFrom(_ sourceModule: ModuleName, destinationModule: ModuleName, withProps props: [String: Any], options: [String: Any], callback: (() -> Void)? = nil) {
        guard let topViewController = topMostViewController() else { return }

        let viewController: UIViewController
        let pushOntoNav: (UINavigationController) -> Void
        let replaceInNav: (UINavigationController) -> Void
        let pushToReplace = options["replace"] as? Bool ?? false

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

            let sourceViewController = splitViewController.sourceController(moduleName: sourceModule)
            let resetDetailNavStackIfClickedFromMaster = splitViewController.masterTopViewController == sourceViewController

            if let nav = navigationControllerForSplitViewControllerPush(splitViewController: splitViewController, sourceModule: sourceModule, destinationModule: destinationModule, props: propsFRD, options: options) {
                if (resetDetailNavStackIfClickedFromMaster && !canBecomeMaster && splitViewController.viewControllers.count > 1) {
                    viewController.navigationItem.leftBarButtonItem = splitViewController.prettyDisplayModeButtonItem
                    viewController.navigationItem.leftItemsSupplementBackButton = true
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
        } else {
            assertionFailure("\(#function) invalid controller: \(topViewController)")
        }
    }

    open func popFrom(_ sourceModule: ModuleName, callback: (() -> Void)? = nil) {
        guard let topViewController = topMostViewController() else {
            callback?()
            return
        }

        var nav: UINavigationController? = nil
        if let splitViewController = topViewController as? HelmSplitViewController {
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
        callback?()
    }

    public func present(_ module: ModuleName, withProps props: [String: Any], options: [String: Any], callback: (() -> Void)? = nil) {
        guard let current = topMostViewController() else {
            callback?()
            return
        }

        func configureModalProps(for viewController: UIViewController) {
            if let modalPresentationStyle = options[PropKeys.modalPresentationStyle] as? String {
                switch modalPresentationStyle {
                case "fullscreen": viewController.modalPresentationStyle = .fullScreen
                case "formsheet": viewController.modalPresentationStyle = .formSheet
                case "currentContext": viewController.modalPresentationStyle = .currentContext
                case "overCurrentContext": viewController.modalPresentationStyle = .overCurrentContext
                case "drawer":
                    viewController.modalPresentationStyle = .custom
                    viewController.transitioningDelegate = DrawerTransition
                default: viewController.modalPresentationStyle = .fullScreen
                }
            }

            if let modalTransitionStyle = options[PropKeys.modalPresentationStyle] as? String {
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
                factory.presenter == nil,
                nav == nil {
                toPresent = HelmNavigationController(rootViewController: viewController)
            }

            configureModalProps(for: toPresent)

            if let presenter = factory.presenter {
                presenter(current, viewController)
                callback?()
            } else {
                viewController.addModalDismissButton(buttonTitle: nil)
                current.present(toPresent, animated: options["animated"] as? Bool ?? true, completion: callback)
            }
        } else {
            var toPresent: UIViewController
            var helmVC: HelmViewController

            let vc = HelmViewController(moduleName: module, props: propsFRD)
            toPresent = vc
            helmVC = vc
            if let embedInNavigationController: Bool = options["embedInNavigationController"] as? Bool, embedInNavigationController {
                toPresent = HelmNavigationController(rootViewController: vc)
            }

            configureModalProps(for: toPresent)

            helmVC.loadViewIfNeeded()
            helmVC.onReadyToPresent = { [weak current, toPresent] in
                current?.present(toPresent, animated: options["animated"] as? Bool ?? true, completion: callback)
            }
        }
    }

    open func dismiss(_ options: [String: Any], callback: (() -> Void)? = nil) {
        // TODO: maybe not always dismiss the top - UIKit allows dismissing things not the top, dismisses all above
        guard let vc = topMostViewController() else { return }
        let animated = options["animated"] as? Bool ?? true
        vc.dismiss(animated: animated, completion: callback)
    }

    open func dismissAllModals(_ options: [String: Any], callback: (() -> Void)? = nil) {
        // TODO: maybe not always dismiss the top - UIKit allows dismissing things not the top, dismisses all above
        guard let vc = UIApplication.shared.keyWindow?.rootViewController, vc.presentedViewController != nil else {
            callback?()
            return
        }
        
        let animated = options["animated"] as? Bool ?? true
        vc.dismiss(animated: animated, completion: callback)
    }

    public func traitCollection(_ moduleName: String, callback: @escaping RCTResponseSenderBlock) {
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
    
    public func cleanup(callback: (() -> Void)?) {
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
}

extension HelmManager {
    func navigationControllerForSplitViewControllerPush(splitViewController: HelmSplitViewController?, sourceModule: ModuleName, destinationModule: ModuleName, props: [String: Any], options: [String: Any]) -> UINavigationController? {

        if let detailViewController = splitViewController?.detailTopHelmViewController, detailViewController.moduleName == sourceModule {
            return splitViewController?.detailHelmNavigationController ?? splitViewController?.detailNavigationController
        } else {
            let canBecomeMaster = options["canBecomeMaster"] as? Bool ?? false

            if canBecomeMaster || (splitViewController?.traitCollection.horizontalSizeClass ?? .compact) == .compact {
                return splitViewController?.masterHelmNavigationController as? HelmNavigationController
            }

            if (splitViewController?.detailHelmNavigationController == nil) {
                splitViewController?.primeEmptyDetailNavigationController()
            }

            return splitViewController?.detailHelmNavigationController ?? splitViewController?.detailNavigationController
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
        } else {
            return self
        }
    }
}

extension HelmManager {

    static func narBarTitleViewFromImagePath(_ imagePath: Any) -> UIView? {
        var titleView: UIView? = nil
        switch (imagePath) {
        case is String:
            if let path = imagePath as? String {
                if let url = URL(string: path), (path as NSString).pathExtension == "svg" {
                    titleView = SVGImageView(url: url)
                } else {
                    let imageView = UIImageView()
                    imageView.kf.setImage(with: URL(string: path))
                    titleView = imageView
                }
            }
        case is [String: Any]:
            let image = RCTConvert.uiImage(imagePath)
            let imageView = UIImageView(image: image)
            titleView = imageView
            break
        default: break
        }

        guard let view = titleView else { return nil }

        view.contentMode = .scaleAspectFit
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
        view.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        container.addSubview(view)

        return container
    }
}
