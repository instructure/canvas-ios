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

public struct ItemPickerItem: Equatable {
    let image: UIImage?
    let title: String
    let subtitle: String?
    let accessibilityIdentifier: String?

    public init(image: UIImage? = nil, title: String, subtitle: String? = nil, accessibilityIdentifier: String? = nil) {
        self.image = image
        self.title = title
        self.subtitle = subtitle
        self.accessibilityIdentifier = accessibilityIdentifier
    }
}

public protocol ItemPickerDelegate: AnyObject {
    func itemPicker(_ itemPicker: ItemPickerViewController, didSelectRowAt indexPath: IndexPath)
}

public class ItemPickerViewController: UIViewController {
    weak var delegate: ItemPickerDelegate?
    var didSelect: ((IndexPath) -> Void)?
    var sections: [ItemPickerSection] = []
    var selected: IndexPath?

    let tableView = UITableView(frame: .zero, style: .grouped)

    public static func create(
        title: String,
        sections: [ItemPickerSection],
        selected: IndexPath?,
        delegate: ItemPickerDelegate? = nil,
        didSelect: ((IndexPath) -> Void)? = nil
    ) -> ItemPickerViewController {
        let controller = ItemPickerViewController()
        controller.delegate = delegate
        controller.didSelect = didSelect
        controller.sections = sections
        controller.selected = selected
        controller.title = title
        return controller
    }

    public override func loadView() {
        view = tableView
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundLightest
        tableView.backgroundColor = .backgroundGrouped
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerHeaderFooterView(GroupedSectionHeaderView.self, fromNib: false)
        tableView.registerCell(RightDetailTableViewCell.self)
        tableView.registerCell(SubtitleTableViewCell.self)
        tableView.separatorColor = .borderMedium
        tableView.separatorInset = .zero
        tableView.tintColor = Brand.shared.primary

        tableView.isAccessibilityElement = true
        tableView.accessibilityLabel = String.localizedAccessibilityListCount(sections[0].items.count)
    }
}

extension ItemPickerViewController: UITableViewDataSource, UITableViewDelegate {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sectionTitle = sections[section].title else { return nil }

        let header: GroupedSectionHeaderView = tableView.dequeueHeaderFooter()
        let section = sections[section]
        header.update(title: sectionTitle, itemCount: section.items.count)
        return header
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return (section == 0 && sections[section].title == nil) ? 0 : UITableView.automaticDimension
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = sections[indexPath.section].items[indexPath.row]
        let cell: UITableViewCell
        if let subtitle = item.subtitle, !subtitle.isEmpty {
            cell = tableView.dequeue(for: indexPath) as SubtitleTableViewCell
            cell.detailTextLabel?.text = subtitle
        } else {
            cell = tableView.dequeue(for: indexPath) as RightDetailTableViewCell
        }
        cell.backgroundColor = .backgroundLightest
        cell.imageView?.image = item.image
        cell.textLabel?.text = item.title
        cell.accessibilityTraits.insert(.button)
        if let accessibilityIdentifier = item.accessibilityIdentifier {
            cell.accessibilityIdentifier = accessibilityIdentifier
        } else {
            cell.accessibilityIdentifier = "ItemPickerItem.\(indexPath.section)-\(indexPath.row)"
        }
        if indexPath == selected {
            let image = UIImageView(frame: CGRect(x: 0, y: 0, width: 18, height: 18))
            image.image = .checkSolid
            cell.accessoryView = image
            cell.accessibilityTraits.insert(.selected)
        } else {
            cell.accessoryView = nil
            cell.accessibilityTraits.remove(.selected)
        }
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selected = indexPath
        delegate?.itemPicker(self, didSelectRowAt: indexPath)
        didSelect?(indexPath)
        tableView.deselectRow(at: indexPath, animated: false)
        tableView.reloadData()
    }
}
