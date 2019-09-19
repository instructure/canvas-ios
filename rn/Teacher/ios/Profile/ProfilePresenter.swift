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

import Foundation
import CanvasCore
import Core

public class ProfilePresenter: ProfilePresenterProtocol {
    let env: AppEnvironment
    public weak var view: ProfileViewProtocol?

    #if DEBUG
    var showDevMenu = true
    #else
    var showDevMenu = UserDefaults.standard.bool(forKey: "showDevMenu")
    #endif

    public lazy var helpLinks = env.subscribe(GetAccountHelpLinks(for: .teacher)) { [weak self] in
        self?.view?.reload()
    }

    lazy var settings = env.subscribe(GetUserSettings(userID: "self")) { [weak self] in
        self?.view?.reload()
    }

    lazy var tools = env.subscribe(GetGlobalNavExternalPlacements()) { [weak self] in
        self?.view?.reload()
    }

    lazy var permissions = env.subscribe(GetContextPermissions(context: ContextModel(.account, id: "self"), permissions: [.becomeUser])) { [weak self] in
        self?.view?.reload()
    }

    var canActAsUser: Bool {
        if env.api.baseURL.absoluteString.contains("siteadmin.instructure.com") {
            return true
        }

        return self.permissions.first?.becomeUser ?? false
    }

    public var cells: [ProfileViewCell] {
        var cells: [ProfileViewCell] = []

        cells.append(ProfileViewCell("files", name: NSLocalizedString("Files", comment: "")) { [weak self] _ in
            self?.view?.route(to: .files(), options: nil)
        })

        for tool in tools {
            cells.append(ProfileViewCell("lti.\(tool.domain ?? "").\(tool.definitionID)", name: tool.title) { [weak self] _ in
                self?.view?.dismiss(animated: true) {
                    guard let session = Session.current, let top = HelmManager.shared.topMostViewController() else { return }
                    ExternalToolManager.shared.launch(tool.url, in: session, from: top)
                }
            })
        }

        let colorOverlay = settings.first?.hideDashcardColorOverlays != true
        cells.append(ProfileViewCell("colorOverlay", type: .toggle(colorOverlay), name: NSLocalizedString("Color Overlay", comment: "")) { cell in
            let colorOverlay = (cell.accessoryView as? UISwitch)?.isOn == true
            NotificationCenter.default.post(name: NSNotification.Name("redux-action"), object: nil, userInfo: [
                "type": "userInfo.updateUserSettings",
                "pending": true,
                "payload": [ "hideOverlay": !colorOverlay ],
            ])
            UpdateUserSettings(hide_dashcard_color_overlays: !colorOverlay).fetch { (settings, _, _) in
                guard settings == nil else { return }
                NotificationCenter.default.post(name: NSNotification.Name("redux-action"), object: nil, userInfo: [
                    "type": "userInfo.updateUserSettings",
                    "error": true,
                    "payload": [ "hideOverlay": !colorOverlay ],
                ])
            }
        })

        if let root = helpLinks.first, helpLinks.count > 1 {
            cells.append(ProfileViewCell("help", name: root.text) { [weak self] cell in
                self?.view?.showHelpMenu(from: cell)
            })
        }
        cells.append(ProfileViewCell("settings", name: NSLocalizedString("Settings", comment: "")) { [weak self] cell in
            self?.showSettingsMenu(from: cell)
        })
        if showDevMenu {
            cells.append(ProfileViewCell("developerMenu", name: NSLocalizedString("Developer Menu", comment: "")) { [weak self] _ in
                self?.view?.route(to: .developerMenu, options: [.modal, .embedInNav])
            })
        }
        if canActAsUser {
            cells.append(ProfileViewCell("actAsUser", name: NSLocalizedString("Act as User", comment: "")) { [weak self] _ in
                self?.view?.route(to: .actAsUser, options: [.modal, .embedInNav])
            })
        }
        cells.append(ProfileViewCell("changeUser", name: NSLocalizedString("Change User", comment: "")) { _ in
            guard let delegate = UIApplication.shared.delegate as? LoginDelegate else { return }
            delegate.changeUser()
        })
        if env.currentSession?.actAsUserID != nil {
            cells.append(ProfileViewCell("logOut", name: NSLocalizedString("Stop Act as User", comment: "")) { _ in
                guard let delegate = UIApplication.shared.delegate as? AppDelegate else { return }
                guard let session = delegate.environment.currentSession else { return }
                delegate.stopActing(as: session)
            })
        } else {
            cells.append(ProfileViewCell("logOut", name: NSLocalizedString("Log Out", comment: "")) { _ in
                guard let delegate = UIApplication.shared.delegate as? AppDelegate else { return }
                guard let session = delegate.environment.currentSession else { return }
                delegate.userDidLogout(session: session)
            })
        }
        return cells
    }

    init(env: AppEnvironment = .shared) {
        self.env = env
    }

    public func viewIsReady() {
        helpLinks.refresh(force: true)
        permissions.refresh(force: true)
        settings.refresh(force: true)
        tools.refresh(force: true)
    }

    public func didTapVersion() {
        showDevMenu = true
        UserDefaults.standard.set(true, forKey: "showDevMenu")
        self.view?.reload()
    }

    func showSettingsMenu(from cell: UITableViewCell) {
        let settingsMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        settingsMenu.addAction(UIAlertAction(title: NSLocalizedString("Visit the Canvas Guides", comment: ""), style: .default) { [weak self] _ in
            self?.view?.route(to: "https://community.canvaslms.com/community/answers/guides/mobile-guide/content?filterID=contentstatus%5Bpublished%5D~category%5Btable-of-contents%5D", options: nil)
        })
        settingsMenu.addAction(UIAlertAction(title: NSLocalizedString("Terms of Use", comment: ""), style: .default) { [weak self] _ in
            self?.view?.route(to: .termsOfService(), options: [.modal, .embedInNav])
        })
        settingsMenu.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))

        settingsMenu.popoverPresentationController?.sourceView = cell
        settingsMenu.popoverPresentationController?.sourceRect = CGRect(origin: CGPoint(x: cell.bounds.maxX, y: cell.bounds.midY), size: .zero)
        view?.present(settingsMenu, animated: true, completion: nil)
    }
}
