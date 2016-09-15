//
//  ShareViewController.swift
//  AssignmentsShare
//
//  Created by Nathan Armstrong on 3/17/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import UIKit
import Social
import AssignmentKit
import EnrollmentKit
import TooLegit
import SoLazy
import SoPersistent
import Keymaster
import FileKit

class ShareViewController: SLComposeServiceViewController {
    let appGroup = "group.com.instructure.Assignments.SubmissionShare"

    var session: Session?
    var assignment: Assignment? {
        didSet {
            validateContent()
            reloadConfigurationItems()
            reloadNewSubmissions()
        }
    }

    var itemProvider: NSItemProvider? {
        return (extensionContext?.inputItems.first as? NSExtensionItem)?.attachments?.first as? NSItemProvider
    }

    var newSubmissions = [NewUpload]() {
        didSet {
            validateContent()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        placeholder = NSLocalizedString("Comment..", comment: "Assignment submission comment placeholder text")
    }

    override func isContentValid() -> Bool {
        return session != nil && assignment != nil && newSubmissions.count > 0
    }

    override func didSelectPost() {
        performUpload {
            self.extensionContext!.completeRequestReturningItems([], completionHandler: nil)
        }
    }

    func performUpload(completionHandler: ()->Void) {
        guard let session = session, assignment = assignment where newSubmissions.count > 0 else {
            displayErrorMessage(NSLocalizedString("Unable to submit assignment.", comment: "Error message when unable to submit assignment."))
            return
        }

        let backgroundSession = session.copyToBackgroundSessionWithIdentifier(assignment.submissionUploadIdentifier, sharedContainerIdentifier: appGroup)

        func uploadSubmissions(submissions: [NewUpload]) {
            if submissions.isEmpty {
                completionHandler()
                return
            }

            var mutableSubmissions = submissions
            guard let submission = mutableSubmissions.popLast() else {
                ❨╯°□°❩╯⌢"something weird happened"
            }

            do {
                try assignment.uploadSubmission(submission, inSession: session)
            } catch {
                displayErrorMessage(NSLocalizedString("Failed to resume upload.", comment: "Error when an upload failed to resume."))
            }
        }

        uploadSubmissions(newSubmissions)
    }

    override func configurationItems() -> [AnyObject]! {
        let assignmentConfig = SLComposeSheetConfigurationItem()
        assignmentConfig.title = NSLocalizedString("Assignment", comment: "Assignment label")
        assignmentConfig.value = assignment?.name ?? ""
        assignmentConfig.tapHandler = showSessionPicker
        return [assignmentConfig]
    }

    func showSessionPicker() {
        let sessions = Keymaster.sharedInstance.savedSessions()

        if let session = sessions.first where sessions.count == 1 {
            showCoursePicker(session)
            return
        }

        let sessionsList = SelectSessionListViewController.new()
        sessionsList.pickedSessionAction = { [weak self] session in
            self?.showCoursePicker(session)
        }
        sessionsList.sessionDeleted = nil
        pushConfigurationViewController(sessionsList)
    }

    func showCoursePicker(session: Session) {
        self.session = session
        do {
            let collection = try Course.allCoursesCollection(session)
            let dataSource = CollectionTableViewDataSource(collection: collection) { course -> PickerCellViewModel in
                var vm = PickerCellViewModel(label: course.name)
                vm.accessoryType = .DisclosureIndicator
                return vm
            }
            let refresher = try Course.refresher(session)
            let coursePicker = SoPersistent.TableViewController(dataSource: dataSource, refresher: refresher)
            coursePicker.didSelectItemAtIndexPath = { [weak self] indexPath in
                let course = collection[indexPath]
                self?.showAssignmentPicker(course, session: session)
            }
            pushConfigurationViewController(coursePicker)
        } catch {
            displayErrorMessage(NSLocalizedString("Unable to select a course.", comment: "Error message when a course could not be selected"))
        }
    }

    func showAssignmentPicker(course: Course, session: Session) {
        guard let context = extensionContext else {
            return
        }

        do {
            let collection = try Assignment.collectionByDueStatus(session, courseID: course.id)
            let dataSource = CollectionTableViewDataSource(collection: collection) { assignment -> PickAssignmentTableViewCellViewModel in
                let uploadInProgress = assignment.uploadBackgroundSessionExists(session)
                let vm = PickAssignmentTableViewCellViewModel(assignment: assignment, context: context, selected: assignment.id == self.assignment?.id, uploadAlreadyInProgress: uploadInProgress)
                return vm
            }
            let refresher = try Assignment.refresher(session, courseID: course.id)
            let assignmentPicker = SoPersistent.TableViewController(dataSource: dataSource, refresher: refresher)
            assignmentPicker.didSelectItemAtIndexPath = { indexPath in
                let assignment = collection[indexPath]
                self.pickAssignment(assignment)
            }
            pushConfigurationViewController(assignmentPicker)
        } catch {
            displayErrorMessage(NSLocalizedString("Unable to select an assignment.", comment: "Error message when an assignment could not be selected"))
        }
    }

    func pickAssignment(assignment: Assignment) {
        self.assignment = assignment
        popConfigurationViewController()
    }

    func reloadNewSubmissions() {
        self.newSubmissions = []

        guard let assignment = assignment, context = extensionContext else {
            return
        }

        let builder = ShareSubmissionBuilder(assignment: assignment)
        builder.submissionsForExtensionContext(context)
            .start { [weak self] event in
                switch event {
                case .Next(let s):
                    self?.newSubmissions.append(s)
                case .Completed:
                    self?.validateContent()
                case .Failed(let e):
                    self?.displayErrorMessage(e.localizedDescription)
                case .Interrupted: break
                }
            }
    }

    func displayErrorMessage(message: String) {
        print("error", message)
    }

}
