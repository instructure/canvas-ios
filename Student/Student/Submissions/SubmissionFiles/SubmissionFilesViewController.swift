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

class SubmissionFilesViewController: UIViewController {
    var files: [File] = []
    weak var presenter: SubmissionDetailsPresenter?
    @IBOutlet weak var emptyLabel: DynamicLabel?
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var emptyContainer: UIView!
    @IBOutlet weak var emptyImageView: UIImageView!

    static func create(files: [File]?, presenter: SubmissionDetailsPresenter?) -> SubmissionFilesViewController {
        let controller = loadFromStoryboard()
        controller.files = files ?? []
        controller.presenter = presenter
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundLightest
        tableView?.tintColor = .textInfo
        emptyLabel?.text = String(localized: "There are no files for this assignment.", bundle: .student)
        emptyContainer?.isHidden = !files.isEmpty
        emptyImageView?.image = UIImage(named: Panda.Papers.name, in: .core, compatibleWith: nil)
    }
}

extension SubmissionFilesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let file = files[indexPath.row]
        let cell = tableView.dequeue(SubmissionFilesCell.self, for: indexPath)
        cell.backgroundColor = .backgroundLightest
        cell.titleLabel?.text = file.displayName
        if let url = file.thumbnailURL {
            cell.iconView?.load(url: url)
        } else {
            cell.iconView?.image = file.icon
        }
        cell.checkView?.isHidden = (file.id != presenter?.selectedFileID)
        let fileID = file.id ?? ""
        cell.checkView?.tintColor = presenter?.course.first?.color
        cell.checkView?.accessibilityIdentifier = "SubmissionFiles.cell.\(fileID).checkView"
        cell.checkView?.isAccessibilityElement = !UIAccessibility.isSwitchControlRunning
        cell.accessibilityIdentifier = "SubmissionFiles.cell.\(fileID)"
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let id = files[indexPath.row].id {
            presenter?.select(fileID: id)
        }
        tableView.reloadData()
    }
}
