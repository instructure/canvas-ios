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

public struct ItemPickerSection {
    let title: String?
    let items: [ItemPickerItem]

    public init(title: String? = nil, items: [ItemPickerItem]) {
        self.title = title
        self.items = items
    }
}

public struct ItemPickerItem {
    let title: String
    let subtitle: String?

    public init(title: String, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }
}

public class ItemPickerCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var subtitleLabel: UILabel?
}

public protocol ItemPickerDelegate: class {
    func itemPicker(_ itemPicker: ItemPickerViewController, didSelectRowAt indexPath: IndexPath)
}

public class ItemPickerViewController: UITableViewController {
    weak var delegate: ItemPickerDelegate?
    var sections: [ItemPickerSection] = []
    var selected: IndexPath?

    public static func create(title: String, sections: [ItemPickerSection], selected: IndexPath?, delegate: ItemPickerDelegate?) -> ItemPickerViewController {
        let controller = loadFromStoryboard()
        controller.delegate = delegate
        controller.sections = sections
        controller.selected = selected
        controller.title = title
        return controller
    }

    public override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = sections[indexPath.section].items[indexPath.row]
        let cell: ItemPickerCell = tableView.dequeue(for: indexPath)
        cell.titleLabel?.text = item.title
        cell.subtitleLabel?.text = item.subtitle
        cell.accessoryType = indexPath == selected ? .checkmark : .none
        return cell
    }

    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selected = indexPath
        delegate?.itemPicker(self, didSelectRowAt: indexPath)
        tableView.deselectRow(at: indexPath, animated: false)
        tableView.reloadData()
    }
}
