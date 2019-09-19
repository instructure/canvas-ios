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
import Core

public class ProfilePresenter: ProfilePresenterProtocol {
    let env: AppEnvironment
    public weak var view: ProfileViewProtocol?

    #if DEBUG
    var showDevMenu = true
    #else
    var showDevMenu = UserDefaults.standard.bool(forKey: "showDevMenu")
    #endif

    public lazy var helpLinks = env.subscribe(GetAccountHelpLinks(for: .observer)) { [weak self] in
        self?.view?.reload()
    }

    lazy var permissions: Store<GetContextPermissions> = {
        let useCase = GetContextPermissions(context: ContextModel(.account, id: "self"), permissions: [.becomeUser])
        return env.subscribe(useCase) { [weak self] in
            self?.view?.reload()
        }
    }()

    var canActAsUser: Bool {
        if env.api.baseURL.absoluteString.contains("siteadmin.instructure.com") {
            return true
        }

        return self.permissions.first?.becomeUser ?? false
    }

    public var cells: [ProfileViewCell] {
        var cells: [ProfileViewCell] = []

        cells.append(ProfileViewCell("manageChildren", name: NSLocalizedString("Manage Children", comment: "")) { [weak self] _ in
            self?.view?.route(to: .profileObservees, options: nil)
        })
        if let root = helpLinks.first, helpLinks.count > 1 {
            cells.append(ProfileViewCell("help", name: root.text) { [weak self] cell in
                self?.view?.showHelpMenu(from: cell)
            })
        }
        if canActAsUser {
            cells.append(ProfileViewCell("actAsUser", name: NSLocalizedString("Act as User", comment: "")) { [weak self] _ in
                self?.view?.route(to: .actAsUser, options: [.modal, .embedInNav])
            })
        }
        cells.append(ProfileViewCell("changeUser", name: NSLocalizedString("Change User", comment: "")) { _ in
            guard let delegate = UIApplication.shared.delegate as? ParentAppDelegate else { return }
            delegate.changeUser()
        })
        if env.currentSession?.actAsUserID != nil {
            cells.append(ProfileViewCell("logOut", name: NSLocalizedString("Stop Act as User", comment: "")) { _ in
                guard let delegate = UIApplication.shared.delegate as? ParentAppDelegate else { return }
                guard let session = delegate.environment.currentSession else { return }
                delegate.stopActing(as: session)
            })
        } else {
            cells.append(ProfileViewCell("logOut", name: NSLocalizedString("Log Out", comment: "")) { _ in
                guard let delegate = UIApplication.shared.delegate as? ParentAppDelegate else { return }
                guard let session = delegate.environment.currentSession else { return }
                delegate.userDidLogout(session: session)
            })
        }
        if showDevMenu {
            cells.append(ProfileViewCell("developerMenu", name: NSLocalizedString("Developer Menu", comment: "")) { [weak self] _ in
                self?.view?.route(to: .developerMenu, options: [.modal, .embedInNav ])
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
    }

    public func didTapVersion() {
        showDevMenu = true
        UserDefaults.standard.set(true, forKey: "showDevMenu")
        self.view?.reload()
    }
}
