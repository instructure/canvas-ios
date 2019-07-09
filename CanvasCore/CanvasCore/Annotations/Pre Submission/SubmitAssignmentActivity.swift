//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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


class SubmitAssignmentActivity: UIActivity {
    @objc let session: Session
    @objc let defaultCourseID: String?
    @objc let defaultAssignmentID: String?
    @objc var fileURL: URL?
    @objc var didSubmitAssignment: ()->Void = { }

    @objc init(session: Session, defaultCourseID: String?, defaultAssignmentID: String?, assignmentSubmitted: @escaping ()->Void) {
        self.session = session
        self.defaultCourseID = defaultCourseID
        self.defaultAssignmentID = defaultAssignmentID
        self.didSubmitAssignment = assignmentSubmitted
        super.init()
    }

    override var activityType: UIActivity.ActivityType? {
        return UIActivity.ActivityType(rawValue: "submit-assignment-to-canvas")
    }

    override var activityTitle : String? {
        return NSLocalizedString("Submit Assignment", comment: "Title for button to submit assignment")
    }

    override var activityImage : UIImage? {
        return UIImage(named: "submit_activity", in: Bundle(for: SubmitAssignmentActivity.self), compatibleWith: nil)
    }

    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        for activityItem in activityItems {
            if activityItem is URL { return true }
        }
        return false
    }

    override func prepare(withActivityItems activityItems: [Any]) {
        for activityItem in activityItems {
            fileURL = activityItem as? URL // There should only ever be one file url
        }
    }

    override var activityViewController : UIViewController? {
        guard let fileURL = fileURL else { return nil }

        let modal = UIStoryboard(name: "SubmitAnnotatedAssignmentViewController", bundle: Bundle(for: SubmitAssignmentActivity.self)).instantiateInitialViewController() as! SmallModalNavigationController
        let vc = modal.viewControllers[0] as! SubmitAnnotatedAssignmentViewController
        vc.annotatedFileURL = fileURL
        vc.session = session
        vc.defaultCourseID = defaultCourseID
        vc.defaultAssignmentID = defaultAssignmentID
        vc.didSubmitAssignment = didSubmitAssignment
        return modal
    }
}

