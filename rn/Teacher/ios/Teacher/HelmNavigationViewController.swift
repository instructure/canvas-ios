//
//  HelmNavigationController.swift
//  Teacher
//
//  Created by Garrett Richards on 4/27/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import UIKit

class HelmNavigationController: UINavigationController {
    init() {
        let emptyViewController = EmptyViewController(nibName: nil, bundle: nil)
        super.init(rootViewController: emptyViewController)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var prefersStatusBarHidden: Bool {
        return topViewController?.prefersStatusBarHidden ?? super.prefersStatusBarHidden
    }
}

class EmptyViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
    }
}
