import CanvasCore
import TechDebt

extension AppDelegate: RCTBridgeDelegate {
    func prepareReactNative() {
        NativeLoginManager.shared().delegate = self
        NativeLoginManager.shared().app = .student
        HelmManager.shared.bridge = RCTBridge(delegate: self, launchOptions: nil)
        HelmManager.shared.onReactLoginComplete = {
            guard let session = self.session, let window = self.window else { return }

            let root = rootViewController(session)
            self.addClearCacheGesture(root.view)

            UIView.transition(with: window, duration: 0.25, options: .transitionCrossDissolve, animations: {
                let loading = UIViewController()
                loading.view.backgroundColor = .white
                window.rootViewController = loading
            }, completion: { _ in
                window.rootViewController = root
            })
        }

        HelmManager.shared.onReactReload = {
            NativeLoginManager.shared().stopMasquerding()
            self.showLoadingState()
        }

        HelmManager.shared.registerNativeViewController(for: "/courses/:courseID/assignments/:assignmentID", factory: { props in
            guard let courseID = props["courseID"] as? String else { return nil }
            guard let assignmentID = props["assignmentID"] as? String else { return nil }
            let url = URL(string: "api/v1/courses/\(courseID)/assignments/\(assignmentID)")
            return Router.shared().controller(forHandling: url)
        })
        
        HelmManager.shared.registerNativeViewController(for: "/courses/:courseID/quizzes/:quizID", factory: { props in
            guard let courseID = props["courseID"] as? String else { return nil }
            guard let quizID = props["quizID"] as? String else { return nil }
            let url = URL(string: "api/v1/courses/\(courseID)/quizzes/\(quizID)")
            return Router.shared().controller(forHandling: url)
        })

        HelmManager.shared.registerNativeViewController(for: "/courses/:courseID/quizzes", factory: { props in
            guard let courseID = props["courseID"] as? String else { return nil }
            let url = URL(string: "api/v1/courses/\(courseID)/quizzes")
            return Router.shared().controller(forHandling: url)
        })

        HelmManager.shared.registerNativeViewController(for: "/users/self/files", factory: { props in
            guard let folderController = FolderViewController(interfaceStyle: FolderInterfaceStyleLight) else { return nil }
            guard let canvasAPI = CKCanvasAPI.current() else { return nil }
            folderController.canvasAPI = canvasAPI
            folderController.title = NSLocalizedString("Files", comment: "")
            let context = CKContextInfo(from: canvasAPI.user)
            folderController.loadRootFolder(forContext: context)
            return UINavigationController(rootViewController: folderController)
        })

        HelmManager.shared.registerNativeViewController(for: "/profile/settings", factory: { props in
            let settings = SettingsViewController.controller(CKCanvasAPI.current())
            return UINavigationController(rootViewController: settings)
        })

        HelmManager.shared.registerNativeViewController(for: "/groups/:groupID", factory: { props in
            guard let groupID = props["groupID"] as? String else { return nil }

            let url = URL(string: "api/v1/groups/\(groupID)/tabs")
            return Router.shared().controller(forHandling: url)
        })
        
        let nativeFactory: ([String: Any]) -> UIViewController? = { props in
            guard let route = props["route"] as? String else { return nil }
            let url = URL(string: "api/v1/\(route)")
            let controller = Router.shared().controller(forHandling: url)
            
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
        
        HelmManager.shared.registerSharedNativeViewControllers()
    }

    func excludeHelmInBranding() {
        let appearance = UINavigationBar.appearance(whenContainedInInstancesOf: [HelmNavigationController.self])
        appearance.barTintColor = nil
        appearance.tintColor = nil
        appearance.titleTextAttributes = nil
    }

    func sourceURL(for bridge: RCTBridge!) -> URL! {
        let url = RCTBundleURLProvider.sharedSettings().jsBundleURL(forBundleRoot: "index.ios", fallbackResource: nil)
        return url
    }
}
