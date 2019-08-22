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

    enum PostToVisisbility: String, CaseIterable {
        case everyone, graded

        var title: String {
            switch self {
            case .everyone:
                return NSLocalizedString("Everyone", comment: "")
            case .graded:
                return NSLocalizedString("Graded", comment: "")
            }
        }

        var subHeader: String {
            switch self {
            case .everyone:
                return NSLocalizedString("Grades will be made visible to all students", comment: "")
            case .graded:
                return NSLocalizedString("Grades will be made visible to students with graded submissions", comment: "")
            }
        }
    }
    @IBOutlet weak var allGradesPostedView: UIView!
    @IBOutlet weak var allGradesPostedLabel: DynamicLabel!
    @IBOutlet weak var allGradesPostedSubheader: DynamicLabel!
    private var sections: [String] = []
    private var showSections: Bool = false
    private var sectionToggles: [Bool] = []
    private var gradesCurrentlyHidden = 0
    private var visibility: PostToVisisbility = .everyone

    static func create() -> PostGradesViewController {
        let controller = loadFromStoryboard()
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupSections()

        postGradesButton.setTitle(NSLocalizedString("Post Grades", comment: ""), for: .normal)

        allGradesPostedView.isHidden = true
        allGradesPostedLabel.text = NSLocalizedString("All Posted", comment: "")
        allGradesPostedSubheader.text = NSLocalizedString("All grades are currently posted.", comment: "")
    }

    func setupTableView() {
        tableView.registerCell(SectionCell.self)
        tableView.registerCell(PostToCell.self)
    }

    func setupSections() {
        sections = ["section A", "section B"]     // FIXME: remove these static sections once we have real sections
        sectionToggles = Array(repeating: false, count: sections.count)
    }

    @IBAction func actionUserDidClickPostGrades(_ sender: Any) {
        print(#function)
    }
}

extension PostGradesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Row.allCases.count +  (showSections ? sections.count : 0)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        if indexPath.row == 0 {
            cell = tableView.dequeue(for: indexPath) as PostToCell
        } else {
            cell = tableView.dequeue(for: indexPath) as SectionCell
        }

        if indexPath.row < Row.allCases.count { //  first two rows (Row enum)
            if let row = Row(rawValue: indexPath.row) {
                switch row {
                case .postTo:
                    cell.textLabel?.text = NSLocalizedString("Post to...", comment: "")
                    cell.detailTextLabel?.text = visibility.title
                    cell.accessoryType = .disclosureIndicator
                    cell.selectionStyle = .default
                case .section:
                    cell.textLabel?.text = NSLocalizedString("Specific Sections", comment: "")
                    cell.selectionStyle = .none
                    if let cell = cell as? SectionCell {
                        cell.toggle.removeTarget(self, action: #selector(actionDidToggleShowSections(sender:)), for: UIControl.Event.valueChanged)
                        cell.toggle.isOn = showSections
                        cell.toggle.addTarget(self, action: #selector(actionDidToggleShowSections(sender:)), for: UIControl.Event.valueChanged)
                    }
                }
            }
        } else {    //  sections
            let index = abs(indexPath.row - Row.allCases.count)
            cell.textLabel?.text = sections[index]
            cell.selectionStyle = .none
            if let cell = cell as? SectionCell {
                cell.toggle.removeTarget(self, action: #selector(actionDidToggleSection(toggle:)), for: UIControl.Event.valueChanged)
                cell.toggle.isOn = sectionToggles[index]
                cell.toggle.tag = index
                cell.toggle.addTarget(self, action: #selector(actionDidToggleSection(toggle:)), for: UIControl.Event.valueChanged)
            }
        }

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            let localizedFormat = NSLocalizedString("grades_currently_hidden", comment: "number of grades hidden")
            return String(format: localizedFormat, gradesCurrentlyHidden)
        }
        return nil
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if let row = Row(rawValue: indexPath.row), row == .postTo {
            let vc = PostToVisibilitySelectionViewController.create(visibility: visibility, delegate: self)
            navigationController?.pushViewController(vc, animated: true)
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
            accessoryView = toggle
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    class PostToCell: UITableViewCell {
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

extension PostGradesViewController: PostToVisibilitySelectionDelegate {
    func visibilityDidChange(visibility: PostGradesViewController.PostToVisisbility) {
        self.visibility = visibility
        tableView.reloadData()
    }
}
