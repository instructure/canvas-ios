//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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
import Social
import Core

class SubmitAssignmentViewController: SLComposeServiceViewController, SubmitAssignmentView {
    var presenter: SubmitAssignmentPresenter?

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = SubmitAssignmentPresenter()
        presenter?.view = self
        placeholder = NSLocalizedString("Comments...", bundle: .core, comment: "")
        navigationController?.navigationBar.topItem?.rightBarButtonItem?.title = NSLocalizedString("Submit", bundle: .core, comment: "")
    }

    override func presentationAnimationDidFinish() {
        super.presentationAnimationDidFinish()
        presenter?.viewIsReady()
        let items = extensionContext?.inputItems as? [NSExtensionItem] ?? []
        presenter?.load(items: items)
    }

    override func isContentValid() -> Bool {
        return presenter?.isContentValid ?? false
    }

    override func didSelectPost() {
        presenter?.submit(comment: contentText) { [weak self] in
            self?.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
        }
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        var items: [Any] = []
        guard let environment = presenter?.env else { return items }
        if let course = SLComposeSheetConfigurationItem() {
            course.title = NSLocalizedString("Course", bundle: .core, comment: "")
            let pending = presenter?.courses.pending == true || presenter?.defaultCourses?.pending == true
            course.value = pending ? nil : presenter?.course?.name
            course.valuePending = pending
            course.tapHandler = { [weak self] in
                guard let self = self else { return }
                let courses = CoursesViewController.create(environment: environment, selectedCourseID: self.presenter?.course?.id) { course in
                    self.presenter?.select(course: course)
                    self.navigationController?.popViewController(animated: true)
                }
                self.pushConfigurationViewController(courses)
            }
            items.append(course)
        }

        if let course = presenter?.course, let assignment = SLComposeSheetConfigurationItem() {
            assignment.title = NSLocalizedString("Assignment", bundle: .core, comment: "")
            let pending = presenter?.assignments?.pending == true || presenter?.defaultAssignments?.pending == true
            assignment.value = pending ? nil : presenter?.assignment?.name
            assignment.valuePending = pending
            assignment.tapHandler = { [weak self] in
                guard let self = self else { return }
                let assignments = AssignmentsViewController.create(courseID: course.id, selectedAssignmentID: self.presenter?.assignment?.id) { assignment in
                    self.presenter?.select(assignment: assignment)
                    self.navigationController?.popViewController(animated: true)
                }
                self.pushConfigurationViewController(assignments)
            }
            items.append(assignment)
        }
        return items
    }

    func update() {
        reloadConfigurationItems()
        validateContent()
    }
}
