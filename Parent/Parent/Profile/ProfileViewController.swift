//
// Copyright (C) 2019-present Instructure, Inc.
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
import CanvasKeymaster
import Core

private let drawerTransitioningDelegate = DrawerTransitioningDelegate()

class ProfileViewController: UIViewController {

    enum Cells: String, CaseIterable {
        case observees
        case help
        case changeUser
        case logOut
        case developerMenu

        func localized() -> String {
            switch self {
            case .observees: return NSLocalizedString("Manage Children", bundle: .parent, comment: "")
            case .help: return NSLocalizedString("Help", bundle: .parent, comment: "")
            case .changeUser: return NSLocalizedString("Change User", bundle: .parent, comment: "")
            case .logOut: return NSLocalizedString("Log Out", bundle: .parent, comment: "")
            case .developerMenu: return NSLocalizedString("Developer Menu", bundle: .parent, comment: "")
            }
        }
    }

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var email: UILabel!

    #if DEBUG
    var showDevMenu = true
    #else
    var showDevMenu = UserDefaults.standard.bool(forKey: "showDevMenu")
    #endif

    public static func create() -> ProfileViewController {
        let controller = self.loadFromXib()
        controller.modalPresentationStyle = .custom
        controller.transitioningDelegate = drawerTransitioningDelegate
        return controller
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        let session = AppEnvironment.shared.currentSession

        avatarImageView.layer.cornerRadius = ceil( avatarImageView.bounds.size.width / 2 )
        avatarImageView.clipsToBounds = true
        avatarImageView.load(url: session?.userAvatarURL)

        name.text = session?.userName
        email.text = session?.userEmail

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.tableFooterView = UIView()
        tableView.delegate = self
    }

    func show(_ route: Route, options: Core.Router.RouteOptions? = nil) {
        let router = AppEnvironment.shared.router
        let dashboard = presentingViewController ?? self
        dismiss(animated: true) {
            router.route(to: route, from: dashboard, options: options)
        }
    }

    func show(_ route: String, options: Core.Router.RouteOptions? = nil) {
        let router = AppEnvironment.shared.router
        let dashboard = presentingViewController ?? self
        dismiss(animated: true) {
            router.route(to: route, from: dashboard, options: options)
        }
    }

    func showHelpMenu() {
        let helpMenu = UIAlertController(title: NSLocalizedString("Help", bundle: .parent, comment: ""), message: nil, preferredStyle: .actionSheet)

        helpMenu.addAction(UIAlertAction(title: NSLocalizedString("View Canvas Guides", bundle: .parent, comment: ""), style: .default) { [weak self] _ in
            self?.show("https://community.canvaslms.com/docs/DOC-9919", options: .modal)
        })

        helpMenu.addAction(UIAlertAction(title: NSLocalizedString("Report a Problem", bundle: .parent, comment: ""), style: .default) { [weak self] _ in
            self?.show("/support/problem", options: .modal)
        })

        helpMenu.addAction(UIAlertAction(title: NSLocalizedString("Request a Feature", bundle: .parent, comment: ""), style: .default) { [weak self] _ in
            self?.show("/support/feature", options: .modal)
        })

        helpMenu.addAction(UIAlertAction(title: NSLocalizedString("Terms of Use", bundle: .parent, comment: ""), style: .default) { [weak self] _ in
            self?.show("/accounts/self/terms_of_service", options: [.modal, .embedInNav])
        })

        helpMenu.addAction(UIAlertAction(title: NSLocalizedString("Cancel", bundle: .parent, comment: ""), style: .cancel))

        self.present(helpMenu, animated: true)
    }
}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.contentView.backgroundColor = UIColor.named(.white)
        cell.textLabel?.textColor = UIColor.named(.textDarkest)
        cell.textLabel?.text = Cells.allCases[indexPath.row].localized()
        cell.isHidden = Cells.allCases[indexPath.row] == .developerMenu && !showDevMenu
        return cell
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Cells.allCases.count
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch Cells.allCases[indexPath.row] {
        case .observees:
            self.show(.profileObservees)
            return
        case .help:
            self.showHelpMenu()
            return
        case .changeUser:
            CanvasKeymaster.the().switchUser()
            return
        case .logOut:
            CanvasKeymaster.the().logout()
            return
        case .developerMenu:
            self.show(.developerMenu, options: [.modal, .embedInNav])
            return
        }
    }
}

extension ProfileViewController {
    @IBAction func didTapVersion(_ sender: UITapGestureRecognizer) {
        showDevMenu = true
        UserDefaults.standard.set(true, forKey: "showDevMenu")
        tableView.reloadData()
    }
}
