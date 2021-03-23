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

public typealias ProfileViewCellBlock = (UITableViewCell) -> Void

public enum ProfileViewCellAccessoryType {
    case toggle(Bool)
    case badge(UInt)
}

public struct ProfileViewCell {
    let id: String
    let type: ProfileViewCellAccessoryType?
    let name: String
    let block: ProfileViewCellBlock

    public init(_ id: String, type: ProfileViewCellAccessoryType? = nil, name: String, block: @escaping ProfileViewCellBlock) {
        self.id = id
        self.type = type
        self.name = name
        self.block = block
    }
}

class ProfileTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var badgeView: UIView!
    @IBOutlet weak var badgeLabel: UILabel!
}

public class ProfileViewController: UIViewController {
    @IBOutlet weak var avatarButton: UIButton!
    @IBOutlet weak var avatarLoading: CircleProgressView!
    @IBOutlet weak var avatarView: AvatarView!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var versionLabel: UILabel!

    var cells: [ProfileViewCell] = []
    var dashboard: UIViewController {
        var dashboard = presentingViewController ?? self
        if let tabs = dashboard as? UITabBarController {
            dashboard = tabs.selectedViewController ?? tabs
        }
        if let split = dashboard as? UISplitViewController {
            dashboard = split.viewControllers.first ?? split
        }
        return dashboard
    }
    let env = AppEnvironment.shared
    #if DEBUG
    var showDevMenu = true
    #else
    var showDevMenu = UserDefaults.standard.bool(forKey: "showDevMenu")
    #endif
    var unreadCount: UInt = 0

    var enrollment = HelpLinkEnrollment.student
    lazy var helpLinks = env.subscribe(GetAccountHelpLinks(for: enrollment)) { [weak self] in
        self?.reload()
    }

    lazy var permissions = env.subscribe(GetContextPermissions(context: .account("self"), permissions: [.becomeUser])) { [weak self] in
        self?.reload()
    }

    lazy var settings = env.subscribe(GetUserSettings(userID: "self")) { [weak self] in
        self?.reload()
    }

    lazy var tools = env.subscribe(GetGlobalNavExternalPlacements()) { [weak self] in
        self?.reload()
    }

    lazy var profile = env.subscribe(GetUserProfile(userID: "self")) { [weak self] in
        self?.reload()
    }

    var canActAsUser: Bool {
        if env.currentSession?.baseURL.host?.hasPrefix("siteadmin.") == true {
            return true
        }

        return self.permissions.first?.becomeUser ?? false
    }

    public static func create(enrollment: HelpLinkEnrollment) -> ProfileViewController {
        let controller = loadFromStoryboard()
        controller.modalPresentationStyle = .custom
        controller.modalPresentationCapturesStatusBarAppearance = true
        controller.transitioningDelegate = DrawerTransitioningDelegate.shared
        controller.enrollment = enrollment
        return controller
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundLightest

        avatarButton.accessibilityLabel = NSLocalizedString("Change Profile Image", bundle: .core, comment: "")
        avatarLoading.isHidden = true

        tableView.separatorColor = .borderMedium

        if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            versionLabel.text = "v. \(version)"
        }

        helpLinks.refresh()
        permissions.refresh()
        settings.refresh()
        tools.refresh()
        profile.refresh()

