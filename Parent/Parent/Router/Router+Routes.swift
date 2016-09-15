//
//  Router+Routes.swift
//  Parent
//
//  Created by Brandon Pluim on 12/15/15.
//  Copyright © 2015 Instructure Inc. All rights reserved.
//

import UIKit

import Result
import TooLegit
import Keymaster

class RouteTemplates {
    static let loginRouteTemplate = "parent/login/"
    static let createAccountRouteTemplate = "parent/create_account/"
    static let forgotPasswordRouteTemplate = "parent/forgot_password/"
    static let dashboardRouteTemplate = "parent/dashboard/"
    static let settingsRouteTemplate = "parent/settings/"
}

extension Router {

    func addRoutes() {
        let routeDictionary = [
            RouteTemplates.loginRouteTemplate : loginRouteHandler(),
            RouteTemplates.createAccountRouteTemplate : createAccountHandler(),
            RouteTemplates.forgotPasswordRouteTemplate : forgotPasswordHandler(),
            RouteTemplates.dashboardRouteTemplate : parentDashboardHandler(),
            RouteTemplates.settingsRouteTemplate : settingsPageHandler()
        ]
        
        addRoutesWithDictionary(routeDictionary)
    }
    
    func routeToLoggedInViewController(window: UIWindow) {
        let initialHandler = Router.sharedInstance.parentDashboardHandler()
        let initialViewController = initialHandler(params: nil)
        Router.sharedInstance.route(window, toRootViewController: initialViewController)
    }
    
    func routeToLoggedOutViewController(window: UIWindow) {
        let initialHandler = Router.sharedInstance.loginRouteHandler()
        let initialViewController = initialHandler(params: nil)
        Router.sharedInstance.route(window, toRootViewController: initialViewController)
    }
    
    func loginRouteHandler() -> RouteHandler {
        return { params in
            let baseURL = NSURL(string: "https://mobile-1-canvas.portal2.canvaslms.com")!
            let clientID = "10000000000002"
            let clientSecret = "Zyy0dEKxtMFo4waksVsOaDpSH7WArAi8WtG72eg5ZjTjMtm3d55oZ8JnxjC0gFPB"
            let loginVC = LoginViewController.new(baseURL: baseURL, clientID: clientID, clientSecret: clientSecret)
            
            loginVC.result = { result in
                if let session = result.value {
                    self.session = session
//                    print(session.auth)
//                    print(session.currentUser.email)
//                    print(session.currentUser.avatarURL)
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.route(loginVC, toURL: NSURL(string: RouteTemplates.dashboardRouteTemplate)!)
                    }
                } else if let error = result.error {
                    print(error.localizedDescription)
                }
            }
            
            loginVC.createAccountAction = { _ in
                self.route(loginVC, toURL: NSURL(string: RouteTemplates.createAccountRouteTemplate)!)
            }
            
            loginVC.forgotPasswordAction = { _ in
                self.route(loginVC, toURL: NSURL(string: RouteTemplates.forgotPasswordRouteTemplate)!)
            }
            
            return loginVC
        }
    }
    
    func createAccountHandler() -> RouteHandler {
        return { params in
            return UIViewController()
        }
    }
    
    func forgotPasswordHandler() -> RouteHandler {
        return { params in
            return UIViewController()
        }
    }
    
    func parentDashboardHandler() -> RouteHandler {
        return { params in
            guard let session = self.session else {
                fatalError("You can't create a ParentDashboardViewController without a Session")
            }
            
            let dashboardVC = ParentDashboardViewController.new(session: session)
            dashboardVC.settingsButtonAction = { session in
                self.route(dashboardVC, toURL: NSURL(string: RouteTemplates.settingsRouteTemplate)!, animated: true, modal: true)
            }
            
            return dashboardVC
        }
    }
    
    func addInitialObserveeHandler() -> RouteHandler {
        return { params in
            return UIViewController()
        }
    }
    
    func addObserveeHandler() -> RouteHandler {
        return { params in
            return UIViewController()
        }
    }
    
    func settingsPageHandler() -> RouteHandler {
        return { params in
            guard let session = self.session else {
                fatalError("You can't create a ParentDashboardViewController without a Session")
            }
            
            let settingsVC = SettingsViewController.new(session: session)
            
            settingsVC.closeAction = { session in
                settingsVC.dismissViewControllerAnimated(true, completion: nil)
            }
            
            settingsVC.observeeSelectedAction = { session, observee in
                print(observee.name)
            }
            
            settingsVC.logoutAction = { session in
                print(session.user.name)
            }
            
            let settingsNavController = UINavigationController(rootViewController: settingsVC)
            return settingsNavController
        }
    }
    
}