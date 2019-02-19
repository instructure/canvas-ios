//
// Copyright (C) 2018-present Instructure, Inc.
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
import Core

class ExternalToolSubmissionContentViewController: UIViewController {

    @IBOutlet weak var openExternalToolButton: DynamicButton?
    @IBOutlet weak var errorLabel: DynamicLabel?

    var env: AppEnvironment?
    var assignment: Assignment?

    static func create(env: AppEnvironment, assignment: Assignment?) -> ExternalToolSubmissionContentViewController {
        let controller = Bundle.loadController(self)
        controller.assignment = assignment
        controller.env = env
        return controller
    }

    override func viewDidLoad() {
        openExternalToolButton?.setTitle(NSLocalizedString("Open External Tool", bundle: .student, comment: "Button to open external tool"), for: .normal)
    }

    @IBAction func openExternalTool(_ sender: Any) {
        guard let assignment = assignment, let env = env else {
            return
        }
        let context = ContextModel(.course, id: assignment.courseID)
        let lti = LTITools(env: env, context: context, id: nil, url: nil, launchType: .assessment, assignmentID: assignment.id, moduleItemID: nil)
        lti.presentToolInSFSafariViewController(from: self, animated: true, completionHandler: { [weak self] launched in
            self?.errorLabel?.isHidden = launched
        })
    }
}
