//
// Copyright (C) 2016-present Instructure, Inc.
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

import CanvasCore
import Eureka



private enum SupportTicketCellTag: String {
    case Email, Subject, Impact, Comment
}

open class SupportTicketViewController : FormViewController {

    fileprivate var requesterName: String = NSLocalizedString("Unknown User", tableName: "Localizable", bundle: .parent, value: "", comment: "Default name given a user until we find their real name")
    fileprivate var requesterUsername: String = NSLocalizedString("Unknown User Name", tableName: "Localizable", bundle: .parent, value: "", comment: "Default user name, the computer-friendly version of their name, until we find their real user name")
    fileprivate var requesterEmail: String? = nil {
        didSet {
            if let row = form.rowBy(tag: SupportTicketCellTag.Email.rawValue) {
                row.evaluateHidden()
            }
        }
    }
    fileprivate var baseURL : URL? = nil
    fileprivate var type: SupportTicketType = .problem
    fileprivate var session: Session? = nil

    fileprivate var cancelButton: UIBarButtonItem!
    fileprivate var doneButton: UIBarButtonItem!
    fileprivate var notification: ToastManager?
    fileprivate var sendTask: URLSessionDataTask?

    open static func new(_ session: Session, type: SupportTicketType) -> SupportTicketViewController{
        let controller = SupportTicketViewController()
        controller.requesterName = session.user.sortableName ?? session.user.name
        controller.requesterEmail = session.user.email
        controller.requesterUsername = session.user.name
        controller.baseURL = session.baseURL
        controller.type = type
        controller.session = session

        return controller
    }

    // ---------------------------------------------
    // MARK: - UIViewController LifeCycle
    // ---------------------------------------------
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        if let nav = navigationController?.navigationBar {
            notification = ToastManager(navigationBar: nav)
        }

        cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(SupportTicketViewController.cancelTapped(_:)))
        doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(SupportTicketViewController.doneTapped(_:)))
        
        self.navigationItem.leftBarButtonItem = cancelButton
        self.navigationItem.rightBarButtonItem = doneButton

        form +++ Section()
            <<< PushRow<String>() {
                $0.title = NSLocalizedString("Impact:", tableName: "Localizable", bundle: .parent, value: "", comment: "Impact Title")
                $0.selectorTitle = NSLocalizedString("Select Impact", tableName: "Localizable", bundle: .parent, value: "", comment: "Select Impact Placeholder")
                $0.options = ImpactLevel.impacts().map { $0.description() }
                $0.value = ImpactLevel.None.description()
                $0.tag = SupportTicketCellTag.Impact.rawValue
                }.onChange { [weak self] row in
                    self?.validateForm()
            }
            <<< EmailRow(SupportTicketCellTag.Email.rawValue) { [weak self] in
                let rowHidden = (self?.requesterEmail != nil)
                $0.hidden = Condition(booleanLiteral: rowHidden)
                }.cellSetup { cell, row in
                cell.textField.placeholder = NSLocalizedString("Your Email", tableName: "Localizable", bundle: .parent, value: "", comment: "Title for the email field")
                }.onChange { [weak self] row in
                    self?.validateForm()
            }
            <<<  TextRow(SupportTicketCellTag.Subject.rawValue).cellSetup { cell, row in
                cell.textField.placeholder = NSLocalizedString("Subject", bundle: .parent, comment: "Title for the subject field")
                }.onChange { [weak self] row in
                    self?.validateForm()
            }
            <<< TextAreaRow(SupportTicketCellTag.Comment.rawValue) {
                $0.placeholder = type.description()
                $0.cell.textView.accessibilityHint = "\($0.placeholder)"
                $0.textAreaHeight = .dynamic(initialTextViewHeight: 100)
                }.onChange { [weak self] row in
                    self?.validateForm()
            }

        validateForm()
    }

    // ---------------------------------------------
    // MARK: - IBActions
    // ---------------------------------------------
    func doneTapped(_ barButtonItem: UIBarButtonItem) {
        guard let impactRow = form.rowBy(tag: SupportTicketCellTag.Impact.rawValue) as? PushRow<String>,
            let subjectRow = form.rowBy(tag: SupportTicketCellTag.Subject.rawValue) as? TextRow,
            let commentRow = form.rowBy(tag: SupportTicketCellTag.Comment.rawValue) as? TextAreaRow,
            let impactValue = impactRow.value,
            let impact = ImpactLevel.impactFromDescription(impactValue),
            let subject = subjectRow.value?.trimmingCharacters(in: .whitespacesAndNewlines),
            let comment = commentRow.value?.trimmingCharacters(in: .whitespacesAndNewlines) else {
                notification?.toastSuccess(NSLocalizedString("Invalid Input.  Check fields and try again.", tableName: "Localizable", bundle: .parent, value: "", comment: "Support Ticket Invalid Input Message"))
                return
        }

        var email = requesterEmail ?? "unknown_email@unknown.com"
        if let emailRow = form.rowBy(tag: SupportTicketCellTag.Email.rawValue) as? TextRow,
            let emailValue = emailRow.value?.trimmingCharacters(in: .whitespacesAndNewlines) {
            email = requesterEmail ?? emailValue
        }

        let realBaseURL = baseURL ?? URL(string: "https://canvas.instructure.com")!
        let url = realBaseURL.appendingPathComponent("error_reports.json")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        let supportTicket: SupportTicket
        if let session = session {
            supportTicket = SupportTicket(session: session, subject: subject, body: comment, impact: impact, type: type)
        } else {
            supportTicket = SupportTicket(requesterName: requesterName, requesterUsername: requesterUsername, requesterEmail: email, requesterDomain: realBaseURL, subject: subject, body: comment, impact: impact, type: type)
        }
        let data = try! JSONSerialization.data(withJSONObject: supportTicket.dictionaryValue(), options: .prettyPrinted)
        request.httpBody = data

        setLoading(true)
        sendTask = URLSession.shared.dataTask(with: request) { [weak self] data,response,error in
            let notification = self?.notification
            guard error == nil else {
                if let _ = error {
                    DispatchQueue.main.async {
                        self?.setLoading(false)
                        notification?.toastSuccess(NSLocalizedString("Request Failed!  Check network and try again!", tableName: "Localizable", bundle: .parent, value: "", comment: "Support Ticket Creation Failed"))
                    }
                }
                return
            }

            DispatchQueue.main.async {
                self?.setLoading(false)
                let _ = self?.navigationController?.popViewController(animated: true)
                notification?.toastSuccess(NSLocalizedString("Thanks, your request was received!", tableName: "Localizable", bundle: .parent, value: "", comment: "Support Ticket Created Successfully"))
            }
        }

        sendTask?.resume()
    }

    func cancelTapped(_ barButtonItem: UIBarButtonItem) {
        sendTask?.cancel()
        let _ = navigationController?.popViewController(animated: true)
    }

    // ---------------------------------------------
    // MARK: - Validation
    // ---------------------------------------------
    func validateForm() {
        doneButton.isEnabled = isFormValid()
    }

    func setLoading(_ loading: Bool) {
        if loading {
            let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
            activityIndicator.startAnimating()
        } else {
            navigationItem.rightBarButtonItem = doneButton
        }
    }

    func isFormValid() -> Bool {
        if let emailRow = form.rowBy(tag: SupportTicketCellTag.Email.rawValue) as? EmailRow,
            let formEmail = emailRow.value {
            requesterEmail = formEmail
        }

        guard let impactRow = form.rowBy(tag: SupportTicketCellTag.Impact.rawValue) as? PushRow<String>,
            let subjectRow = form.rowBy(tag: SupportTicketCellTag.Subject.rawValue) as? TextRow,
            let commentRow = form.rowBy(tag: SupportTicketCellTag.Comment.rawValue) as? TextAreaRow,
            let impact = impactRow.value,
            let email = requesterEmail,
            let subject = subjectRow.value?.trimmingCharacters(in: .whitespacesAndNewlines),
            let comment = commentRow.value?.trimmingCharacters(in: .whitespacesAndNewlines) else {
                return false
        }

        return email.isValidEmail() && impact != ImpactLevel.None.description() && !subject.isEmpty && !comment.isEmpty
    }

}
