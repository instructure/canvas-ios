import CanvasCore
import TechDebt

extension AppDelegate: RCTBridgeDelegate {
    func prepareReactNative() {
        NativeLoginManager.shared().delegate = self
        NativeLoginManager.shared().app = .student
        HelmManager.shared.bridge = RCTBridge(delegate: self, launchOptions: nil)
        HelmManager.shared.onReactLoginComplete = {
            guard let session = self.session, let window = self.window else { return }
            
            self.syncDisposable = startSyncingAsyncActions(session)
            
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
        
        HelmManager.shared.registerNativeViewController(for: "/courses/:courseID/tabs/:tabID", factory: { props in
            guard let tabID = props["tabID"] as? String else { return nil }
            guard let courseID = props["courseID"] as? String else { return nil }
            
            let session = CanvasKeymaster.the().currentClient.authSession
            let contextID = ContextID.course(withID: courseID)
            
            guard let tabs = try? Tab.collection(session, contextID: contextID) else { return nil }
            guard let tab = tabs.filter({ $0.id == tabID }).first else { return nil }
            guard let url = tab.routingURL(session) else { return nil }
            guard let controller = Router.shared().controller(forHandling: url) else {
                DispatchQueue.main.async {
                    Router.shared().fallbackHandler(url, self.window?.rootViewController)
                }
                return nil
            }
            
            // Work around all these controllers not setting the nav color
            DispatchQueue.main.async {
                controller.navigationController?.navigationBar.barTintColor = (session.enrollmentsDataSource[ContextID(id: courseID, context: .course)] as? Course)?.color.value ?? .black
                controller.navigationController?.navigationBar.tintColor = .white
                controller.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
            }
            
            return controller
        })
        
        HelmManager.shared.registerNativeViewController(for: "/courses/:courseID/assignments/:assignmentID", factory: { props in
            guard let courseID = props["courseID"] as? String else { return nil }
            guard let assignmentID = props["assignmentID"] as? String else { return nil }
            let url = URL(string: "api/v1/courses/\(courseID)/assignments/\(assignmentID)")
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
