//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
    
    

import UIKit


import CanvasCore


class NoStudentsViewController: UIViewController {

    @IBOutlet var triangleBackgroundGradientView: TriangleBackgroundGradientView!
    @IBOutlet var proceedButton: UIButton!

    var proceedAction: ()->Void = { }
    var logoutAction: ()->Void = { }

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

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func proceedButtonTapped(_ sender: UIButton) {
        proceedAction()
    }

    @IBAction func logoutButtonTapped(_ sender: UIButton) {
        let style = UIDevice.current.userInterfaceIdiom == .pad ? UIAlertControllerStyle.alert : UIAlertControllerStyle.actionSheet
        let alertController = UIAlertController(title: nil, message: NSLocalizedString("Are you sure you want to logout?", comment: "Logout Confirmation"), preferredStyle: style)

        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel button title"), style: .cancel) { _ in }
        alertController.addAction(cancelAction)

        let destroyAction = UIAlertAction(title: NSLocalizedString("Logout", comment: "Logout Confirm Button"), style: .destructive) { [unowned self] _ in
            self.logoutAction()
        }
        alertController.addAction(destroyAction)

        self.present(alertController, animated: true) { }
    }
}
