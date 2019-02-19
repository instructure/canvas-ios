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
import Social
import CoreData

protocol ShareExtensionViewModel: DueViewable, SubmissionViewable {
    var name: String { get }
}

open class ShareExtensionViewController: SLComposeServiceViewController, ShareExtensionViewProtocol {

    fileprivate var presenter: ShareExtensionPresenter?
    fileprivate var assignment: Assignment?
    fileprivate var course: Course?
    fileprivate var submitTitle = NSLocalizedString("Submit Assignment", comment: "")

    open var iOSAppGroupName = "group.com.instructure.icanvas"

    open override func viewDidLoad() {
        super.viewDidLoad()

        if Keychain.entries.count > 0 {
            presenter = ShareExtensionPresenter(view: self, courseID: "165", assignmentID: "2169")
            presenter?.viewIsReady()
        } else {
            // TODO: Alert user (in a better UI) that they must first log into an account from the Student app first
            textView.text = NSLocalizedString("You will need to log into at least one Canvas account from the Student app first.", comment: "")
        }
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateNavBar(backgroundColor: nil)
    }

    public func updateNavBar(backgroundColor: UIColor?) {
        guard let item = navigationController?.navigationBar.items?.first?.rightBarButtonItem else { return }
        item.title = Keychain.entries.count == 0 ? "" : submitTitle
    }

    open override func presentationAnimationDidFinish() {
        super.presentationAnimationDidFinish()

        if Keychain.entries.count == 0 {
            // return presentNotSignedInMessage()
        }
    }

    open override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    open override func didSelectPost() {
        navigationController?.navigationBar.items?.first?.rightBarButtonItem?.isEnabled = false

        // do work here

        extensionContext!.completeRequest(returningItems: nil, completionHandler: nil)
    }

    open func update(course: Course, assignment: Assignment) {
        self.course = course
        self.assignment = assignment
    }

    open func showSubmitAssignmentButton(isEnabled: Bool, buttonTitle: String?) {
        guard let item = navigationController?.navigationBar.items?.first?.rightBarButtonItem else { return }

        if let title = buttonTitle {
            item.title = isEnabled ? title : ""
            submitTitle = title
        }

        item.isEnabled = isEnabled
    }

    open override func configurationItems() -> [Any]! {
        guard Keychain.entries.count > 0 else {
            return []
        }

        let account = SLComposeSheetConfigurationItem()!
        account.title = "Account"
        account.value = Keychain.entries.first?.accessToken ?? NSLocalizedString("Select Account", comment: "")
        if Keychain.entries.count > 1 {
            account.tapHandler = {
                // TODO: Push account selection view
            }
        }

        let courseItem = SLComposeSheetConfigurationItem()!
        courseItem.title = NSLocalizedString("Course", comment: "")
        courseItem.value = course?.name ?? NSLocalizedString("Select Course", comment: "")
        courseItem.tapHandler = {
            // TODO: Push course selection view
        }

        let assignmentItem = SLComposeSheetConfigurationItem()!
        assignmentItem.title = NSLocalizedString("Assignment", comment: "")
        assignmentItem.value = assignment?.name ?? NSLocalizedString("Select Assignment", comment: "")
        assignmentItem.tapHandler = {
            // TODO: Push assignment selection view
        }

        return [account, courseItem, assignmentItem]
    }

}
