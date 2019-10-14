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
import UIKit

public class ProfilePresenter {
    let env: AppEnvironment
    weak var view: ProfileViewProtocol?

    #if DEBUG
    var showDevMenu = true
    #else
    var showDevMenu = UserDefaults.standard.bool(forKey: "showDevMenu")
    #endif

    let enrollment: HelpLinkEnrollment
    lazy var helpLinks = env.subscribe(GetAccountHelpLinks(for: enrollment)) { [weak self] in
        self?.view?.reload()
    }

    lazy var permissions = env.subscribe(GetContextPermissions(context: ContextModel(.account, id: "self"), permissions: [.becomeUser])) { [weak self] in
        self?.view?.reload()
    }

    lazy var settings = env.subscribe(GetUserSettings(userID: "self")) { [weak self] in
        self?.view?.reload()
    }

    lazy var tools = env.subscribe(GetGlobalNavExternalPlacements()) { [weak self] in
        self?.view?.reload()
    }

    var canActAsUser: Bool {
        if env.currentSession?.baseURL.host?.hasPrefix("siteadmin.") == true {
            return true
        }

        return self.permissions.first?.becomeUser ?? false
    }

    var cells: [ProfileViewCell] {
        var cells: [ProfileViewCell] = []

        if enrollment == .observer {
            cells.append(ProfileViewCell("manageChildren", name: NSLocalizedString("Manage Children", comment: "")) { [weak self] _ in
                self?.view?.route(to: .profileObservees, options: nil)
            })
        } else {
            cells.append(ProfileViewCell("files", name: NSLocalizedString("Files", comment: "")) { [weak self] _ in
                self?.view?.route(to: .files(), options: nil)
            })
            for tool in tools {
                cells.append(ProfileViewCell("lti.\(tool.domain ?? "").\(tool.definitionID)", name: tool.title) { [weak self] _ in
                    self?.view?.launchLTI(url: tool.url)
                })
            }
        }

        if enrollment == .student {
            let showGrades = env.userDefaults?.showGradesOnDashboard == true
            cells.append(ProfileViewCell("showGrades", type: .toggle(showGrades), name: NSLocalizedString("Show Grades", comment: "")) { [weak self] cell in
                let showGrades = (cell.accessoryView as? UISwitch)?.isOn == true
                self?.env.userDefaults?.showGradesOnDashboard = showGrades
                NotificationCenter.default.post(name: NSNotification.Name("redux-action"), object: nil, userInfo: [
                    "type": "userInfo.updateShowGradesOnDashboard",
                    "payload": [ "showsGradesOnCourseCards": showGrades ],
                ])
            })
        }

        if enrollment == .student || enrollment == .teacher {
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
        }

        if let root = helpLinks.first, helpLinks.count > 1 {
            cells.append(ProfileViewCell("help", name: root.text) { [weak self] cell in
                self?.view?.showHelpMenu(from: cell)
            })
        }
        if enrollment == .student || enrollment == .teacher {
            cells.append(ProfileViewCell("settings", name: NSLocalizedString("Settings", comment: "")) { [weak self] _ in
                self?.view?.route(to: .profileSettings, options: [.modal, .embedInNav, .formSheet, .addDoneButton])
            })
        }
        if canActAsUser {
            cells.append(ProfileViewCell("actAsUser", name: NSLocalizedString("Act as User", comment: "")) { [weak self] _ in
                self?.view?.route(to: .actAsUser, options: [.modal, .embedInNav])
            })
        }
        cells.append(ProfileViewCell("changeUser", name: NSLocalizedString("Change User", comment: "")) { [weak self] _ in
            guard let delegate = self?.env.loginDelegate else { return }
            delegate.changeUser()
        })
        if env.currentSession?.actAsUserID != nil {
            let name = env.currentSession?.isFakeStudent == true ? NSLocalizedString("Leave Student View", comment: "") : NSLocalizedString("Stop Act as User", comment: "")
            cells.append(ProfileViewCell("logOut", name: name) { [weak self] _ in
                guard let session = self?.env.currentSession else { return }
                self?.env.loginDelegate?.stopActing(as: session)
            })
        } else {
            cells.append(ProfileViewCell("logOut", name: NSLocalizedString("Log Out", comment: "")) { [weak self] _ in
                guard let session = self?.env.currentSession else { return }
                self?.env.loginDelegate?.userDidLogout(session: session)
            })
        }
        if showDevMenu {
            cells.append(ProfileViewCell("developerMenu", name: NSLocalizedString("Developer Menu", comment: "")) { [weak self] _ in
                self?.view?.route(to: .developerMenu, options: [.modal, .embedInNav])
            })
        }
        return cells
    }

    init(env: AppEnvironment = .shared, enrollment: HelpLinkEnrollment, view: ProfileViewProtocol?) {
        self.env = env
        self.enrollment = enrollment
        self.view = view
    }

    public func viewIsReady() {
        helpLinks.refresh()
        permissions.refresh()
        settings.refresh()
        tools.refresh()
    }

    public func didTapVersion() {
        showDevMenu = true
        UserDefaults.standard.set(true, forKey: "showDevMenu")
        self.view?.reload()
    }
}
