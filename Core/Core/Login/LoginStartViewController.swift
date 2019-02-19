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

class LoginStartViewController: UIViewController, LoginStartViewProtocol {
    @IBOutlet weak var authenticationMethodLabel: DynamicLabel?
    @IBOutlet weak var canvasNetworkButton: DynamicButton?
    @IBOutlet weak var findSchoolButton: DynamicButton?
    @IBOutlet weak var helpButton: DynamicButton?
    @IBOutlet weak var logomarkYCenter: NSLayoutConstraint?
    @IBOutlet weak var logomarkView: UIImageView?
    @IBOutlet weak var logoView: UIImageView?
    @IBOutlet weak var previousLoginsBottom: NSLayoutConstraint?
    @IBOutlet weak var previousLoginsTableView: UITableView?
    @IBOutlet weak var previousLoginsView: UIView?
    @IBOutlet weak var whatsNewContainer: UIView?
    @IBOutlet weak var whatsNewLabel: DynamicLabel?
    @IBOutlet weak var whatsNewLink: DynamicButton?

    var shouldAnimateFromLaunchScreen = false
    weak var loginDelegate: LoginDelegate?
    var logins = [KeychainEntry]()
    var presenter: LoginStartPresenter?

    static func create(loginDelegate: LoginDelegate, fromLaunch: Bool) -> LoginStartViewController {
        let controller = Bundle.loadController(self)
        controller.presenter = LoginStartPresenter(loginDelegate: loginDelegate, view: controller)
        controller.loginDelegate = loginDelegate
        controller.shouldAnimateFromLaunchScreen = fromLaunch
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        canvasNetworkButton?.setTitle(NSLocalizedString("Canvas Network", bundle: .core, comment: ""), for: .normal)
        canvasNetworkButton?.isHidden = loginDelegate?.supportsCanvasNetwork == false
        findSchoolButton?.setTitle(NSLocalizedString("Find my school", bundle: .core, comment: ""), for: .normal)
        helpButton?.accessibilityLabel = NSLocalizedString("Help", bundle: .core, comment: "")
        helpButton?.isHidden = !Bundle.main.isParentApp
        authenticationMethodLabel?.isHidden = true
        logomarkView?.image = loginDelegate?.loginLogo
        logoView?.image = loginDelegate?.loginLogo
        previousLoginsView?.isHidden = true
        whatsNewLabel?.text = NSLocalizedString("We've made a few changes.", bundle: .core, comment: "")
        whatsNewLink?.setTitle(NSLocalizedString("See what's new.", bundle: .core, comment: ""), for: .normal)
        whatsNewContainer?.isHidden = loginDelegate?.whatsNewURL == nil

        presenter?.viewIsReady()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        guard shouldAnimateFromLaunchScreen else { return }

        for view in view.subviews {
            view.alpha = 0
        }
        logomarkView?.alpha = 1
        logomarkYCenter?.constant = 0
        previousLoginsBottom?.constant = -(previousLoginsView?.frame.height ?? 175)
        view.layoutIfNeeded()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard shouldAnimateFromLaunchScreen else { return }
        shouldAnimateFromLaunchScreen = false
        view.layoutIfNeeded()
        UIView.animate(withDuration: 0.75, delay: 0.25, animations: {
            self.logomarkYCenter?.constant = -150
            self.view.layoutIfNeeded()
        }, completion: fadeIn)
    }

    func fadeIn(_ completed: Bool) {
        view.layoutIfNeeded()
        UIView.animate(withDuration: 0.5, animations: {
            for view in self.view.subviews {
                view.alpha = 1
            }
            self.view.layoutIfNeeded()
        }, completion: springPreviousLogins)
    }

    func springPreviousLogins(_ completed: Bool) {
        guard previousLoginsView?.isHidden == false else { return }
        view.layoutIfNeeded()
        UIView.animate(
            withDuration: 0.5,
            delay: 0.5,
            usingSpringWithDamping: 0.75,
            initialSpringVelocity: 2,
            options: .curveEaseOut,
            animations: {
                self.previousLoginsBottom?.constant = 0
                self.view.layoutIfNeeded()
            },
            completion: nil
        )
    }

    func update(method: String?) {
        authenticationMethodLabel?.text = method
        authenticationMethodLabel?.isHidden = method == nil
    }

    func update(logins: [KeychainEntry]) {
        self.logins = logins
        previousLoginsView?.isHidden = logins.isEmpty
        previousLoginsTableView?.reloadData()
    }

    @IBAction func canvasNetworkTapped(_ sender: UIButton) {
        presenter?.openCanvasNetwork()
    }

    @IBAction func findTapped(_ sender: UIButton) {
        presenter?.openFindSchool()
    }

    @IBAction func helpTapped(_ sender: UIButton) {
        presenter?.openHelp()
    }

    @IBAction func whatsNewTapped(_ sender: UIButton) {
        presenter?.openWhatsNew()
    }

    @IBAction func authMethodTapped(_ sender: UIView) {
        presenter?.cycleAuthMethod()
    }
}

extension LoginStartViewController: UITableViewDataSource, UITableViewDelegate, LoginPreviousUserDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logins.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(LoginPreviousUserCell.self, for: indexPath)
        cell.update(entry: logins[indexPath.row], delegate: self)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter?.selectPreviousLogin(logins[indexPath.row])
    }

    func removePreviousLogin(_ entry: KeychainEntry) {
        guard let row = logins.firstIndex(of: entry) else { return }
        logins.remove(at: row)
        previousLoginsTableView?.deleteRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
        presenter?.removePreviousLogin(entry)
        if logins.isEmpty {
            view.layoutIfNeeded()
            UIView.animate(withDuration: 0.5) {
                self.previousLoginsBottom?.constant = -(self.previousLoginsView?.frame.height ?? 175)
                self.view.layoutIfNeeded()
            }
        }
    }
}
