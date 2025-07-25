//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

import UIKit

protocol PairWithStudentQRCodeTutorialDelegate: AnyObject {
    func pairWithStudentQRCodeTutorialDidFinish(_ controller: PairWithStudentQRCodeTutorialViewController)
}

public class PairWithStudentQRCodeTutorialViewController: UIViewController {

    @IBOutlet weak var headerLabel: DynamicLabel!
    weak var delegate: PairWithStudentQRCodeTutorialDelegate?

    static func create() -> PairWithStudentQRCodeTutorialViewController {
        let vc = loadFromStoryboard()
        let next = UIBarButtonItem(
            title: String(localized: "Next", bundle: .core),
            style: .plain,
            target: vc,
            action: #selector(done(_:))
        )
        next.accessibilityIdentifier = "PairWithStudentQRCodeTutorial.nextButton"
        vc.addNavigationButton(next, side: .right)
        return vc
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        title = String(localized: "Create Account", bundle: .core)
        headerLabel.text = String(localized:
        """
        To create an account, have your student create a pairing code for you from the Settings section of the Canvas app as shown below, and then scan that code from here.
        If your student doesn't see the option to create a pairing code, you'll need to reach out to your school to create your account.
        """, bundle: .core)
        headerLabel.accessibilityIdentifier = "PairWithStudentQRCodeTutorial.headerLabel"
    }

    @objc func done(_ sender: UIBarButtonItem) {
        delegate?.pairWithStudentQRCodeTutorialDidFinish(self)
    }
}