        env.api.makeRequest(GetConversationsUnreadCountRequest()) { [weak self] (response, _, _) in performUIUpdate {
            self?.unreadCount = response?.unread_count ?? 0
            self?.reload()
        } }
        env.api.makeRequest(GetUserRequest(userID: "self")) { [weak self] user, _, _ in
            performUIUpdate {
                self?.avatarButton.isHidden = user?.permissions?.can_update_avatar == false
            }
        }
    }

    public func reload() {
        let profile = self.profile.first
        let userName = profile?.name ?? env.currentSession?.userName
        avatarView.name = userName ?? ""
        avatarView.url = profile?.avatarURL
        nameLabel.text = userName.flatMap { User.displayName($0, pronouns: profile?.pronouns) }
        emailLabel.text = profile?.email

        cells = reloadCells()
        tableView.reloadData()
    }

    func reloadCells() -> [ProfileViewCell] {
        var cells: [ProfileViewCell] = []

        if enrollment == .observer {
            cells.append(ProfileViewCell("inbox", type: .badge(unreadCount), name: NSLocalizedString("Inbox", bundle: .core, comment: "")) { [weak self] _ in
                self?.route(to: "/conversations")
            })
            cells.append(ProfileViewCell("manageChildren", name: NSLocalizedString("Manage Students", bundle: .core, comment: "")) { [weak self] _ in
                self?.route(to: "/profile/observees")
            })
        } else {
            cells.append(ProfileViewCell("files", name: NSLocalizedString("Files", bundle: .core, comment: "")) { [weak self] _ in
                self?.route(to: "/users/self/files")
            })
            for tool in tools {
                cells.append(ProfileViewCell("lti.\(tool.domain ?? "").\(tool.definitionID)", name: tool.title) { [weak self] _ in
                    guard let url = tool.url else { return }
                    self?.launchLTI(url: url)
                })
            }
        }

        if enrollment == .student {
            let showGrades = env.userDefaults?.showGradesOnDashboard == true
            cells.append(ProfileViewCell("showGrades", type: .toggle(showGrades), name: NSLocalizedString("Show Grades", bundle: .core, comment: "")) { [weak self] cell in
                let showGrades = (cell.accessoryView as? UISwitch)?.isOn == true
                self?.env.userDefaults?.showGradesOnDashboard = showGrades
            })
        }

        if enrollment == .student || enrollment == .teacher {
            let colorOverlay = settings.first?.hideDashcardColorOverlays != true
            cells.append(ProfileViewCell("colorOverlay", type: .toggle(colorOverlay), name: NSLocalizedString("Color Overlay", bundle: .core, comment: "")) { cell in
                let colorOverlay = (cell.accessoryView as? UISwitch)?.isOn == true
                UpdateUserSettings(hide_dashcard_color_overlays: !colorOverlay).fetch()
            })
        }

        if let root = helpLinks.first, helpLinks.count > 1 {
            cells.append(ProfileViewCell("help", name: root.text) { [weak self] cell in
                self?.showHelpMenu(from: cell)
            })
        }
        if enrollment == .student || enrollment == .teacher {
            cells.append(ProfileViewCell("settings", name: NSLocalizedString("Settings", bundle: .core, comment: "")) { [weak self] _ in
                self?.route(to: "/profile/settings", options: .modal(.formSheet, embedInNav: true, addDoneButton: true))
            })
        }
        if canActAsUser {
            cells.append(ProfileViewCell("actAsUser", name: NSLocalizedString("Act as User", bundle: .core, comment: "")) { [weak self] _ in
                self?.route(to: "/act-as-user", options: .modal(embedInNav: true))
            })
        }
        if env.currentSession?.isFakeStudent != true {
            // Don't allow Change User in Student View because the user gets destroyed
            // with each launch of Student View
            cells.append(ProfileViewCell("changeUser", name: NSLocalizedString("Change User", bundle: .core, comment: "")) { [weak self] _ in
                guard let self = self, let delegate = self.env.loginDelegate else { return }
                self.env.router.dismiss(self) {
                    delegate.changeUser()
                }
            })
        }
        if env.currentSession?.actAsUserID != nil {
            let leaveStudentView = NSLocalizedString("Leave Student View", bundle: .core, comment: "")
            let stopActAsUser = NSLocalizedString("Stop Act as User", bundle: .core, comment: "")
            let name = env.currentSession?.isFakeStudent == true ? leaveStudentView : stopActAsUser
            cells.append(ProfileViewCell("logOut", name: name) { [weak self] _ in
                guard let self = self, let session = self.env.currentSession else { return }
                self.env.router.dismiss(self) {
                    self.env.loginDelegate?.stopActing(as: session)
                }
            })
        } else {
            cells.append(ProfileViewCell("logOut", name: NSLocalizedString("Log Out", bundle: .core, comment: "")) { [weak self] _ in
                UploadManager.shared.isUploading { isUploading in
                    guard let self = self, let session = self.env.currentSession else { return }
                    performUIUpdate {
                        let logoutBlock = {
                            self.env.router.dismiss(self) {
                                self.env.loginDelegate?.userDidLogout(session: session)
                            }
                        }
                        if isUploading {
                            self.showUploadAlert {
                                logoutBlock()
                            }
                        } else {
                            logoutBlock()
                        }
                    }
                }
            })
        }
        if showDevMenu {
            cells.append(ProfileViewCell("developerMenu", name: NSLocalizedString("Developer Menu", bundle: .core, comment: "")) { [weak self] _ in
                self?.route(to: "/dev-menu", options: .modal(embedInNav: true))
            })
        }
        return cells
    }

    @IBAction func didTapVersion() {
        showDevMenu = true
        UserDefaults.standard.set(true, forKey: "showDevMenu")
        reload()
    }

    public func route(to: String, options: RouteOptions = .push) {
        let dashboard = self.dashboard
        env.router.dismiss(self) {
            self.env.router.route(to: to, from: dashboard, options: options)
        }
    }

    public func launchLTI(url: URL) {
        let dashboard = self.dashboard
        env.router.dismiss(self) {
            LTITools(url: url).presentTool(from: dashboard, animated: true)
        }
    }

    public func showHelpMenu(from cell: UITableViewCell) {
        guard let root = helpLinks.first, helpLinks.count > 1 else { return }

        let helpView = HelpView(helpLinks: Array(helpLinks.dropFirst()), tapAction: { [weak self] helpLink in
            guard let route = helpLink.route, let self = self else { return }
            self.env.router.dismiss(self) {
                self.route(to: route.path, options: route.options)
            }
        })
        let helpViewController = CoreHostingController(helpView)
        helpViewController.title = root.text
        env.router.show(helpViewController, from: self, options: .modal(.formSheet, embedInNav: true, addDoneButton: true))
    }
}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ProfileTableViewCell = tableView.dequeue(for: indexPath)
        let item = cells[indexPath.row]
        cell.accessibilityIdentifier = "Profile.\(item.id)Button"
        cell.backgroundColor = .backgroundLightest
        cell.nameLabel.text = item.name
        switch item.type {
        case .toggle(let isOn):
            let toggle = UISwitch(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
            toggle.isOn = isOn
            toggle.tag = indexPath.row
            toggle.onTintColor = Brand.shared.primary
            toggle.addTarget(self, action: #selector(toggleChanged), for: .valueChanged)
            cell.accessoryView = toggle
            cell.accessibilityIdentifier = "Profile.\(item.id)Toggle"
            cell.badgeView.isHidden = true
        case .badge(let count):
            cell.accessoryView = nil
            cell.badgeLabel.text = NumberFormatter.localizedString(from: NSNumber(value: count), number: .none)
            cell.badgeLabel.textColor = Brand.shared.navBadgeText
            cell.badgeView.backgroundColor = Brand.shared.navBadgeBackground
            cell.badgeView.isHidden = count == 0
        case .none:
            cell.accessoryView = nil
            cell.badgeView.isHidden = true
        }
        return cell
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        if let toggle = cell.accessoryView as? UISwitch {
            toggle.setOn(!toggle.isOn, animated: true)
        }
        let item = cells[indexPath.row]
        Analytics.shared.logEvent("profile_\(item.id)_selected")
        item.block(cell)
    }

    @objc func toggleChanged(_ toggle: UISwitch) {
        guard let cell = tableView?.cellForRow(at: IndexPath(row: toggle.tag, section: 0)) else { return }
        cells[toggle.tag].block(cell)
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBAction func showAvatarMenu(sender: UIButton) {
        let avatarMenu = UIAlertController(title: NSLocalizedString("Choose Profile Picture", bundle: .core, comment: ""), message: nil, preferredStyle: .actionSheet)
        avatarMenu.addAction(AlertAction(NSLocalizedString("Take Photo", bundle: .core, comment: ""), style: .default) { [weak self] _ in
            self?.showImagePicker(for: .camera, at: sender)
        })
        avatarMenu.addAction(AlertAction(NSLocalizedString("Choose Photo", bundle: .core, comment: ""), style: .default) { [weak self] _ in
            self?.showImagePicker(for: .photoLibrary, at: sender)
        })
        avatarMenu.addAction(AlertAction(NSLocalizedString("Cancel", bundle: .core, comment: ""), style: .cancel))

        avatarMenu.popoverPresentationController?.sourceView = sender
        avatarMenu.popoverPresentationController?.sourceRect = sender.bounds
        env.router.show(avatarMenu, from: self, options: .modal())
    }

    func showImagePicker(for type: UIImagePickerController.SourceType, at: UIButton) {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        picker.sourceType = type
        picker.modalPresentationStyle = .popover
        picker.popoverPresentationController?.sourceView = at
        picker.popoverPresentationController?.sourceRect = at.bounds
        env.router.show(picker, from: self, options: .modal())
    }

    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        env.router.dismiss(picker)
        guard let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage else { return }
        avatarView.imageView.image = image
        avatarView.alpha = 0.5
        avatarLoading.isHidden = false
        do {
            UploadAvatar(url: try image.write(nameIt: "profile")).fetch { [weak self] result in performUIUpdate {
                switch result {
                case .success(let url):
                    self?.avatarView?.url = url
                case .failure(let error):
                    self?.reload()
                    self?.showError(error)
                }
                self?.avatarView.alpha = 1
                self?.avatarLoading.isHidden = true
            } }
        } catch {
            showError(error)
            avatarView.alpha = 1
            avatarLoading.isHidden = true
        }
    }

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        env.router.dismiss(picker)
    }

    public func showError(_ error: Error) {
        let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(AlertAction(NSLocalizedString("Dismiss", bundle: .core, comment: ""), style: .default))
        env.router.show(alert, from: self, options: .modal())
    }

    public func showUploadAlert(completionHandler: @escaping () -> Void) {
        let title = NSLocalizedString("Upload in progress", bundle: .core, comment: "")
        let message = NSLocalizedString("One of your submissions is still being uploaded. Logging out might interrupt it.\nAre you sure you want to log out?", bundle: .core, comment: "")
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(AlertAction(NSLocalizedString("Yes", bundle: .core, comment: ""), style: .destructive) { _ in
            completionHandler()
        })
        alert.addAction(AlertAction(NSLocalizedString("Cancel", bundle: .core, comment: ""), style: .cancel))
        env.router.show(alert, from: self, options: .modal())
    }
}
