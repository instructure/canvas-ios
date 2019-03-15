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

import Foundation
import Core
import CanvasKeymaster

public class ProfilePresenter: ProfilePresenterProtocol {
    #if DEBUG
    var showDevMenu = true
    #else
    var showDevMenu = UserDefaults.standard.bool(forKey: "showDevMenu")
    #endif

    public weak var view: ProfileViewController?
    public var cells: [ProfileViewCell] {
        return [
            ProfileViewCell(
                name: NSLocalizedString("Manage Children", bundle: .parent, comment: ""),
                hidden: false,
                block: { [weak self] in
                    self?.view?.show(.profileObservees)
                }
            ),
            ProfileViewCell(
                name: NSLocalizedString("Help", bundle: .parent, comment: ""),
                hidden: false,
                block: { [weak self] in
                    self?.showHelpMenu()
                }
            ),
            ProfileViewCell(
                name: NSLocalizedString("Change User", bundle: .parent, comment: ""),
                hidden: false,
                block: { CanvasKeymaster.the().switchUser() }
            ),
            ProfileViewCell(
                name: NSLocalizedString("Log Out", bundle: .parent, comment: ""),
                hidden: false,
                block: { CanvasKeymaster.the().logout() }
            ),
            ProfileViewCell(
                name: NSLocalizedString("Developer Menu", bundle: .parent, comment: ""),
                hidden: !showDevMenu,
                block: { [weak self] in
                    self?.view?.show(.developerMenu, options: [.modal, .embedInNav ])
                }
            )
        ]
    }

    public func didTapVersion() {
        showDevMenu = true
        UserDefaults.standard.set(true, forKey: "showDevMenu")
    }

    func showHelpMenu() {
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

        view?.present(helpMenu, animated: true)
    }
}
