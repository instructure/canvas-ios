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

import UIKit
import Core

class SubmissionFilesViewController: UIViewController {
    var files: [File] = []
    weak var presenter: SubmissionDetailsPresenter?
    @IBOutlet weak var emptyLabel: DynamicLabel?
    @IBOutlet weak var tableView: UITableView?

    static func create(files: [File]?, presenter: SubmissionDetailsPresenter?) -> SubmissionFilesViewController {
        let controller = loadFromStoryboard()
        controller.files = files ?? []
        controller.presenter = presenter
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView?.separatorColor = .named(.borderMedium)
        tableView?.tintColor = .named(.textInfo)
        emptyLabel?.text = NSLocalizedString("There are no files to display.", bundle: .student, comment: "")
        emptyLabel?.isHidden = !files.isEmpty
    }
}

extension SubmissionFilesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let file = files[indexPath.row]
        let cell = tableView.dequeue(SubmissionFilesCell.self, for: indexPath)
        cell.titleLabel?.text = file.displayName
        if let url = file.thumbnailURL {
            cell.iconView?.load(url: url)
        } else {
            cell.iconView?.image = file.icon
        }
        cell.checkView?.isHidden = (file.id != presenter?.selectedFileID)
        cell.checkView?.accessibilityIdentifier = "SubmissionFilesElement.cell.\(file.id).checkView"
        cell.accessibilityIdentifier = "SubmissionFilesElement.cell.\(file.id)"
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter?.select(fileID: files[indexPath.row].id)
        tableView.reloadData()
    }
}
