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

protocol PostToVisibilitySelectionDelegate: class {
    func visibilityDidChange(visibility: PostGradePolicy)
}

class PostToVisibilitySelectionViewController: UITableViewController {

    var selectedVisibility: PostGradePolicy = .everyone
    weak var delegate: PostToVisibilitySelectionDelegate?

    static func create(visibility: PostGradePolicy, delegate: PostToVisibilitySelectionDelegate?) -> PostToVisibilitySelectionViewController {
        let controller = loadFromStoryboard()
        controller.selectedVisibility = visibility
        controller.delegate = delegate
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Post to...", comment: "")
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PostGradePolicy.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(for: indexPath)

        let row = PostGradePolicy.allCases[indexPath.row]
        cell.detailTextLabel?.numberOfLines = 0
        cell.textLabel?.text = row.title
        cell.textLabel?.font = UIFont.scaledNamedFont(.semibold16)
        cell.detailTextLabel?.font = UIFont.scaledNamedFont(.semibold12)
        cell.detailTextLabel?.textColor = .named(.textDark)
        cell.detailTextLabel?.text = row.subHeader
        cell.accessoryType = row == selectedVisibility ? .checkmark : .none

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedVisibility = PostGradePolicy.allCases[indexPath.row]
        tableView.reloadData()
        delegate?.visibilityDidChange(visibility: selectedVisibility)
    }
}
