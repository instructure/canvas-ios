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
    private var sectionToggles: [Bool] = []
    private var gradesCurrentlyPosted = 0
    fileprivate var showSections = false
    @IBOutlet weak var allGradesHiddenView: UIView!
    @IBOutlet weak var allHiddenLabel: DynamicLabel!
    @IBOutlet weak var allHiddenSubHeader: DynamicLabel!
    var presenter: PostGradesPresenter!
    private lazy var paging = PagingPresenter(controller: self)
    var viewModel = APIPostPolicy()
    var color: UIColor = .textInfo

    static func create(courseID: String, assignmentID: String) -> HideGradesViewController {
        let controller = loadFromStoryboard()
        controller.presenter = PostGradesPresenter(courseID: courseID, assignmentID: assignmentID, view: controller)
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupSections()
        view.backgroundColor = .backgroundLightest
        allGradesHiddenView.backgroundColor = .backgroundLightest
        allGradesHiddenView.isHidden = true
        allHiddenLabel.text = String(localized: "All Hidden", bundle: .teacher)
        allHiddenSubHeader.text = String(localized: "All grades are currently hidden.", bundle: .teacher)

        hideGradesButton.setTitle(String(localized: "Hide Grades", bundle: .teacher), for: .normal)
        hideGradesButton.setTitleColor(.textLightest, for: .normal)
        hideGradesButton.textStyle = UIFont.Name.semibold16.rawValue
        hideGradesButton.backgroundColor = .textInfo

        presenter.viewIsReady()
    }

    func setupTableView() {
        tableView.backgroundColor = .backgroundGrouped
        tableView.registerCell(PostGradesViewController.SectionCell.self)
        tableView.registerCell(PageLoadingCell.self)
    }

    func setupSections() {
        sectionToggles = Array(repeating: false, count: viewModel.sectionsCount)
    }

    @IBAction func actionUserDidClickHideGrades(_ sender: Any) {
        let sectionIDs = sectionToggles.enumerated().compactMap { i, s in s ? viewModel.sections?[i].id : nil }
        presenter.hideGrades(sectionIDs: sectionIDs)

    }
}

extension HideGradesViewController: UITableViewDelegate, UITableViewDataSource {

    private var rowsCount: Int {
        return (showSections ? viewModel.sectionsCount : 0) + 1
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return showSections ? (paging.hasMore ? 2 : 1) : 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? rowsCount : 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.section == 0 else {
            return tableView
                .dequeue(PageLoadingCell.self, for: indexPath)
                .setup(with: paging)
        }

        let cell: PostGradesViewController.SectionCell = tableView.dequeue(for: indexPath)
        cell.toggle.tintColor = Brand.shared.buttonPrimaryBackground

        if indexPath.row == 0 {
            cell.textLabel?.text = String(localized: "Specific Sections", bundle: .teacher)
            cell.selectionStyle = .none
            cell.toggle.accessibilityLabel = cell.textLabel?.text
            cell.toggle.isOn = showSections
            cell.toggle.accessibilityIdentifier = "PostPolicy.toggleHideGradeSections"
            cell.toggle.addTarget(self, action: #selector(actionDidToggleShowSections(sender:)), for: UIControl.Event.valueChanged)
        } else {    //  sections
            let index = abs(indexPath.row - 1)
            cell.textLabel?.text = viewModel.sections?[index].name
            cell.toggle.accessibilityLabel = cell.textLabel?.text
            cell.toggle.accessibilityIdentifier = "PostPolicy.hide.section.toggle.\(viewModel.sections?[index].id ?? "")"
            cell.selectionStyle = .none
            cell.toggle.isOn = sectionToggles[index]
            cell.toggle.tag = index
            cell.toggle.addTarget(self, action: #selector(actionDidToggleSection(toggle:)), for: UIControl.Event.valueChanged)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            let localizedFormat = String(localized: "grades_currently_posted", bundle: .teacher, comment: "number of grades hidden")
            return String(format: localizedFormat, viewModel.submissions?.postedCount ?? 0)
        }
        return nil
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        paging.willDisplayRow(at: indexPath)
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        paging.willSelectRow(at: indexPath)
        return indexPath
    }

    @objc
    func actionDidToggleShowSections(sender: CoreSwitch) {
        showSections = sender.isOn
        tableView.reloadData()
    }

    @objc
    func actionDidToggleSection(toggle: CoreSwitch) {
        sectionToggles[toggle.tag] = toggle.isOn
    }
}

extension HideGradesViewController: PostGradesViewProtocol {
    func update(_ newModel: APIPostPolicy) {
        self.viewModel = newModel
        self.paging.onPageLoaded(newModel)
        setupSections()
        tableView.reloadData()
    }

    func nextPageLoadingFailed(_ error: any Error) {
        self.paging.onPageLoadingFailed()
    }

    func nextPageLoaded(_ newModel: APIPostPolicy) {
        let newSectionsCount = max(newModel.sectionsCount - self.viewModel.sectionsCount, 0)
        sectionToggles.append(contentsOf: Array(repeating: false, count: newSectionsCount))
        self.viewModel = newModel
        self.paging.onPageLoaded(newModel)
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

extension HideGradesViewController: PagingViewController {
    typealias Page = APIPostPolicy

    func isMoreRow(at indexPath: IndexPath) -> Bool {
        return indexPath.section == 1 && indexPath.row == 0
    }

    func loadNextPage() {
        presenter.fetchNextPage(to: viewModel)
    }
}
