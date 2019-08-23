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

class HideGradesViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var hideGradesButton: DynamicButton!
    private var sections: [String] = []
    private var sectionToggles: [Bool] = []
    private var gradesCurrentlyPosted = 0
    private var showSections = false
    @IBOutlet weak var allGradesHiddenView: UIView!
    @IBOutlet weak var allHiddenLabel: DynamicLabel!
    @IBOutlet weak var allHiddenSubHeader: DynamicLabel!

    static func create() -> HideGradesViewController {
        let controller = loadFromStoryboard()
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupSections()

        allGradesHiddenView.isHidden = true
        allHiddenLabel.text = NSLocalizedString("All Hidden", comment: "")
        allHiddenSubHeader.text = NSLocalizedString("All grades are currently hidden.", comment: "")

        hideGradesButton.setTitle(NSLocalizedString("Hide Grades", comment: ""), for: .normal)
    }

    func setupTableView() {
        tableView.registerCell(PostGradesViewController.SectionCell.self)
    }

    func setupSections() {
        sections = ["section A", "section B"]     // FIXME: remove these static sections once we have real sections
        sectionToggles = Array(repeating: false, count: sections.count)
    }

    @IBAction func actionUserDidClickHideGrades(_ sender: Any) {
        print(#function)
    }
}

extension HideGradesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (showSections ? sections.count : 0) + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: PostGradesViewController.SectionCell = tableView.dequeue(for: indexPath)

        if indexPath.row == 0 {
            cell.textLabel?.text = NSLocalizedString("Specific Sections", comment: "")
            cell.selectionStyle = .none
            cell.toggle.isOn = showSections
            cell.toggle.addTarget(self, action: #selector(actionDidToggleShowSections(sender:)), for: UIControl.Event.valueChanged)
        } else {    //  sections
            let index = abs(indexPath.row - 1)
            cell.textLabel?.text = sections[index]
            cell.selectionStyle = .none
            cell.toggle.isOn = sectionToggles[index]
            cell.toggle.tag = index
            cell.toggle.addTarget(self, action: #selector(actionDidToggleSection(toggle:)), for: UIControl.Event.valueChanged)

        }

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            let localized = NSLocalizedString("grades_currently_posted", comment: "number of grades posted")
            return String(format: localized, gradesCurrentlyPosted)
        }
        return nil
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
}
