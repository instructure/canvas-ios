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
    var unreadCount: UInt = 0
    let env = AppEnvironment.shared
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

    lazy var profile = env.subscribe(GetUserProfile(userID: "self")) { [weak self] in
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
            cells.append(ProfileViewCell("inbox", type: .badge(unreadCount), name: NSLocalizedString("Inbox", bundle: .core, comment: "")) { [weak self] _ in
                self?.view?.route(to: .conversations)
            })
            cells.append(ProfileViewCell("manageChildren", name: NSLocalizedString("Manage Students", bundle: .core, comment: "")) { [weak self] _ in
                self?.view?.route(to: .profileObservees())
            })
        } else {
            cells.append(ProfileViewCell("files", name: NSLocalizedString("Files", bundle: .core, comment: "")) { [weak self] _ in
                self?.view?.route(to: .files())
            })
            for tool in tools {
                cells.append(ProfileViewCell("lti.\(tool.domain ?? "").\(tool.definitionID)", name: tool.title) { [weak self] _ in
                    guard let url = tool.url else { return }
                    self?.view?.launchLTI(url: url)
                })
            }
        }

        if enrollment == .student {
            let showGrades = env.userDefaults?.showGradesOnDashboard == true
            cells.append(ProfileViewCell("showGrades", type: .toggle(showGrades), name: NSLocalizedString("Show Grades", bundle: .core, comment: "")) { [weak self] cell in
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
            cells.append(ProfileViewCell("colorOverlay", type: .toggle(colorOverlay), name: NSLocalizedString("Color Overlay", bundle: .core, comment: "")) { cell in
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
            cells.append(ProfileViewCell("settings", name: NSLocalizedString("Settings", bundle: .core, comment: "")) { [weak self] _ in
                self?.view?.route(to: .profileSettings, options: .modal(.formSheet, embedInNav: true, addDoneButton: true))
            })
        }
        if canActAsUser {
            cells.append(ProfileViewCell("actAsUser", name: NSLocalizedString("Act as User", bundle: .core, comment: "")) { [weak self] _ in
                self?.view?.route(to: .actAsUser, options: .modal(embedInNav: true))
            })
        }
        if env.currentSession?.isFakeStudent != true {
            // Don't allow Change User in Student View because the user gets destroyed
            // with each launch of Student View
            cells.append(ProfileViewCell("changeUser", name: NSLocalizedString("Change User", bundle: .core, comment: "")) { [weak self] _ in
                guard let delegate = self?.env.loginDelegate else { return }
                self?.view?.dismiss(animated: true, completion: {
                    delegate.changeUser()
                })
            })
        }
        if env.currentSession?.actAsUserID != nil {
            let leaveStudentView = NSLocalizedString("Leave Student View", bundle: .core, comment: "")
            let stopActAsUser = NSLocalizedString("Stop Act as User", bundle: .core, comment: "")
            let name = env.currentSession?.isFakeStudent == true ? leaveStudentView : stopActAsUser
            cells.append(ProfileViewCell("logOut", name: name) { [weak self] _ in
                guard let session = self?.env.currentSession else { return }
                self?.view?.dismiss(animated: true, completion: {
                    self?.env.loginDelegate?.stopActing(as: session)
                })
            })
        } else {
            cells.append(ProfileViewCell("logOut", name: NSLocalizedString("Log Out", bundle: .core, comment: "")) { [weak self] _ in
                guard let session = self?.env.currentSession else { return }
                self?.view?.dismiss(animated: true, completion: {
                    self?.env.loginDelegate?.userDidLogout(session: session)
                })
            })
        }
        if showDevMenu {
            cells.append(ProfileViewCell("developerMenu", name: NSLocalizedString("Developer Menu", bundle: .core, comment: "")) { [weak self] _ in
                self?.view?.route(to: .developerMenu, options: .modal(embedInNav: true))
            })
        }
        return cells
    }

    init(enrollment: HelpLinkEnrollment, view: ProfileViewProtocol?) {
        self.enrollment = enrollment
        self.view = view
    }

    public func viewIsReady() {
        helpLinks.refresh()
        permissions.refresh()
        settings.refresh()
        tools.refresh()
        profile.refresh()
        env.api.makeRequest(GetConversationsUnreadCountRequest()) { [weak self] (response, _, _) in performUIUpdate {
            self?.unreadCount = response?.unread_count ?? 0
            self?.view?.reload()
        } }
    }

    public func didTapVersion() {
        showDevMenu = true
        UserDefaults.standard.set(true, forKey: "showDevMenu")
        self.view?.reload()
    }
}
