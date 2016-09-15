//
//  ForgotPasswordViewController.swift
//  Parent
//
//  Created by Brandon Pluim on 11/17/15.
//  Copyright © 2015 Instructure Inc. All rights reserved.
//

import UIKit

import SoLazy

public class ForgotPasswordViewController: UIViewController {
    
    public typealias ForgotPasswordSuccessfulAction = (String) -> ()
    public typealias ForgotPasswordFailedAction = (NSError) -> ()
    
    public var success: ForgotPasswordSuccessfulAction?
    public var failure: ForgotPasswordFailedAction?
    
    // ---------------------------------------------
    // MARK: - Initializers
    // ---------------------------------------------
    private static let defaultStoryboardName = "ForgotPasswordViewController"
    public static func new(storyboardName: String = defaultStoryboardName, baseURL: NSURL, clientID: String) -> ForgotPasswordViewController {
        guard let controller = UIStoryboard(name: storyboardName, bundle: NSBundle(forClass: self)).instantiateInitialViewController() as? ForgotPasswordViewController else {
            fatalError("Initial ViewController is not of type LoginViewController")
        }
        
        return controller
    }
    
    // ---------------------------------------------
    // MARK: - UIViewController Lifecycle
    // ---------------------------------------------
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        initBackButtonIfNeeded()
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
