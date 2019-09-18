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

public protocol ProfilePresenterProtocol: class {
    var view: ProfileViewProtocol? { get set }
    var cells: [ProfileViewCell] { get }
    var helpLinks: Store<GetAccountHelpLinks> { get }
    func didTapVersion()
    func viewIsReady()
}

public protocol ProfileViewProtocol: ErrorViewController {
    func reload()
    func route(to: Route, options: RouteOptions?)
    func route(to url: URL, options: RouteOptions?)
    func route(to url: String, options: RouteOptions?)
    func route(to url: URLComponents, options: RouteOptions?)
    func showHelpMenu(from cell: UITableViewCell)
    func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?)
}

public typealias ProfileViewCellBlock = (UITableViewCell) -> Void

public struct ProfileViewCell {
    let name: String
    let block: ProfileViewCellBlock

    public init(name: String, block: @escaping ProfileViewCellBlock) {
        self.name = name
        self.block = block
    }
}

class ProfileTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel?
}

public class ProfileViewController: UIViewController, ProfileViewProtocol {
    @IBOutlet weak var avatarButton: UIButton?
    @IBOutlet weak var avatarLoading: UIActivityIndicatorView?
    @IBOutlet weak var avatarView: AvatarView?
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var emailLabel: UILabel?
    @IBOutlet weak var versionLabel: UILabel?

    var env = AppEnvironment.shared
    var presenter: ProfilePresenterProtocol?

    public static func create(env: AppEnvironment = .shared, presenter: ProfilePresenterProtocol) -> ProfileViewController {
        let controller = loadFromStoryboard()
        controller.modalPresentationStyle = .custom
        controller.transitioningDelegate = DrawerTransitioningDelegate.shared
        controller.env = env
        controller.presenter = presenter
        presenter.view = controller
        return controller
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        let session = AppEnvironment.shared.currentSession

        view?.backgroundColor = .named(.backgroundLightest)

        avatarButton?.accessibilityLabel = NSLocalizedString("Change Profile Image", bundle: .core, comment: "")
        avatarView?.name = session?.userName ?? ""
        avatarView?.url = session?.userAvatarURL

        nameLabel?.text = session?.userName
        emailLabel?.text = session?.userEmail

        tableView?.separatorColor = .named(.borderMedium)
        presenter?.viewIsReady()

        if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            versionLabel?.text = "v. \(version)"
        }
    }

    public func reload() {
        tableView?.reloadData()
    }

    public func route(to: Route, options: RouteOptions?) {
        route(to: to.url, options: options)
    }

    public func route(to url: URL, options: RouteOptions?) {
        route(to: .parse(url), options: options)
    }

    public func route(to url: String, options: RouteOptions?) {
        route(to: .parse(url), options: options)
    }

    public func route(to url: URLComponents, options: RouteOptions?) {
        let dashboard = presentingViewController ?? self
        dismiss(animated: true) {
            self.env.router.route(to: url, from: dashboard, options: options)
        }
    }

    public func showHelpMenu(from cell: UITableViewCell) {
        guard let helpLinks = presenter?.helpLinks, let root = helpLinks.first, helpLinks.count > 1 else { return }

        let helpMenu = UIAlertController(title: root.text, message: nil, preferredStyle: .actionSheet)
        for link in helpLinks.dropFirst() {
            helpMenu.addAction(UIAlertAction(title: link.text, style: .default) { [weak self] _ in
                switch link.id {
                case "instructor_question":
                    self?.route(to: "/conversations/compose?instructorQuestion=1&canAddRecipients=0", options: [.modal, .embedInNav])
                case "report_a_problem":
                    self?.route(to: .errorReport(for: "problem"), options: [.modal, .embedInNav])
                default:
                    self?.route(to: link.url, options: [.modal, .embedInNav])
                }
            })
        }
        helpMenu.addAction(UIAlertAction(title: NSLocalizedString("Cancel", bundle: .core, comment: ""), style: .cancel))

        helpMenu.popoverPresentationController?.sourceView = cell
        helpMenu.popoverPresentationController?.sourceRect = CGRect(origin: CGPoint(x: cell.bounds.maxX, y: cell.bounds.midY), size: .zero)
        present(helpMenu, animated: true)
    }
}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ProfileTableViewCell = tableView.dequeue(for: indexPath)
        cell.nameLabel?.text = presenter?.cells[indexPath.row].name
        return cell
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.cells.count ?? 0
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        presenter?.cells[indexPath.row].block(cell)
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBAction func showAvatarMenu(sender: UIButton) {
        let avatarMenu = UIAlertController(title: NSLocalizedString("Choose Profile Picture", bundle: .core, comment: ""), message: nil, preferredStyle: .actionSheet)
        avatarMenu.addAction(UIAlertAction(title: NSLocalizedString("Take Photo", bundle: .core, comment: ""), style: .default) { [weak self] _ in
            self?.showImagePicker(for: .camera, at: sender)
        })
        avatarMenu.addAction(UIAlertAction(title: NSLocalizedString("Choose Photo", bundle: .core, comment: ""), style: .default) { [weak self] _ in
            self?.showImagePicker(for: .photoLibrary, at: sender)
        })
        avatarMenu.addAction(UIAlertAction(title: NSLocalizedString("Cancel", bundle: .core, comment: ""), style: .cancel))

        avatarMenu.popoverPresentationController?.sourceView = sender
        avatarMenu.popoverPresentationController?.sourceRect = sender.bounds
        present(avatarMenu, animated: true)
    }

    func showImagePicker(for type: UIImagePickerController.SourceType, at: UIButton) {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        picker.sourceType = type
        picker.modalPresentationStyle = .popover
        picker.popoverPresentationController?.sourceView = at
        picker.popoverPresentationController?.sourceRect = at.bounds
        present(picker, animated: true)
    }

    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        guard let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage else { return }
        avatarLoading?.startAnimating()
        do {
            UploadAvatar(url: try image.write(nameIt: "profile")).fetch(env: env) { [weak self] result in DispatchQueue.main.async {
                switch result {
                case .success(let url):
                    self?.avatarView?.url = url
                case .failure(let error):
                    self?.showError(error)
                }
                self?.avatarLoading?.stopAnimating()
            } }
        } catch {
            showError(error)
            avatarLoading?.stopAnimating()
        }
    }

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    public func showAlert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertAction.Style.default, handler: nil))
        present(alert, animated: true)
    }
}

extension ProfileViewController {
    @IBAction func didTapVersion(_ sender: UITapGestureRecognizer) {
        presenter?.didTapVersion()
    }
}
