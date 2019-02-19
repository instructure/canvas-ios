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

class LoginFindSchoolViewController: UIViewController, LoginFindSchoolViewProtocol {
    @IBOutlet weak var keyboardSpace: NSLayoutConstraint?
    @IBOutlet weak var loadingView: UIActivityIndicatorView?
    @IBOutlet weak var promptLabel: DynamicLabel?
    @IBOutlet weak var resultsTableView: UITableView?
    @IBOutlet weak var searchField: UITextField?

    var accounts = [(domain: String, name: String)]()
    let logoView = UIImageView()
    var presenter: LoginFindSchoolPresenter?

    var notFoundAttributedText: NSAttributedString = {
        let text = NSLocalizedString("Can’t find your school? Try typing the full school URL.", bundle: .core, comment: "")
        let link = NSLocalizedString("Tap here for help.", bundle: .core, comment: "")
        let combined = "\(text) \(link)"
        let attributedText = NSMutableAttributedString(string: combined, attributes: [
            .foregroundColor: UIColor.named(.textDark),
            .font: UIFont.scaledNamedFont(.bodySmall),
        ])
        attributedText.addAttribute(.foregroundColor, value: UIColor.named(.electric), range: (combined as NSString).range(of: link))
        return attributedText
    }()

    var helpAttributedText = NSAttributedString(
        string: NSLocalizedString("How do I find my school?", bundle: .core, comment: ""),
        attributes: [.foregroundColor: UIColor.named(.electric)]
    )

    static func create(loginDelegate: LoginDelegate?, method: AuthenticationMethod) -> LoginFindSchoolViewController {
        let controller = Bundle.loadController(self)
        controller.presenter = LoginFindSchoolPresenter(loginDelegate: loginDelegate, method: method, view: controller)
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        logoView.image = .icon(.instructure, .solid)
        logoView.tintColor = .currentLogoColor()
        logoView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        logoView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        navigationItem.titleView = logoView

        promptLabel?.text = NSLocalizedString("What’s your school’s name?", bundle: .core, comment: "")
        searchField?.attributedPlaceholder = NSAttributedString(
            string: NSLocalizedString("Find your school or district", bundle: .core, comment: ""),
            attributes: [.foregroundColor: UIColor.named(.textDark)]
        )

        presenter?.viewIsReady()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        searchField?.becomeFirstResponder()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func update(results: [(domain: String, name: String)]) {
        accounts = results
        loadingView?.stopAnimating()
        resultsTableView?.reloadData()
    }
}

extension LoginFindSchoolViewController: UITextFieldDelegate {
    @IBAction func textFieldDidChange(_ textField: UITextField) {
        guard let query = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
        loadingView?.startAnimating()
        presenter?.search(query: query)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard var host = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !host.isEmpty else { return false }
        if !host.contains(".") {
            host = "\(host).instructure.com"
        }
        textField.resignFirstResponder()
        presenter?.showLoginForHost(host)
        return false
    }
}

extension LoginFindSchoolViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(accounts.count, 1)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(UITableViewCell.self, for: indexPath)
        if accounts.isEmpty {
            cell.textLabel?.accessibilityIdentifier = "LoginFindAccountResult.emptyCell"
            cell.textLabel?.attributedText = searchField?.text?.isEmpty == true ? helpAttributedText : notFoundAttributedText
        } else {
            cell.textLabel?.accessibilityIdentifier = "LoginFindAccountResult.\(accounts[indexPath.row].domain)"
            cell.textLabel?.text = accounts[indexPath.row].name
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if accounts.isEmpty {
            presenter?.showHelp()
        } else {
            presenter?.showLoginForHost(accounts[indexPath.row].domain)
        }
    }
}

extension LoginFindSchoolViewController {
    @objc func keyboardWillShow(_ notification: Notification) {
        guard
            let info = notification.userInfo as? [String: Any],
            let keyboardHeight = (info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height,
            let animationCurve = info[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt,
            let animationDuration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
        else { return }

        UIView.animate(withDuration: animationDuration, delay: 0, options: .init(rawValue: animationCurve), animations: {
            self.keyboardSpace?.constant = keyboardHeight
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        guard
            let info = notification.userInfo as? [String: Any],
            let animationCurve = info[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt,
            let animationDuration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
        else { return }

        UIView.animate(withDuration: animationDuration, delay: 0, options: .init(rawValue: animationCurve), animations: {
            self.keyboardSpace?.constant = 0
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}
