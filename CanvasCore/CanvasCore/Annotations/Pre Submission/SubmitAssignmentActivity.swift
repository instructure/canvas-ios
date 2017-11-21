//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    
    

import UIKit


class SubmitAssignmentActivity: UIActivity {
    let session: Session
    let defaultCourseID: String?
    let defaultAssignmentID: String?
    var fileURL: URL?
    var didSubmitAssignment: ()->Void = { }

    init(session: Session, defaultCourseID: String?, defaultAssignmentID: String?, assignmentSubmitted: @escaping ()->Void) {
        self.session = session
        self.defaultCourseID = defaultCourseID
        self.defaultAssignmentID = defaultAssignmentID
        self.didSubmitAssignment = assignmentSubmitted
        super.init()
    }

    override var activityType: UIActivityType? {
        return UIActivityType(rawValue: "submit-assignment-to-canvas")
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

