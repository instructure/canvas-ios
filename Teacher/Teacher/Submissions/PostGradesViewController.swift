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
    lazy var paging = PagingPresenter(controller: self)
    var presenter: PostGradesPresenter!
    var viewModel = APIPostPolicy()
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
        postGradesButton.setTitleColor(.textLightest, for: .normal)
        postGradesButton.textStyle = UIFont.Name.semibold16.rawValue
        postGradesButton.backgroundColor = .textInfo

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
        tableView.registerCell(PageLoadingCell.self)
    }

    func setupSections() {
        sectionToggles = Array(repeating: false, count: viewModel.sectionsCount)
    }

    @IBAction func actionUserDidClickPostGrades(_ sender: Any) {
        let sectionIDs = sectionToggles.enumerated().compactMap { i, s in s ? viewModel.sections?[i].id : nil }
        presenter.postGrades(postPolicy: postPolicy, sectionIDs: sectionIDs)
    }
}

extension PostGradesViewController: UITableViewDelegate, UITableViewDataSource {

    private var rowsCount: Int {
        return Row.allCases.count +  (showSections ? viewModel.sectionsCount : 0)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? rowsCount : 1
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return showSections ? (paging.hasMore ? 2 : 1) : 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.section == 0 else {
            return tableView
                .dequeue(PageLoadingCell.self, for: indexPath)
                .setup(with: paging)
        }

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
                cell.setupInstDisclosureIndicator()
                cell.selectionStyle = .default
                cell.accessibilityIdentifier = "PostPolicy.postTo"
            case .section:
                cell.textLabel?.text = String(localized: "Specific Sections", bundle: .teacher)
                cell.selectionStyle = .none
                if let cell = cell as? SectionCell {
                    cell.toggle.accessibilityLabel = cell.textLabel?.text
                    cell.toggle.isOn = showSections
                    cell.toggle.tintColor = Brand.shared.buttonPrimaryBackground
                    cell.toggle.accessibilityIdentifier = "PostPolicy.togglePostToSections"
                    cell.toggle.addTarget(self, action: #selector(actionDidToggleShowSections(sender:)), for: UIControl.Event.valueChanged)
                }
            }
        } else {    //  sections
            let index = abs(indexPath.row - Row.allCases.count)
            cell.textLabel?.text = viewModel.sections?[index].name
            cell.selectionStyle = .none
            if let cell = cell as? SectionCell {
                cell.toggle.accessibilityLabel = cell.textLabel?.text
                cell.toggle.isOn = sectionToggles[index]
                cell.toggle.tag = index
                cell.toggle.tintColor = Brand.shared.buttonPrimaryBackground
                cell.toggle.accessibilityIdentifier = "PostPolicy.post.section.toggle.\(viewModel.sections?[index].id ?? "")"
                cell.toggle.addTarget(self, action: #selector(actionDidToggleSection(toggle:)), for: UIControl.Event.valueChanged)
            }
        }

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            let localizedFormat = String(localized: "grades_currently_hidden", bundle: .teacher, comment: "number of grades hidden")
            return String(format: localizedFormat, viewModel.submissions?.hiddenCount ?? 0)
        }
        return nil
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if let row = Row(rawValue: indexPath.row), row == .postTo {
            let pageTitle = String(localized: "Post to...", bundle: .teacher)
            let allCases = PostGradePolicy.allCases

            let picker = ItemPickerScreen(
                pageTitle: pageTitle,
                identifierGroup: "PostPolicy.postToOptions",
                allOptions: allCases.map { OptionItem(id: $0.optionItemId, title: $0.title, subtitle: $0.subtitle) },
                initialOptionId: postPolicy.optionItemId,
                didSelectOption: { [weak self] in
                    guard let selectedCase = allCases.element(for: $0) else { return }

                    self?.postPolicy = selectedCase
                    self?.tableView.reloadData()
                }
            )

            let pickerVC = CoreHostingController(picker)
            pickerVC.navigationItem.title = pageTitle
            show(pickerVC, sender: self)
        }
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

    class SectionCell: UITableViewCell {
        var toggle: CoreSwitch

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            toggle = CoreSwitch()
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            backgroundColor = .backgroundLightest
            textLabel?.textColor = .textDarkest
            textLabel?.font = .scaledNamedFont(.semibold16)
            textLabel?.accessibilityElementsHidden = true

            toggle.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(toggle)
            toggle.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
            toggle.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func prepareForReuse() {
            super.prepareForReuse()
            toggle.removeTarget(nil, action: nil, for: .valueChanged)
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

extension PostGradesViewController: PostGradesViewProtocol {
    func update(_ viewModel: APIPostPolicy) {
        self.viewModel = viewModel
        self.paging.onPageLoaded(viewModel)
        setupSections()
        tableView.reloadData()
    }

    func nextPageLoadingFailed(_ error: any Error) {
        self.paging.onPageLoadingFailed()
    }

    func nextPageLoaded(_ viewModel: APIPostPolicy) {
        let newSectionsCount = max(viewModel.sectionsCount - self.viewModel.sectionsCount, 0)
        sectionToggles.append(contentsOf: Array(repeating: false, count: newSectionsCount))
        self.viewModel = viewModel
        self.paging.onPageLoaded(viewModel)
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

extension PostGradesViewController: PagingViewController {
    typealias Page = APIPostPolicy

    func isMoreRow(at indexPath: IndexPath) -> Bool {
        indexPath.section == 1 && indexPath.row == 0
    }

    func reloadMorePageRow() {
        tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .none)
    }

    func loadNextPage() {
        presenter.fetchNextPage(to: viewModel)
    }
}
