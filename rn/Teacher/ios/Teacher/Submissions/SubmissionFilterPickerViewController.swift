//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

class SubmissionFilterPickerViewController: UIViewController {
    let tableView = UITableView(frame: .zero, style: .plain)
    lazy var resetButton = UIBarButtonItem(title: String(localized: "Reset", bundle: .teacher), style: .plain, target: self, action: #selector(resetFilter))
    lazy var doneButton = UIBarButtonItem(title: String(localized: "Done", bundle: .teacher), style: .done, target: self, action: #selector(done))

    var assignmentID = ""
    var context = Context.currentUser
    let env = AppEnvironment.shared
    var filter: GetSubmissions.Filter?
    var onChange: ([GetSubmissions.Filter]) -> Void = { _ in }
    var outOfText: String?
    var sectionIDs: Set<String> = []
    let staticFilters: [GetSubmissions.Filter?] = [ nil, .late, .notSubmitted, .needsGrading, .graded ]

    lazy var sections = env.subscribe(GetCourseSections(courseID: context.id)) { [weak self] in
        self?.tableView.reloadData()
    }

    static func create(
        context: Context,
        outOfText: String?,
        filter: [GetSubmissions.Filter],
        onChange: @escaping ([GetSubmissions.Filter]) -> Void
    ) -> SubmissionFilterPickerViewController {
        let controller = SubmissionFilterPickerViewController()
        controller.context = context
        controller.outOfText = outOfText
        for f in filter {
            if case .section(let sectionIDs) = f {
                controller.sectionIDs = sectionIDs
            } else {
                controller.filter = f
            }
        }
        controller.onChange = onChange
        return controller
    }

    public override func loadView() {
        view = tableView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = String(localized: "Filter by", bundle: .teacher)
        navigationItem.leftBarButtonItem = resetButton
        navigationItem.rightBarButtonItem = doneButton

        view.backgroundColor = .backgroundLightest
        tableView.backgroundColor = .backgroundLightest
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerCell(RightDetailTableViewCell.self)
        tableView.separatorColor = .borderMedium
        tableView.separatorInset = .zero
        tableView.tintColor = Brand.shared.primary
        tableView.tableFooterView = UIView()

        sections.exhaust()
    }

    @objc func resetFilter() {
        filter = nil
        sectionIDs = []
        tableView.reloadData()
    }

    @objc func done() {
        var filter: [GetSubmissions.Filter] = []
        if let selected = self.filter {
            filter.append(selected)
        }
        if !sectionIDs.isEmpty {
            filter.append(.section(sectionIDs))
        }
        onChange(filter)
        env.router.dismiss(self)
    }
}

extension SubmissionFilterPickerViewController: UITableViewDataSource, UITableViewDelegate {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return staticFilters.count
        case 1:
            return 2
        default:
            return sections.count
        }
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: RightDetailTableViewCell = tableView.dequeue(for: indexPath)
        var isSelected = false
        switch (indexPath.section, indexPath.row) {
        case (0, let row):
            cell.textLabel?.text = staticFilters[row]?.name ?? String(localized: "All submissions", bundle: .teacher)
            isSelected = filter == staticFilters[row]
        case (1, 0):
            if case .scoreBelow = filter {
                cell.textLabel?.text = filter?.name
                isSelected = true
            } else {
                cell.textLabel?.text = String(localized: "Scored below...", bundle: .teacher)
            }
        case (1, 1):
            if case .scoreAbove = filter {
                cell.textLabel?.text = filter?.name
                isSelected = true
            } else {
                cell.textLabel?.text = String(localized: "Scored above...", bundle: .teacher)
            }
        case (_, let row):
            cell.textLabel?.text = sections[row]?.name
            isSelected = sections[row].map { sectionIDs.contains($0.id) } == true
        }
        cell.backgroundColor = .backgroundLightest
        cell.accessibilityIdentifier = "SubmissionFilterPicker.\(indexPath.section).\(indexPath.row)"
        cell.accessibilityTraits.insert(.button)
        if isSelected {
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
        switch (indexPath.section, indexPath.row) {
        case (0, let row):
            filter = staticFilters[row]
        case (1, let row):
            let prompt = UIAlertController(
                title: row == 0 ? String(localized: "Scored below...", bundle: .teacher) : String(localized: "Scored above...", bundle: .teacher),
                message: outOfText,
                preferredStyle: .alert
            )
            prompt.addTextField { field in
                field.keyboardType = .decimalPad
                field.accessibilityLabel = String(localized: "Points", bundle: .teacher)
            }
            prompt.addAction(AlertAction(String(localized: "Cancel", bundle: .teacher), style: .cancel))
            prompt.addAction(AlertAction(String(localized: "OK", bundle: .teacher), style: .default) { [weak self] _ in
                let text = prompt.textFields?[0].text?.trimmingCharacters(in: .whitespacesAndNewlines)
                guard let score = text.flatMap({ NumberFormatter().number(from: $0) })?.doubleValue else { return }
                self?.filter = row == 0 ? .scoreBelow(score) : .scoreAbove(score)
                self?.tableView.reloadData()
            })
            env.router.show(prompt, from: self, options: .modal())
        case (_, let row):
            if let sectionID = sections[row]?.id {
                if sectionIDs.contains(sectionID) {
                    sectionIDs.remove(sectionID)
                } else {
                    sectionIDs.insert(sectionID)
                }
            }
        }
        tableView.deselectRow(at: indexPath, animated: false)
        tableView.reloadData()
    }
}
