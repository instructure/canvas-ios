//
//  NoStudentsViewController.swift
//  Parent
//
//  Created by Ben Kraus on 5/25/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import UIKit
import TooLegit
import SoPretty
import SoLazy
import Airwolf

class NoStudentsViewController: UIViewController {

    @IBOutlet var triangleBackgroundGradientView: TriangleBackgroundGradientView!
    @IBOutlet var proceedButton: UIButton!

    var proceedAction: (Void)->Void = { }
    var logoutAction: (Void)->Void = { }

    init() {
        super.init(nibName: "NoStudentsViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, proceedButton);

        let colors = ColorScheme.blueColorScheme.inverse()
        triangleBackgroundGradientView.diagonal = false
        triangleBackgroundGradientView.transitionToColors(colors.tintTopColor, tintBottomColor: colors.tintBottomColor) // Flip the colors the other way
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    @IBAction func proceedButtonTapped(sender: UIButton) {
        proceedAction()
    }

    @IBAction func logoutButtonTapped(sender: UIButton) {
        let style = UIDevice.currentDevice().userInterfaceIdiom == .Pad ? UIAlertControllerStyle.Alert : UIAlertControllerStyle.ActionSheet
        let alertController = UIAlertController(title: nil, message: NSLocalizedString("Are you sure you want to logout?", comment: "Logout Confirmation"), preferredStyle: style)

        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Logout Cancel Button"), style: .Cancel) { _ in }
        alertController.addAction(cancelAction)

        let destroyAction = UIAlertAction(title: NSLocalizedString("Logout", comment: "Logout Confirm Button"), style: .Destructive) { [unowned self] _ in
            self.logoutAction()
        }
        alertController.addAction(destroyAction)

        self.presentViewController(alertController, animated: true) { }
    }
}
