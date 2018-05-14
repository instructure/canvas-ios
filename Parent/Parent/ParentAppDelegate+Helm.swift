//
// Copyright (C) 2018-present Instructure, Inc.
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

import CanvasCore
import Marshal

extension ParentAppDelegate: RCTBridgeDelegate {
    func prepareReactNative() {
        NativeLoginManager.shared().delegate = self
        NativeLoginManager.shared().app = .parent
        HelmManager.shared.bridge = RCTBridge(delegate: self, launchOptions: nil)
        
        HelmManager.shared.onReactLoginComplete = {
            guard let session = self.session else { return }
            
            do {
                let refresher = try Student.observedStudentsRefresher(session)
                refresher.refreshingCompleted.observeValues { [weak self] _ in
                    guard let weakSelf = self, let window = weakSelf.window else { return }
                    
                    let dashboardHandler = Router.sharedInstance.parentDashboardHandler()
                    let root = dashboardHandler(nil)
                    
                    weakSelf.addClearCacheGesture(root.view)
                    
                    UIView.transition(with: window, duration: 0.25, options: .transitionCrossDissolve, animations: {
                        let loading = UIViewController()
                        loading.view.backgroundColor = .white
                        window.rootViewController = loading
                    }, completion: { _ in
                        window.rootViewController = root
                    })
                    
                }
                refresher.refresh(true)
            } catch let e as NSError {
                print(e)
            }
            
            Router.sharedInstance.addRoutes()
            Router.sharedInstance.session = session
            NotificationCenter.default.post(name: .loggedIn, object: self, userInfo: [LoggedInNotificationContentsSession: session])
        }

        HelmManager.shared.onReactReload = {
            self.showLoadingState()
        }

        let nativeFactory: ([String: Any]) -> UIViewController? = { props in
            guard let route = props["route"] as? String else { return nil }
            let url = URL(string: "api/v1/\(route)")
            let controller = Router.sharedInstance.viewControllerForURL(url)
            
            // Work around all these controllers not setting the nav color
            DispatchQueue.main.async {
                guard let color = RCTConvert.uiColor(props["color"]) else { return }
                controller?.navigationController?.navigationBar.barTintColor = color
                controller?.navigationController?.navigationBar.tintColor = .white
                controller?.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
            }
            
            return controller
        }
        
        HelmManager.shared.registerNativeViewController(for: "/native-route/*route", factory: nativeFactory)
        HelmManager.shared.registerNativeViewController(for: "/native-route-master/*route", factory: nativeFactory)
        
        CanvasCore.registerSharedNativeViewControllers()
    }

    func sourceURL(for bridge: RCTBridge!) -> URL! {
        let url = RCTBundleURLProvider.sharedSettings().jsBundleURL(forBundleRoot: "index.ios", fallbackResource: nil)
        return url
    }
    
    // Use this if the moduleName maps cleanly to a native route we already have set up.
    open func registerScreen(_ moduleName: ModuleName) {
        HelmManager.shared.registerNativeViewController(for: moduleName, factory: { props in
            guard let url = propsURL(props) else { return nil }
            return Router.sharedInstance.viewControllerForURL(url)
        })
    }
}

func propsURL(_ props: [String: Any]) -> URL? {
    return hrefProp(props).flatMap(URL.init)
}

func hrefProp(_ props: [String: Any]) -> String? {
    guard let location = props["location"] as? [String: Any] else { return nil }
    return location["href"] as? String
}
