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
import Core

class ConversationListViewController: UIViewController {
    @IBOutlet weak var emptyView: EmptyView!
    @IBOutlet weak var tableView: UITableView!

    static func create() -> ConversationListViewController {
        return loadFromStoryboard()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .named(.backgroundLightest)
        title = NSLocalizedString("Inbox", comment: "")

        emptyView.titleText = NSLocalizedString("Inbox Zero", comment: "")
        emptyView.bodyText = NSLocalizedString("You’re all caught up", comment: "")
        // emptyView.isHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.useModalStyle()
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}
