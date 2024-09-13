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

class PostGradesViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var postGradesButton: DynamicButton!

    private enum Row: Int, CaseIterable {
        case postTo, section
    }

    @IBOutlet weak var allGradesPostedView: UIView!
    @IBOutlet weak var allGradesPostedLabel: DynamicLabel!
    @IBOutlet weak var allGradesPostedSubheader: DynamicLabel!
    private var showSections: Bool = false
    private var sectionToggles: [Bool] = []
    private var postPolicy: PostGradePolicy = .everyone
    var presenter: PostGradesPresenter!
    var viewModel: APIPostPolicyInfo?
    var color: UIColor = .textInfo

    static func create(courseID: String, assignmentID: String) -> PostGradesViewController {
        let controller = loadFromStoryboard()
        controller.presenter = PostGradesPresenter(courseID: courseID, assignmentID: assignmentID, view: controller)
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupSections()

        view.backgroundColor = .backgroundLightest
        postGradesButton.setTitle(String(localized: "Post Grades", bundle: .teacher), for: .normal)

        allGradesPostedView.backgroundColor = .backgroundLightest
        allGradesPostedView.isHidden = true
        allGradesPostedLabel.text = String(localized: "All Posted", bundle: .teacher)
        allGradesPostedSubheader.text = String(localized: "All grades are currently posted.", bundle: .teacher)
        presenter.viewIsReady()
    }

    func setupTableView() {
        tableView.backgroundColor = .backgroundGrouped
        tableView.registerCell(SectionCell.self)
        tableView.registerCell(PostToCell.self)
    }

    func setupSections() {
        sectionToggles = Array(repeating: false, count: viewModel?.sections.count ?? 0)
    }

    @IBAction func actionUserDidClickPostGrades(_ sender: Any) {
        let sectionIDs = sectionToggles.enumerated().compactMap { i, s in s ? viewModel?.sections[i].id : nil }
        presenter.postGrades(postPolicy: postPolicy, sectionIDs: sectionIDs)
    }
}

extension PostGradesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Row.allCases.count +  (showSections ? (viewModel?.sections.count ?? 0) : 0)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        if indexPath.row == 0 {
            cell = tableView.dequeue(for: indexPath) as PostToCell
        } else {
            cell = tableView.dequeue(for: indexPath) as SectionCell
        }

        cell.textLabel?.font = UIFont.scaledNamedFont(.semibold16)

        if let row = Row(rawValue: indexPath.row) {
            switch row {
            case .postTo:
                cell.textLabel?.text = String(localized: "Post to...", bundle: .teacher)
                cell.detailTextLabel?.text = postPolicy.title
                cell.detailTextLabel?.accessibilityIdentifier = "PostPolicy.postToValue"
                cell.accessoryType = .disclosureIndicator
                cell.selectionStyle = .default
                cell.accessibilityIdentifier = "PostPolicy.postTo"
            case .section:
                cell.textLabel?.text = String(localized: "Specific Sections", bundle: .teacher)
                cell.selectionStyle = .none
                if let cell = cell as? SectionCell {
                    cell.toggle.isOn = showSections
                    cell.toggle.onTintColor = Brand.shared.buttonPrimaryBackground
                    cell.toggle.accessibilityIdentifier = "PostPolicy.togglePostToSections"
                    cell.toggle.addTarget(self, action: #selector(actionDidToggleShowSections(sender:)), for: UIControl.Event.valueChanged)
                }
            }
        } else {    //  sections
            let index = abs(indexPath.row - Row.allCases.count)
            cell.textLabel?.text = viewModel?.sections[index].name
            cell.selectionStyle = .none
            if let cell = cell as? SectionCell {
                cell.toggle.isOn = sectionToggles[index]
                cell.toggle.tag = index
                cell.toggle.onTintColor = Brand.shared.buttonPrimaryBackground
                cell.toggle.accessibilityIdentifier = "PostPolicy.post.section.toggle.\(viewModel?.sections[index].id ?? "")"
                cell.toggle.addTarget(self, action: #selector(actionDidToggleSection(toggle:)), for: UIControl.Event.valueChanged)
            }
        }

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            let localizedFormat = String(localized: "grades_currently_hidden", bundle: .teacher, comment: "number of grades hidden")
            return String(format: localizedFormat, viewModel?.submissions.hiddenCount ?? 0)
        }
        return nil
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if let row = Row(rawValue: indexPath.row), row == .postTo {
            show(ItemPickerViewController.create(
                title: String(localized: "Post to...", bundle: .teacher),
                sections: [ ItemPickerSection(items: PostGradePolicy.allCases.map {
                    ItemPickerItem(title: $0.title, subtitle: $0.subtitle, accessibilityIdentifier: "PostToSelection.\($0.rawValue)")
                }) ],
                selected: PostGradePolicy.allCases.firstIndex(of: postPolicy).flatMap {
                    IndexPath(row: $0, section: 0)
                },
                delegate: self
            ), sender: self)
        }
    }

    @objc
    func actionDidToggleShowSections(sender: UISwitch) {
        showSections = sender.isOn
        tableView.reloadData()
    }

    @objc
    func actionDidToggleSection(toggle: UISwitch) {
        sectionToggles[toggle.tag] = toggle.isOn
    }

    class SectionCell: UITableViewCell {
        var toggle: UISwitch

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            toggle = UISwitch(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            backgroundColor = .backgroundLightest
            textLabel?.textColor = .textDarkest
            textLabel?.font = .scaledNamedFont(.semibold16)
            accessoryView = toggle
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    class PostToCell: UITableViewCell {
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: .value1, reuseIdentifier: reuseIdentifier)
            backgroundColor = .backgroundLightest
            textLabel?.textColor = .textDarkest
            textLabel?.font = .scaledNamedFont(.semibold16)
            detailTextLabel?.font = .scaledNamedFont(.medium16)
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

extension PostGradesViewController: ItemPickerDelegate {
    func itemPicker(_ itemPicker: ItemPickerViewController, didSelectRowAt indexPath: IndexPath) {
        postPolicy = PostGradePolicy.allCases[indexPath.row]
        tableView.reloadData()
    }
}

extension PostGradesViewController: PostGradesViewProtocol {
    func update(_ viewModel: APIPostPolicyInfo) {
        self.viewModel = viewModel
        setupSections()
        tableView.reloadData()
    }

    func didPostGrades() {
        dismiss(animated: true, completion: nil)
    }

    func updateCourseColor(_ color: UIColor) {
        self.color = color
        tableView.reloadData()
    }

    func showAllPostedView() {
        allGradesPostedView.isHidden = false
    }
}

extension PostGradePolicy {
    var title: String {
        switch self {
        case .everyone:
            return String(localized: "Everyone", bundle: .teacher)
        case .graded:
            return String(localized: "Graded", bundle: .teacher)
        }
    }

    var subtitle: String {
        switch self {
        case .everyone:
            return String(localized: "Grades will be made visible to all students", bundle: .teacher)
        case .graded:
            return String(localized: "Grades will be made visible to students with graded submissions", bundle: .teacher)
        }
    }
}
