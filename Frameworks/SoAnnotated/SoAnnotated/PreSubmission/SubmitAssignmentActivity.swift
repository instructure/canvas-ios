//
//  SubmitAssignmentActivity.swift
//  SoAnnotated
//
//  Created by Ben Kraus on 8/16/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import UIKit
import SoPretty
import TooLegit
import AssignmentKit

class SubmitAssignmentActivity: UIActivity {
    let session: Session
    let defaultCourseID: String?
    let defaultAssignmentID: String?
    var fileURL: NSURL?
    var didSubmitAssignment: (Void)->Void = { }

    init(session: Session, defaultCourseID: String?, defaultAssignmentID: String?, assignmentSubmitted: (Void)->Void) {
        self.session = session
        self.defaultCourseID = defaultCourseID
        self.defaultAssignmentID = defaultAssignmentID
        self.didSubmitAssignment = assignmentSubmitted
        super.init()
    }

    override func activityType() -> String? {
        return "submit-assignment-to-canvas"
    }

    override func activityTitle() -> String? {
        return NSLocalizedString("Submit Assignment", comment: "Title for button to submit assignment")
    }

    override func activityImage() -> UIImage? {
        return UIImage(named: "submit_activity", inBundle: NSBundle(forClass: SubmitAssignmentActivity.self), compatibleWithTraitCollection: nil)
    }

    override func canPerformWithActivityItems(activityItems: [AnyObject]) -> Bool {
        for activityItem in activityItems {
            if activityItem is NSURL { return true }
        }
        return false
    }

    override func prepareWithActivityItems(activityItems: [AnyObject]) {
        for activityItem in activityItems {
            fileURL = activityItem as? NSURL // There should only ever be one file url
        }
    }

    override func activityViewController() -> UIViewController? {
        guard let fileURL = fileURL else { return nil }

        let modal = UIStoryboard(name: "SubmitAnnotatedAssignmentViewController", bundle: NSBundle(forClass: SubmitAssignmentActivity.self)).instantiateInitialViewController() as! SmallModalNavigationController
        let vc = modal.viewControllers[0] as! SubmitAnnotatedAssignmentViewController
        vc.annotatedFileURL = fileURL
        vc.session = session
        vc.defaultCourseID = defaultCourseID
        vc.defaultAssignmentID = defaultAssignmentID
        vc.didSubmitAssignment = didSubmitAssignment
        return modal
    }
}

