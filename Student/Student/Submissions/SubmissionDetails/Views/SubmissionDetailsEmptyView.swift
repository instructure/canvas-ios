//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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
