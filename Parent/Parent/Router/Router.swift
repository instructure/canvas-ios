//
//  Router.swift
//  Parent
//
//  Created by Brandon Pluim on 12/14/15.
//  Copyright © 2015 Instructure Inc. All rights reserved.
//

import UIKit

import TooLegit

typealias RouteHandler = (params: [String : AnyObject]?) -> UIViewController
typealias FallbackHandler = (url: NSURL?) -> UIViewController?

class Router {
    
    var session: Session?
    var window: UIWindow?
    
    static let sharedInstance = Router()
    
    private var fallbackHandler : FallbackHandler = { url in    // Private for now.  No need to open this up until it's needed
        guard let url = url else {
            return UIViewController()
        }
        
        if url.scheme == "parent-courses" {
            return nil
        }
        
        // TODO: Setup a SafariViewController here
        return UIViewController()
    }
    
    private var routes = [String : RouteHandler]()
    private var numberFormatter = NSNumberFormatter()
    
    // ---------------------------------------------
    // MARK: - Adding Routes
    // ---------------------------------------------
    /**
     Adds a Route Template handler to our route map
    
     Route Templates follow a URL path scheme with variables inserted with a ":" prefix
    
     For example: If a route is added with the following route template - "user/assignments/:assignmentID" then
     a matching URL for this parameter would be something like "scheme://domain.com/user/assignments/234"
    
     - Parameters
        - route: URL Path Template for this handler
        - handler: completion block returning a view controller created from parameters in the URL Path Template
    */
    func addRoute(route: String, handler: RouteHandler) {
        routes[route] = handler
    }
    
    /**
     Adds multple routes to the route map
     
     Route templates follow the same rules as routes from the 'addRoute' method
     
     - Parameters
        - newRoutes: mapping similar to our map that key a Route Handler to a Route Template
    */
    func addRoutesWithDictionary(newRoutes: [String : RouteHandler]) {
        for route in newRoutes.keys {
            routes[route] = newRoutes[route]
        }
    }
    
    // ---------------------------------------------
    // MARK: - Dispatching
    // ---------------------------------------------
    /**
     Fetches the RouteHandler for a given URL if available, and then applies the given parameters to return a resulting  UIViewController
     
     - Parameter url: The URL of the ViewController you are trying to route to
    
     - Returns: UIViewController if we have a mapping that matches the URL provided.  Returns nil if no mapping is available.
    */
    func viewControllerForURL(url: NSURL) -> UIViewController? {
        return matchURL(url)
    }
    
    
    /**
     Routes from a specific view controller to the URL provided.
     
     - Parameters
        - fromController: View Controller initializing the
        - toURL: the URL you want to route to.
        - animated: Should the transition be animated?
        - modal: Is the viewController modal?
     
     - Returns: The view controller that was routed to
     */
    func route(fromController: UIViewController, toURL: NSURL, animated: Bool = true, modal: Bool = false) -> UIViewController {
        guard let viewController = matchURL(toURL) else {
            // Fallback view controller here
            // Return Fallback View Controller
            return UIViewController()
        }
        
        fromController.transitionToViewController(viewController, animated: animated, modal: modal)
        return viewController
    }
    
    /**
     Routes from a specific view controller to the URL provided.
     
     - Parameters
     - window: Window containing viewControllers
     - toRootViewController: ViewController to route to
     - animated: Should the transition be animated?
     */
    func route(window: UIWindow, toRootViewController viewController: UIViewController, animated: Bool = true) {
        let navController = UINavigationController(rootViewController: viewController)
        navController.navigationBarHidden = true
        let animationDuration = animated ? 0.5 : 0.0
        UIView.transitionWithView(window, duration: animationDuration, options: UIViewAnimationOptions.TransitionNone, animations: { _ in
            window.rootViewController = navController
            }, completion: nil)
    }
    
    
    // ---------------------------------------------
    // MARK: - URL Parsing
    // ---------------------------------------------
    /**
     Matches a URL to the existing Route Templates in our route mapping.  It then executes the handler with the parameters provided.  Additionally it adds a session if one is available in the "session" variable of the parameters to be handled by the view controller.
    
     Parameter url: url that hopefully matches a Route Template in the mapping.
    
     Returns: A View Controller created from the handler if possible, if not it returns nil
    */
    private func matchURL(matchURL: NSURL) -> UIViewController? {
        
        // Without a path, how can we route anywhere
        var urlComponents: [String] = []
        if let path = matchURL.path as NSString? {
            let realPath: NSString = path.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "/")).stringByReplacingOccurrencesOfString("api/v1/", withString: "")
            urlComponents = realPath.pathComponents
        }

        guard urlComponents.count > 0 else { return nil }
        
        var matchingRoute : String? = nil
        var params = [String: AnyObject]()
        for route in routes.keys {
            // Verify that an invalid route wasn't passed in
            guard let url = NSURL(string: route), routePathComponents = url.pathComponents where routePathComponents.count > 0 else {
                continue
            }
            
            // Can't match if the size is different
            guard routePathComponents.count == urlComponents.count else {
                continue
            }
            
            var componentsMatch = true
            for (index, component) in routePathComponents.enumerate() {
                if component.hasPrefix(":") {
                    // remove the ":" from the path
                    let parameterKey = component.substringFromIndex(component.startIndex.advancedBy(1))
                    let parameter = urlComponents[index]
                    if let number = self.numberFormatter.numberFromString(parameter) {
                        params[parameterKey] = number
                    } else {
                        params[parameterKey] = parameter
                    }
                } else if (urlComponents[index] != routePathComponents[index]) {
                    componentsMatch = false
                    break
                }
            }
            
            guard componentsMatch == true else {
                continue
            }
            
            matchingRoute = route

            params["route"] = route
            params["url"] = matchURL
            if let session = session {
                params["session"] = session
            }
            for queryItem in matchURL.allQueryItems {
                params[queryItem.name] = queryItem.value
            }
        }
        
        if let route = matchingRoute, handler = routes[route] {
            return handler(params: params)
        }
        
        return nil
    }
    
}

// ---------------------------------------------
// MARK: - UIViewController Transitioning Delegates
// ---------------------------------------------
extension UIViewController {
    /**
     Currently this application only supports UINavigationController transitions.  Breaking this out in this manner though allows us to have other transition controllers in the future if we need to.
     
     - Parameters
        - viewController: the view controller you wish to present to the user
        - animated: should we animate the transition?
        - modal: do you want the view to be specifically presented as a modal
     
    */
    func transitionToViewController(viewController: UIViewController, animated: Bool, modal: Bool) {
        // for now we're just going to route using a navigationController or Modal
        if modal {
            presentViewController(viewController, animated: animated, completion: { })
        } else {
            guard let navigationController = navigationController else {
                presentViewController(viewController, animated: animated, completion: { })
                return
            }

            navigationController.pushViewController(viewController, animated: animated)
        }
    }
}