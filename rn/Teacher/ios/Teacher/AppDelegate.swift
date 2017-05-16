//
//  AppDelegate.swift
//  Teacher
//
//  Created by Derrick Hathaway on 4/10/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import UIKit
import CanvasKeymaster
import ReactiveSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        BuddyBuildSDK.setup()
        prepareReactNative()
        createMainWindow()
        initiateLoginProcess()
        return true
    }
    
    func prepareReactNative() {
        Helm.shared.bridge = RCTBridge(delegate: self, launchOptions: nil)
    }
    
    func createMainWindow() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UIViewController()
        window?.makeKeyAndVisible()
    }
    
    func initiateLoginProcess() {
        CanvasKeymaster.the().fetchesBranding = true
        CanvasKeymaster.the().delegate = LoginConfiguration.shared
        
        NativeLoginManager.shared().delegate = self
    }
}


extension AppDelegate: RCTBridgeDelegate {
    func sourceURL(for bridge: RCTBridge!) -> URL! {
        let url = RCTBundleURLProvider.sharedSettings().jsBundleURL(forBundleRoot: "index.ios", fallbackResource: nil)
        return url
    }
}


extension AppDelegate: NativeLoginManagerDelegate {
    func didLogin(_ client: CKIClient) {
        var branding: BrandingModel?
        if let brandingInfo = client.branding?.jsonDictionary() as? [String: Any] {
            branding = BrandingModel(webPayload: brandingInfo)
        }
        
        let tabs = RootTabBarController(branding: branding)
        Helm.shared.rootViewController = tabs
        self.window?.rootViewController = tabs
    }
    
    func didLogout(_ controller: UIViewController) {
        self.window?.rootViewController = controller
    }
}
