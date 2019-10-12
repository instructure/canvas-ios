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
import UIKit

@available(iOS 13, *)
protocol CourseSearchFilterOptionsDelegate: class {
    func courseSearchFilterOptions(_ filterOptions: CourseSearchFilterOptionsViewController, didChangeFilter filter: CourseSearchFilter)
}

@available(iOS 13, *)
class CourseSearchFilterOptionsViewController: UIViewController, UITableViewDelegate, ItemPickerDelegate {
    enum Section: CaseIterable {
        case main, term
    }

    enum ItemType: Hashable {
        case hideCoursesWithoutStudents
        case term
    }

    enum TermSection: Int {
        case all, active, past
    }

    let tableView = UITableView(frame: .zero, style: .grouped)
    var dataSource: UITableViewDiffableDataSource<Section, ItemType>!

    var filter = CourseSearchFilter()
    var terms: [APITerm] = [] {
        didSet {
            activeTerms = terms.filter { $0.workflow_state == .active }
            pastTerms = terms.filter { term in
                if let endAt = term.end_at, endAt < Clock.now {
                    return true
                }
                return false
            }
        }
    }
    private var pastTerms: [APITerm] = []
    private var activeTerms: [APITerm] = []
    weak var delegate: CourseSearchFilterOptionsDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Filter", comment: "")
        let reset = UIBarButtonItem(title: NSLocalizedString("Reset", comment: ""), style: .plain, target: self, action: #selector(resetButtonPressed))
        navigationItem.rightBarButtonItem = reset
        tableView.backgroundColor = .named(.backgroundLight)
        configureTableView()
        configureDataSource()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: true)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.courseSearchFilterOptions(self, didChangeFilter: filter)
    }

    func configureTableView() {
        tableView.delegate = self
        tableView.registerCell(RightDetailTableViewCell.self)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        tableView.pin(inside: view)
    }

    func configureDataSource() {
        dataSource = UITableViewDiffableDataSource(tableView: tableView) { [weak self] tableView, indexPath, item in
            let cell = tableView.dequeue(for: indexPath) as RightDetailTableViewCell
            switch item {
            case .hideCoursesWithoutStudents:
                cell.textLabel?.text = NSLocalizedString("Hide courses without students", comment: "")
                cell.detailTextLabel?.text = nil
                cell.accessoryType = self?.filter.hideCoursesWithoutStudents == true ? .checkmark : .none
            case .term:
                cell.textLabel?.text = NSLocalizedString("Show courses from", comment: "")
                cell.detailTextLabel?.text = self?.filter.term?.name ?? NSLocalizedString("All Terms", comment: "")
                cell.accessoryType = .disclosureIndicator
            }

            return cell
        }
        resetData()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        switch item {
        case .hideCoursesWithoutStudents:
            self.filter.hideCoursesWithoutStudents = self.filter.hideCoursesWithoutStudents == true ? nil : true
            var snapshot = dataSource.snapshot()
            snapshot.reloadItems([.hideCoursesWithoutStudents])
            dataSource.apply(snapshot)
        case .term:
            var selected: IndexPath?
            if let selectedTerm = filter.term {
                if let activeRow = activeTerms.firstIndex(of: selectedTerm) {
                    selected = IndexPath(row: activeRow, section: 1)
                } else if let pastRow = pastTerms.firstIndex(of: selectedTerm) {
                    selected = IndexPath(row: pastRow, section: 2)
                }
            } else {
                selected = IndexPath(row: 0, section: 0)
            }
            let picker = ItemPickerViewController.create(
                title: NSLocalizedString("Term", comment: ""),
                sections: [
                    ItemPickerSection(items: [ItemPickerItem(title: NSLocalizedString("All Terms", comment: ""))]),
                    ItemPickerSection(
                        title: NSLocalizedString("Active", comment: ""),
                        items: activeTerms.map { ItemPickerItem(title: $0.name) }
                    ),
                    ItemPickerSection(
                        title: NSLocalizedString("Past", comment: ""),
                        items: pastTerms.map { ItemPickerItem(title: $0.name) }
                    ),
                ],
                selected: selected,
                delegate: self
            )
            show(picker, sender: self)
        }
    }

    func itemPicker(_ itemPicker: ItemPickerViewController, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            filter.term = activeTerms[indexPath.row]
        case 2:
            filter.term = pastTerms[indexPath.row]
        default:
            filter.term = nil
        }
        var snapshot = dataSource.snapshot()
        snapshot.reloadItems([.term])
        dataSource.apply(snapshot)
    }

    @objc func resetButtonPressed() {
        filter = CourseSearchFilter()
        resetData()
    }

    func resetData() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, ItemType>()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems([.hideCoursesWithoutStudents], toSection: .main)
        snapshot.appendItems([.term], toSection: .term)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}
