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
import CanvasKeymaster

public class ProfilePresenter: ProfilePresenterProtocol {
    let env: AppEnvironment
    public weak var view: ProfileViewControllerProtocol?

    #if DEBUG
    var showDevMenu = true
    #else
    var showDevMenu = UserDefaults.standard.bool(forKey: "showDevMenu")
    #endif

    lazy var permissions: Store<GetContextPermissions> = {
        let useCase = GetContextPermissions(context: ContextModel(.account, id: "self"), permissions: [.becomeUser])
        return env.subscribe(useCase) { [weak self] in
            self?.view?.reload()
        }
    }()

    var canMasquerade: Bool {
        if env.currentSession?.actAsUserID != nil {
            return false
        }

        if env.api.baseURL.absoluteString.contains("siteadmin.instructure.com") {
            return true
        }

        return self.permissions.first?.becomeUser ?? false
    }

    public var cells: [ProfileViewCell] {
        var cells: [ProfileViewCell] = []

        if self.canMasquerade {
            cells.append(ProfileViewCell(
                name: NSLocalizedString("Act as User", bundle: .parent, comment: ""),
                block: { [weak self] _ in
                    self?.view?.show(.actAsUser, options: [.modal, .embedInNav])
                }
            ))
        }

        cells.append(contentsOf: [
            ProfileViewCell(
                name: NSLocalizedString("Manage Children", bundle: .parent, comment: ""),
                block: { [weak self] _ in
                    self?.view?.show(.profileObservees, options: nil)
                }
            ),
            ProfileViewCell(
                name: NSLocalizedString("Help", bundle: .parent, comment: ""),
                block: { [weak self] cell in
                    self?.showHelpMenu(source: cell)
                }
            ),
            ProfileViewCell(
                name: NSLocalizedString("Change User", bundle: .parent, comment: ""),
                block: { _ in
                    guard let delegate = UIApplication.shared.delegate as? ParentAppDelegate else { return }
                    delegate.changeUser()
                }
            ),
            ProfileViewCell(
                name: NSLocalizedString("Log Out", bundle: .parent, comment: ""),
                block: { _ in
                    guard let delegate = UIApplication.shared.delegate as? ParentAppDelegate else { return }
                    guard let session = delegate.environment.currentSession else { return }
                    delegate.userDidLogout(keychainEntry: session)
                }
            )
        ])

        if env.currentSession?.actAsUserID != nil {
            cells.append(ProfileViewCell(
                name: NSLocalizedString("Stop Act as User", bundle: .parent, comment: ""),
                block: { _ in
                    guard let delegate = UIApplication.shared.delegate as? ParentAppDelegate else { return }
                    guard let session = delegate.environment.currentSession else { return }
                    delegate.stopActing(as: session)
                }
            ))
        }

        if showDevMenu {
            cells.append(ProfileViewCell(
                name: NSLocalizedString("Developer Menu", bundle: .parent, comment: ""),
                block: { [weak self] _ in
                    self?.view?.show(.developerMenu, options: [.modal, .embedInNav ])
                }
            ))
        }
        return cells
    }

    init(env: AppEnvironment = .shared) {
        self.env = env
    }

    public func viewIsReady() {
        permissions.refresh(force: true)
    }

    public func didTapVersion() {
        showDevMenu = true
        UserDefaults.standard.set(true, forKey: "showDevMenu")
        self.view?.reload()
    }

    func showHelpMenu(source cell: UITableViewCell) {
        let helpMenu = UIAlertController(title: NSLocalizedString("Help", bundle: .parent, comment: ""), message: nil, preferredStyle: .actionSheet)

        helpMenu.addAction(UIAlertAction(title: NSLocalizedString("View Canvas Guides", bundle: .parent, comment: ""), style: .default) { [weak self] _ in
            self?.view?.show("https://community.canvaslms.com/docs/DOC-9919", options: .modal)
        })

        helpMenu.addAction(UIAlertAction(title: NSLocalizedString("Report a Problem", bundle: .parent, comment: ""), style: .default) { [weak self] _ in
            self?.view?.show(.sendSupport(forType: "problem"), options: .modal)
        })

        helpMenu.addAction(UIAlertAction(title: NSLocalizedString("Request a Feature", bundle: .parent, comment: ""), style: .default) { [weak self] _ in
            self?.view?.show(.sendSupport(forType: "feature"), options: .modal)
        })

        helpMenu.addAction(UIAlertAction(title: NSLocalizedString("Terms of Use", bundle: .parent, comment: ""), style: .default) { [weak self] _ in
            self?.view?.show(.termsOfService(forAccount: "self"), options: [.modal, .embedInNav])
        })

        helpMenu.addAction(UIAlertAction(title: NSLocalizedString("Cancel", bundle: .parent, comment: ""), style: .cancel))

        helpMenu.popoverPresentationController?.sourceView = cell
        helpMenu.popoverPresentationController?.sourceRect = CGRect(origin: CGPoint(x: cell.bounds.maxX, y: cell.bounds.midY), size: .zero)
        view?.present(helpMenu, animated: true, completion: nil)
    }
}
