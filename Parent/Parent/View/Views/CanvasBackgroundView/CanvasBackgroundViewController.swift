//
//  CanvasBackgroundViewController.swift
//  Parent
//
//  Created by Brandon Pluim on 1/8/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import UIKit

class CanvasBackgroundViewController: UIViewController {
    
//    let backgroundView: CanvasBackgroundGradientView!
    
    /*
    * Roles of View Controllers:
    *   Manage User Interface as well as interactions between interface and underlying data
    *   Facilitate transitions between different parts of your user interface
    *   Defines methods and properties for managing views
    *   Handling events
    *   Transitioning from one view controller to another
    *   Coordinating with other parts of the app
    */
    
    /*
    * Two types of View Controllers
    *   Content View Controllers - manage a discrete piece of your app's content and are the main type of view controller you create
    *   Container View Controller - Collect information from other view controllers (child view controllers) and present it in a way that facilitates navigation or presents the content of those view controllers differently
    */
    
    
    
    // ---------------------------------------------
    // MARK: - ViewController Lifecycle
    // ---------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func willTransitionToTraitCollection(newCollection: UITraitCollection, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        print("Trait Collection: \(newCollection)")
    }
}