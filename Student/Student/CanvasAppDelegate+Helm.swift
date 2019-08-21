//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

import CanvasCore
import TechDebt
import Marshal
import Core

extension AppDelegate: RCTBridgeDelegate {
    @objc func prepareReactNative() {
        excludeHelmInBranding()
        NativeLoginManager.shared().delegate = self
        HelmManager.shared.bridge = RCTBridge(delegate: self, launchOptions: nil)
        HelmManager.shared.onReactLoginComplete = {
            guard let session = self.session, let window = self.window else { return }
            NotificationKitController.setupForPushNotifications(delegate: self)

            let controller = rootViewController(session)
            controller.view.layoutIfNeeded()
            UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromRight, animations: {
                window.rootViewController = controller
            }, completion: nil)
        }

        HelmManager.shared.onReactReload = {
            guard self.window?.rootViewController is CanvasTabBarController else { return }
            guard let session = LoginSession.mostRecent else {
                self.changeUser()
                return
            }
            self.setup(session: session, wasReload: true)
        }

        // Files
        registerScreen("/files/:fileID")
        registerScreen("/files/:fileID/download")
        registerScreen("/:context/:contextID/files/:fileID")
        registerScreen("/:context/:contextID/files/:fileID/download")

        registerScreen("/courses/:courseID/assignments/syllabus")

        registerScreen("/courses/:courseID/quizzes")
        registerScreen("/courses/:courseID/quizzes/:quizID")
        registerScreen("/courses/:courseID/modules")
        registerScreen("/courses/:courseID/modules/:moduleID")
        registerScreen("/courses/:courseID/modules/:moduleID/items/:itemID")
        registerScreen("/courses/:courseID/modules/items/:itemID")
        registerScreen("/courses/:courseID/pages")

        registerScreen("/groups/:groupID/conferences")
        registerScreen("/groups/:groupID/collaborations")
        registerScreen("/logs")

        // Pages
        let pageParamsToProps = { (parameters: [String: Any]) -> [String: Any]? in
            guard let courseID = try? parameters.stringID("courseID") else { return nil }
            guard let url = try? parameters.stringID("url") else { return nil }
            return [
                "courseID": courseID,
                "url": url,
            ]
        }
        registerModuleItemScreen("/courses/:courseID/pages/:url", parametersToProps: pageParamsToProps)
        registerModuleItemScreen("/courses/:courseID/wiki/:url", parametersToProps: pageParamsToProps)

        HelmManager.shared.registerNativeViewController(for: "/profile/settings", factory: { _ in
            let settings = SettingsViewController.controller(CKCanvasAPI.current())
            return UINavigationController(rootViewController: settings)
        })

        HelmManager.shared.registerNativeViewController(for: "/groups/:groupID", factory: { props in
            guard let groupID = props["groupID"] as? String else { return nil }

            let url = URL(string: "api/v1/groups/\(groupID)/tabs")
            return Router.shared().controller(forHandling: url)
        })

        registerScreen("/courses/:courseID/assignments/:assignmentID")
        registerScreen("/act-as-user")
        registerScreen("/act-as-user/:userID")

        let nativeFactory: ([String: Any]) -> UIViewController? = { props in
            guard let route = props["route"] as? String else { return nil }
            let url = URL(string: "api/v1/\(route)")
            let controller = Router.shared().controller(forHandling: url)

                // Work around all these controllers not setting the nav color
            DispatchQueue.main.async {
                guard let color = RCTConvert.uiColor(props["color"]) else { return }
                controller?.navigationController?.navigationBar.useContextColor(color)
            }

            return controller
        }

        HelmManager.shared.registerNativeViewController(for: "/native-route/*route", factory: nativeFactory)
        HelmManager.shared.registerNativeViewController(for: "/native-route-master/*route", factory: nativeFactory)

        CanvasCore.registerSharedNativeViewControllers()
    }

    @objc func excludeHelmInBranding() {
        let appearance = UINavigationBar.appearance(whenContainedInInstancesOf: [HelmNavigationController.self])
        appearance.barTintColor = nil
        appearance.tintColor = nil
        appearance.titleTextAttributes = nil
    }

    func sourceURL(for bridge: RCTBridge!) -> URL! {
        let url = RCTBundleURLProvider.sharedSettings().jsBundleURL(forBundleRoot: "index.ios", fallbackResource: nil)
        return url
    }

    // Use this if the moduleName maps cleanly to a native route we already have set up.
    @objc open func registerScreen(_ moduleName: ModuleName) {
        HelmManager.shared.registerNativeViewController(for: moduleName, factory: { props in
            guard let url = propsURL(props) else { return nil }
            return Router.shared().controller(forHandling: url)
        })
    }

    // Use this if the moduleName maps to a RN view
    // but needs to be embedded in a ModuleItemDetailViewController
    // when a module_item_id param is present
    @objc open func registerModuleItemScreen(_ moduleName: ModuleName, parametersToProps: @escaping ([String: Any]) -> [String: Any]?) {
        let rnModuleName = "\(moduleName)/rn"
        Router.shared().addRoute(moduleName) { parameters, _ in
            var props = parametersToProps(parameters ?? [:]) ?? [:]
            props["location"] = [:]
            let viewController = HelmViewController(moduleName: rnModuleName, props: props)
            return moduleItemDetailViewController(routerParameters: parameters ?? [:]) ?? viewController
        }
        HelmManager.shared.registerNativeViewController(for: moduleName, factory: { props in
            return moduleItemDetailViewController(props: props) ?? HelmViewController(moduleName: rnModuleName, props: props)
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

func moduleItemDetailViewController(props: [String: Any]) -> ModuleItemDetailViewController? {
    guard let url = propsURL(props) else { return nil }
    guard let courseID = props["contextID"] as? String ?? props["courseID"] as? String else { return nil }
    if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
        let moduleItemID = components.queryItems?.filter({ $0.name == "module_item_id" }).first?.value {
        return moduleItemDetailViewController(courseID: courseID, moduleItemID: moduleItemID)
    }
    return nil
}

func moduleItemDetailViewController(routerParameters parameters: [String: Any]) -> ModuleItemDetailViewController? {
    if let courseID = try? parameters.stringID("courseID"),
        let query = parameters["query"] as? [String: Any],
        let moduleItemID = query["module_item_id"] as? String {
        return moduleItemDetailViewController(courseID: courseID, moduleItemID: moduleItemID)
    }
    return nil
}

func moduleItemDetailViewController(courseID: String, moduleItemID: String) -> ModuleItemDetailViewController? {
    guard let session = CanvasKeymaster.the().currentClient?.authSession else {
        return nil
    }
    do {
        return try ModuleItemDetailViewController(session: session, courseID: courseID, moduleItemID: moduleItemID) { (vc, url) in
            Router.shared().route(from: vc, to: url)
        }
    } catch {
        return nil
    }
}
