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

import Combine
import UIKit

class LoginFindSchoolViewController: UIViewController {
    @IBOutlet weak var keyboardSpace: NSLayoutConstraint!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var resultsTableView: UITableView!
    @IBOutlet weak var searchField: UITextField!

    private lazy var nextButton = if #available(iOS 26, *) {
        UIBarButtonItem(title: String(localized: "Next", bundle: .core), style: .prominent, target: self, action: #selector(nextPressed))
    } else {
        UIBarButtonItem(title: String(localized: "Next", bundle: .core), style: .done, target: self, action: #selector(nextPressed))
    }

    var keyboard: KeyboardTransitioning?
    let logoView = UIImageView()

    private var viewModel = LoginFindSchoolViewModel()
    private var subscriptions = Set<AnyCancellable>()

    var notFoundAttributedText: NSAttributedString = {
        let text = String(localized: "Can’t find your school? Try typing the full school URL.", bundle: .core)
        let link = String(localized: "Login help.", bundle: .core)
        let combined = "\(text) \(link)"
        let attributedText = NSMutableAttributedString(string: combined, attributes: [
            .foregroundColor: UIColor.textDark,
            .font: UIFont.scaledNamedFont(.regular14)
        ])
        attributedText.addAttribute(.foregroundColor, value: UIColor.textInfo, range: (combined as NSString).range(of: link))
        return attributedText
    }()

    var helpAttributedText = NSAttributedString(
        string: String(localized: "How do I find my school?", bundle: .core),
        attributes: [.foregroundColor: UIColor.textInfo]
    )

    static func create(loginDelegate: LoginDelegate?, method: AuthenticationMethod) -> LoginFindSchoolViewController {
        let controller = loadFromStoryboard()
        controller.viewModel.loginDelegate = loginDelegate
        controller.viewModel.method = method
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
        navigationItem.title = String(localized: "Find School", bundle: .core)
        resultsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "LoadingCell")

        promptLabel.text = String(localized: "What’s your school’s name?", bundle: .core)
        searchField.attributedPlaceholder = NSAttributedString(
            string: String(localized: "Find your school or district", bundle: .core),
            attributes: [.foregroundColor: UIColor.textDark]
        )
        searchField.accessibilityLabel = String(localized: "School’s name", bundle: .core)

        viewModel.state
            .sink { [weak self] state in
                guard let self else { return }

                if state == .searching {
                    loadingView.startAnimating()
                } else {
                    loadingView.stopAnimating()
                    resultsTableView.reloadData()
                }
            }
            .store(in: &subscriptions)
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

    @objc
    private func nextPressed() {
        parseInputAndShowLoginScreen()
    }

    private func parseInputAndShowLoginScreen() {
        guard
            let domain = viewModel.accountDomain(
                from: searchField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            )
        else { return }

        searchField.resignFirstResponder()

        let account = viewModel.accounts.first(where: { $0.domain == domain })
            ?? APIAccountResult(name: "", domain: domain, authentication_provider: nil)
        viewModel.showLoginForAccount(account, from: self)
    }

    private func toggleNextButtonVisibility() {
        if let host = searchField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !host.isEmpty {
            nextButton.accessibilityIdentifier = "nextButton"
            navigationItem.rightBarButtonItem = nextButton
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }
}

extension LoginFindSchoolViewController: UITextFieldDelegate {
    @IBAction func textFieldDidChange(_ textField: UITextField) {
        toggleNextButtonVisibility()

        guard let query = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        else { return }

        viewModel.searchQuery.send(query)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        parseInputAndShowLoginScreen()
        return false
    }
}

extension LoginFindSchoolViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.rowsCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if viewModel.accounts.isNotEmpty && indexPath.row == viewModel.accounts.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingCell", for: indexPath)
            cell.backgroundColor = .backgroundLightest

            if viewModel.state.value == .nextPageFailed {
                cell.selectionStyle = .default
                cell.accessoryView = nil
                cell.textLabel?.attributedText = NSAttributedString(
                    string: String(localized: "Failed. Tap to retry.", bundle: .core),
                    attributes: [
                        .foregroundColor: UIColor.textWarning,
                        .font: UIFont.scaledNamedFont(.regular14)
                    ]
                )
            } else {
                cell.selectionStyle = .none
                cell.textLabel?.attributedText = NSAttributedString(
                    string: String(localized: "Loading…", bundle: .core),
                    attributes: [
                        .foregroundColor: UIColor.textDark,
                        .font: UIFont.scaledNamedFont(.regular14)
                    ]
                )

                if cell.accessoryView == nil {
                    cell.accessoryView = UIActivityIndicatorView(style: .medium)
                }

                (cell.accessoryView as? UIActivityIndicatorView)?.startAnimating()
            }
            return cell
        }

        let cell = tableView.dequeue(UITableViewCell.self, for: indexPath)
        cell.backgroundColor = .backgroundLightest
        cell.textLabel?.font = .scaledNamedFont(.regular16)
        cell.textLabel?.textColor = .textDarkest
        if viewModel.accounts.isEmpty {
            cell.textLabel?.accessibilityIdentifier = "LoginFindAccountResult.emptyCell"
            cell.textLabel?.attributedText = searchField?.text?.isEmpty == true ? helpAttributedText : notFoundAttributedText
        } else {
            cell.textLabel?.accessibilityIdentifier = "LoginFindAccountResult.\(viewModel.accounts[indexPath.row].domain)"
            cell.textLabel?.attributedText = NSAttributedString(string: viewModel.accounts[indexPath.row].name)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        viewModel.rowWillDisplay(at: indexPath)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.rowSelected(at: indexPath, in: self)
    }
}

#if DEBUG

extension LoginFindSchoolViewController {

    static func makePreview(loginDelegate: LoginDelegate?, method: AuthenticationMethod) -> LoginFindSchoolViewController {
        let controller = loadFromStoryboard()
        controller.viewModel = LoginFindSchoolViewModel(scheduler: .immediate, debounceTimeout: 0)
        controller.viewModel.loginDelegate = loginDelegate
        controller.viewModel.method = method
        return controller
    }
}

#endif
