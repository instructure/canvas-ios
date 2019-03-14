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

private let drawerTransitioningDelegate = DrawerTransitioningDelegate()

public protocol ProfilePresenterProtocol: class {
    var view: ProfileViewController? { get set }
    var cells: [ProfileViewCell] { get }
    func didTapVersion()
}

public struct ProfileViewCell {
    let name: String
    let hidden: Bool
    let block: () -> Void

    public init(name: String, hidden: Bool, block: @escaping () -> Void) {
        self.name = name
        self.hidden = hidden
        self.block = block
    }
}

public class ProfileViewController: UIViewController {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var email: UILabel!

    var presenter: ProfilePresenterProtocol?

    public static func create(presenter: ProfilePresenterProtocol) -> ProfileViewController {
        let controller = self.loadFromXib()
        controller.modalPresentationStyle = .custom
        controller.transitioningDelegate = drawerTransitioningDelegate
        controller.presenter = presenter
        presenter.view = controller
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

    public func show(_ route: Route, options: Core.Router.RouteOptions? = nil) {
        let router = AppEnvironment.shared.router
        let dashboard = presentingViewController ?? self
        dismiss(animated: true) {
            router.route(to: route, from: dashboard, options: options)
        }
    }

    public func show(_ route: String, options: Core.Router.RouteOptions? = nil) {
        let router = AppEnvironment.shared.router
        let dashboard = presentingViewController ?? self
        dismiss(animated: true) {
            router.route(to: route, from: dashboard, options: options)
        }
    }
}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.contentView.backgroundColor = UIColor.named(.white)
        cell.textLabel?.textColor = UIColor.named(.textDarkest)
        cell.textLabel?.text = presenter?.cells[indexPath.row].name
        cell.isHidden = presenter?.cells[indexPath.row].hidden ?? false
        return cell
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.cells.count ?? 0
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter?.cells[indexPath.row].block()
    }
}

extension ProfileViewController {
    @IBAction func didTapVersion(_ sender: UITapGestureRecognizer) {
        presenter?.didTapVersion()
        tableView.reloadData()
    }
}
