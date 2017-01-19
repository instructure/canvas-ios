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
import Social
import AssignmentKit
import EnrollmentKit
import TooLegit
import SoLazy
import SoPersistent
import Keymaster
import FileKit

extension NSExtensionContext {
    var attachments: [NSItemProvider] {
        return (inputItems as? [NSExtensionItem] ?? []).map { $0.attachments as? [NSItemProvider] ?? [] }.reduce([], +)
    }
}

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

    var newSubmissions = [NewUpload]() {
        didSet {
            validateContent()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        placeholder = NSLocalizedString("Comment..", tableName: "Localizable", bundle: Bundle(identifier: "com.instructure.AssignmentKit")!, value: "", comment: "Assignment submission comment placeholder text")
    }

    override func isContentValid() -> Bool {
        return session != nil && assignment != nil && newSubmissions.count > 0
    }

    override func didSelectPost() {
        performUpload {
            self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
        }
    }

    func performUpload(_ completionHandler: @escaping ()->Void) {
        guard let session = session, let assignment = assignment, newSubmissions.count > 0 else {
            displayErrorMessage(NSLocalizedString("Unable to submit assignment.", tableName: "Localizable", bundle: Bundle(identifier: "com.instructure.AssignmentKit")!, value: "", comment: "Error message when unable to submit assignment."))
            return
        }

        let backgroundSession = session.copyToBackgroundSessionWithIdentifier(assignment.submissionUploadIdentifier, sharedContainerIdentifier: appGroup)

        func uploadSubmissions(_ submissions: [NewUpload]) {
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
                displayErrorMessage(NSLocalizedString("Failed to resume upload.", tableName: "Localizable", bundle: Bundle(identifier: "com.instructure.AssignmentKit")!, value: "", comment: "Error when an upload failed to resume."))
            }
        }

        uploadSubmissions(newSubmissions)
    }

    override func configurationItems() -> [Any]! {
        guard let assignmentConfig = SLComposeSheetConfigurationItem() else { return [] }
        assignmentConfig.title = NSLocalizedString("Assignment", tableName: "Localizable", bundle: Bundle(identifier: "com.instructure.AssignmentKit")!, value: "", comment: "Assignment label")
        assignmentConfig.value = assignment?.name ?? ""
        assignmentConfig.tapHandler = showSessionPicker
        return [assignmentConfig]
    }

    func showSessionPicker() {
        let sessions = Keymaster.sharedInstance.savedSessions()

        if let session = sessions.first, sessions.count == 1 {
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

    func showCoursePicker(_ session: Session) {
        self.session = session
        do {
            let collection = try Course.allCoursesCollection(session)
            let dataSource = CollectionTableViewDataSource(collection: collection) { course -> PickerCellViewModel in
                var vm = PickerCellViewModel(label: course.name)
                vm.accessoryType = .disclosureIndicator
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
            displayErrorMessage(NSLocalizedString("Unable to select a course.", tableName: "Localizable", bundle: Bundle(identifier: "com.instructure.AssignmentKit")!, value: "", comment: "Error message when a course could not be selected"))
        }
    }

    func showAssignmentPicker(_ course: Course, session: Session) {
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
            displayErrorMessage(NSLocalizedString("Unable to select an assignment.", tableName: "Localizable", bundle: Bundle(identifier: "com.instructure.AssignmentKit")!, value: "", comment: "Error message when an assignment could not be selected"))
        }
    }

    func pickAssignment(_ assignment: Assignment) {
        self.assignment = assignment
        popConfigurationViewController()
    }

    func reloadNewSubmissions() {
        self.newSubmissions = []

        guard let assignment = assignment, let context = extensionContext else {
            return
        }

        assignment.submissions(for: context.attachments) { [weak self] result in
            if let error = result.error {
                self?.displayErrorMessage(error.localizedDescription)
                return
            }
            self?.newSubmissions = result.value ?? []
        }
    }

    func displayErrorMessage(_ message: String) {
        print("error", message)
    }

}
