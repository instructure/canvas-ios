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

@IBDesignable
class SubmissionDetailsEmptyView: UIView {
    @IBOutlet weak var headingLabel: DynamicLabel?
    @IBOutlet weak var dueLabel: DynamicLabel?
    @IBOutlet weak var submitButton: DynamicButton?

    var submitCallback: ((UIButton) -> Void)?
    @IBAction func submitButtonTapped(_ sender: UIButton) {
        submitCallback?(sender)
    }

    var dueText: String? {
        get { return dueLabel?.text }
        set { dueLabel?.text = newValue }
    }

    var submitButtonTitle: String? {
        get { return submitButton?.title(for: .normal) }
        set { submitButton?.setTitle(newValue, for: .normal) }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadFromXib()
        headingLabel?.text = NSLocalizedString("No Submission", bundle: .student, comment: "")
        submitButtonTitle = NSLocalizedString("Submit Assignment", bundle: .student, comment: "")
    }
}
