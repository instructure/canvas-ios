//
// Copyright (C) 2016-present Instructure, Inc.
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


import CanvasCore


struct SettingsObserveeCellViewModel: TableViewCellViewModel {
    let name: String
    let studentID: String
    let avatarURL: URL?
    let highlightColor: UIColor

    init(student: Student, highlightColor: UIColor) {
        name = student.sortableName
        avatarURL = student.avatarURL
        studentID = student.id
        self.highlightColor = highlightColor
    }

    static func tableViewDidLoad(_ tableView: UITableView) {
        tableView.estimatedRowHeight = 64
        tableView.register(UINib(nibName: "SettingsObserveeCell", bundle: Bundle(for: SettingsObserveeCell.self)), forCellReuseIdentifier: "SettingsObserveeCell")
    }

    func cellForTableView(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsObserveeCell", for: indexPath) as? SettingsObserveeCell else {
            fatalError("Incorrect cell type found. Expected: SettingsObserveeCell")
        }

        cell.highlightColor = highlightColor
        cell.nameLabel?.text = name
        cell.nameLabel?.accessibilityIdentifier = "observee_name_\(indexPath.row)"
        cell.avatarImageView?.accessibilityIdentifier = "observee_avatar_\(indexPath.row)"

        if let avatarURL = avatarURL {
            cell.avatarImageView?.kf.setImage(with: avatarURL, placeholder: DefaultAvatarCoordinator.defaultAvatarForStudentID(studentID))
        }

        return cell
    }

}
