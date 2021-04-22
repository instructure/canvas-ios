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

class LoginFindSchoolViewController: UIViewController {
    @IBOutlet weak var keyboardSpace: NSLayoutConstraint!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var resultsTableView: UITableView!
    @IBOutlet weak var searchField: UITextField!

    var accounts = [APIAccountResult]()
    var api: API = API()
    let env = AppEnvironment.shared
    var keyboard: KeyboardTransitioning?
    let logoView = UIImageView()
    var method = AuthenticationMethod.normalLogin
    weak var loginDelegate: LoginDelegate?
    var searchTask: APITask?

    var notFoundAttributedText: NSAttributedString = {
        let text = NSLocalizedString("Can’t find your school? Try typing the full school URL.", bundle: .core, comment: "")
        let link = NSLocalizedString("Tap here for help.", bundle: .core, comment: "")
        let combined = "\(text) \(link)"
        let attributedText = NSMutableAttributedString(string: combined, attributes: [
            .foregroundColor: UIColor.textDark,
            .font: UIFont.scaledNamedFont(.regular14),
        ])
        attributedText.addAttribute(.foregroundColor, value: UIColor.electric, range: (combined as NSString).range(of: link))
        return attributedText
    }()

    var helpAttributedText = NSAttributedString(
        string: NSLocalizedString("How do I find my school?", bundle: .core, comment: ""),
        attributes: [.foregroundColor: UIColor.electric]
    )

    static func create(loginDelegate: LoginDelegate?, method: AuthenticationMethod) -> LoginFindSchoolViewController {
        let controller = loadFromStoryboard()
        controller.loginDelegate = loginDelegate
        controller.method = method
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundLightest

        logoView.image = .instructureSolid
        logoView.tintColor = .currentLogoColor()
        logoView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        logoView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        navigationItem.titleView = logoView
        navigationItem.title = NSLocalizedString("Find School", bundle: .core, comment: "")

        promptLabel.text = NSLocalizedString("What’s your school’s name?", bundle: .core, comment: "")
        searchField.attributedPlaceholder = NSAttributedString(
            string: NSLocalizedString("Find your school or district", bundle: .core, comment: ""),
            attributes: [.foregroundColor: UIColor.textDark]
        )
        searchField.accessibilityLabel = NSLocalizedString("School’s name", bundle: .core, comment: "")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        keyboard = KeyboardTransitioning(view: view, space: keyboardSpace)
        if !UIAccessibility.isSwitchControlRunning, !UIAccessibility.isVoiceOverRunning {
            searchField?.becomeFirstResponder()
        }
    }

    func search(query: String) {
        guard !query.isEmpty else {
            accounts = []
            return resultsTableView.reloadData()
        }

        searchTask?.cancel()
        loadingView?.startAnimating()
        searchTask = api.makeRequest(GetAccountsSearchRequest(searchTerm: query)) { [weak self] (results, _, error) in performUIUpdate {
            guard let self = self, error == nil else { return }
            self.accounts = results ?? []
            self.loadingView.stopAnimating()
            self.resultsTableView.reloadData()
            self.searchTask = nil
        } }
    }

    func showLoginForHost(_ host: String, authenticationProvider: String? = nil) {
        let provider = authenticationProvider ?? accounts.first(where: { $0.domain == host })?.authentication_provider
        let controller: UIViewController
        if method == .manualOAuthLogin {
            controller = LoginManualOAuthViewController.create(
                authenticationProvider: provider,
                host: host,
                loginDelegate: loginDelegate
            )
        } else {
            controller = LoginWebViewController.create(
                authenticationProvider: provider,
                host: host,
                loginDelegate: loginDelegate,
                method: method
            )
        }
        env.router.show(controller, from: self)
    }
}

extension LoginFindSchoolViewController: UITextFieldDelegate {
    @IBAction func textFieldDidChange(_ textField: UITextField) {
        guard let query = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
        search(query: query)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard var host = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !host.isEmpty else { return false }
        host = host.lowercased()
        if !host.contains(".") {
            host = "\(host).instructure.com"
        }
        textField.resignFirstResponder()
        showLoginForHost(host)
        return false
    }
}

extension LoginFindSchoolViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(accounts.count, 1)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(UITableViewCell.self, for: indexPath)
        cell.backgroundColor = .backgroundLightest
        cell.textLabel?.font = .scaledNamedFont(.regular16)
        cell.textLabel?.textColor = .textDarkest
        if accounts.isEmpty {
            cell.textLabel?.accessibilityIdentifier = "LoginFindAccountResult.emptyCell"
            cell.textLabel?.attributedText = searchField?.text?.isEmpty == true ? helpAttributedText : notFoundAttributedText
        } else {
            cell.textLabel?.accessibilityIdentifier = "LoginFindAccountResult.\(accounts[indexPath.row].domain)"
            cell.textLabel?.attributedText = NSAttributedString(string: accounts[indexPath.row].name)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if accounts.isEmpty {
            guard let url = loginDelegate?.helpURL else { return }
            loginDelegate?.openExternalURL(url)
        } else {
            let account = accounts[indexPath.row]
            showLoginForHost(account.domain, authenticationProvider: account.authentication_provider)
        }
    }
}
