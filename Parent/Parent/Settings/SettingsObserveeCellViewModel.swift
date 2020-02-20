//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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
import CanvasCore

struct SettingsObserveeCellViewModel: TableViewCellViewModel {
    let name: String
    let studentID: String
    let avatarURL: URL?
    let highlightColor: UIColor

    init(student: Student, highlightColor: UIColor) {
        name = Core.User.displayName(student.shortName, pronouns: student.pronouns)
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
        cell.avatarImageView?.name = name
        cell.avatarImageView?.url = avatarURL

        return cell
    }

}
