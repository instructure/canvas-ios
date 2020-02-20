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
    var presenter: PostGradesPresenter!
    var viewModel: APIPostPolicyInfo?
    var color: UIColor = .named(.electric)

    static func create(courseID: String, assignmentID: String) -> HideGradesViewController {
        let controller = loadFromStoryboard()
        controller.presenter = PostGradesPresenter(courseID: courseID, assignmentID: assignmentID, view: controller)
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupSections()

        allGradesHiddenView.backgroundColor = .named(.backgroundLightest)
        allGradesHiddenView.isHidden = true
        allHiddenLabel.text = NSLocalizedString("All Hidden", comment: "")
        allHiddenSubHeader.text = NSLocalizedString("All grades are currently hidden.", comment: "")

        hideGradesButton.setTitle(NSLocalizedString("Hide Grades", comment: ""), for: .normal)

        presenter.viewIsReady()
    }

    func setupTableView() {
        tableView.backgroundColor = .named(.backgroundGrouped)
        tableView.registerCell(PostGradesViewController.SectionCell.self)
    }

    func setupSections() {
        sectionToggles = Array(repeating: false, count: viewModel?.sections.count ?? 0)
    }

    @IBAction func actionUserDidClickHideGrades(_ sender: Any) {
        let sectionIDs = sectionToggles.enumerated().compactMap { i, s in s ? viewModel?.sections[i].id : nil }
        presenter.hideGrades(sectionIDs: sectionIDs)

    }
}

extension HideGradesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (showSections ? (viewModel?.sections.count ?? 0) : 0) + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: PostGradesViewController.SectionCell = tableView.dequeue(for: indexPath)
        cell.toggle.onTintColor = Brand.shared.buttonPrimaryBackground

        if indexPath.row == 0 {
            cell.textLabel?.text = NSLocalizedString("Specific Sections", comment: "")
            cell.selectionStyle = .none
            cell.toggle.isOn = showSections
            cell.toggle.accessibilityIdentifier = "PostPolicy.toggleHideGradeSections"
            cell.toggle.addTarget(self, action: #selector(actionDidToggleShowSections(sender:)), for: UIControl.Event.valueChanged)
        } else {    //  sections
            let index = abs(indexPath.row - 1)
            cell.textLabel?.text = viewModel?.sections[index].name
            cell.toggle.accessibilityIdentifier = "PostPolicy.hide.section.toggle.\(viewModel?.sections[index].id ?? "")"
            cell.selectionStyle = .none
            cell.toggle.isOn = sectionToggles[index]
            cell.toggle.tag = index
            cell.toggle.addTarget(self, action: #selector(actionDidToggleSection(toggle:)), for: UIControl.Event.valueChanged)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            let localizedFormat = NSLocalizedString("grades_currently_posted", comment: "number of grades hidden")
            return String(format: localizedFormat, viewModel?.submissions.postedCount ?? 0)
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

extension HideGradesViewController: PostGradesViewProtocol {
    func update(_ viewModel: APIPostPolicyInfo) {
        self.viewModel = viewModel
        setupSections()
        tableView.reloadData()
    }

    func didHideGrades() {
        dismiss(animated: true, completion: nil)
    }

    func updateCourseColor(_ color: UIColor) {
        self.color = color
    }

    func showAllHiddenView() {
        allGradesHiddenView.isHidden = false
    }
}
