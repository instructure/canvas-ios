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
    var view: ProfileViewControllerProtocol? { get set }
    var cells: [ProfileViewCell] { get }
    func didTapVersion()
    func viewIsReady()
}

public protocol ProfileViewControllerProtocol: class {
    func reload()
    func show(_ route: Route, options: Core.Router.RouteOptions?)
    func show(_ route: String, options: Core.Router.RouteOptions?)
    func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?)}

public struct ProfileViewCell {
    let name: String
    let block: () -> Void

    public init(name: String, block: @escaping () -> Void) {
        self.name = name
        self.block = block
    }
}

public class ProfileViewController: UIViewController, ProfileViewControllerProtocol {

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
        presenter?.viewIsReady()
    }

    public func reload() {
        self.tableView.reloadData()
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
    }
}
