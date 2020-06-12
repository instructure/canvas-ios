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
import SafariServices

private var collapsedIDs: [String: Set<String>] = [:] // [courseID: [moduleID]]

public class ModuleListViewController: UIViewController, ColoredNavViewProtocol, ErrorViewController {
    let refreshControl = CircleRefreshControl()
    @IBOutlet weak var emptyMessageLabel: UILabel!
    @IBOutlet weak var emptyTitleLabel: UILabel!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var errorView: ListErrorView!
    @IBOutlet weak var spinnerView: CircleProgressView!
    @IBOutlet weak var tableView: UITableView!
    public let titleSubtitleView = TitleSubtitleView.create()

    let env = AppEnvironment.shared
    public var color: UIColor?
    var courseID = ""
    var moduleID: String?

    lazy var colors = env.subscribe(GetCustomColors()) { [weak self] in
        self?.reloadCourse()
    }
    lazy var courses = env.subscribe(GetCourse(courseID: courseID)) { [weak self] in
        self?.reloadCourse()
    }
    lazy var modules = env.subscribe(GetModules(courseID: courseID)) { [weak self] in
        self?.update()
    }

    public static func create(courseID: String, moduleID: String? = nil) -> ModuleListViewController {
        let controller = loadFromStoryboard()
        controller.courseID = courseID
        controller.moduleID = moduleID
        return controller
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupTitleViewInNavbar(title: NSLocalizedString("Modules", bundle: .core, comment: ""))

        collapsedIDs[courseID] = collapsedIDs[courseID] ?? []
        if let moduleID = moduleID {
            collapsedIDs[courseID]?.remove(moduleID)
        }

        emptyMessageLabel.text = NSLocalizedString("There are no modules to display yet.", bundle: .core, comment: "")
        emptyTitleLabel.text = NSLocalizedString("No Modules", bundle: .core, comment: "")
        errorView.messageLabel.text = NSLocalizedString("There was an error loading modules. Pull to refresh to try again.", bundle: .core, comment: "")
        errorView.retryButton.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)

        refreshControl.color = nil
        refreshControl.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)
        spinnerView.color = color

        tableView.backgroundColor = .named(.backgroundLightest)
        tableView.refreshControl = refreshControl
        tableView.registerCell(EmptyCell.self)
        tableView.registerHeaderFooterView(ModuleSectionHeaderView.self, fromNib: false)
        if let footer = tableView.tableFooterView as? UILabel {
            footer.isHidden = true
            footer.text = NSLocalizedString("Loading more modules...", bundle: .core, comment: "")
            tableView.contentInset.bottom = -footer.frame.height
        }

        NotificationCenter.default.addObserver(self, selector: #selector(moduleItemViewDidLoad), name: .moduleItemViewDidLoad, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: .moduleItemRequirementCompleted, object: nil)

        courses.refresh()
        colors.refresh()
        modules.refresh()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: false)
        }
        if let color = color {
            navigationController?.navigationBar.useContextColor(color)
        }
    }

    func update() {
        spinnerView.isHidden = !modules.pending || refreshControl.isRefreshing
        emptyView.isHidden = modules.pending || !modules.isEmpty || modules.error != nil
        errorView.isHidden = modules.error == nil
        tableView.tableFooterView?.setNeedsLayout()
        tableView.reloadData()
        scrollToModule()
    }

    func reloadCourse() {
        updateNavBar(subtitle: courses.first?.name, color: courses.first?.color)
        view.tintColor = color
    }

    @objc func refresh() {
        modules.refresh(force: true)
    }

    func isSectionExpanded(_ section: Int) -> Bool {
        guard let module = modules[section] else { return false }
        return collapsedIDs[courseID]?.contains(module.id) != true
    }

    func scrollToModule() {
        if let moduleID = moduleID, let section = modules.all.firstIndex(where: { $0.id == moduleID }) {
            let rect = tableView.rect(forSection: section)
            tableView.setContentOffset(CGPoint(x: 0, y: rect.minY), animated: true)
            self.moduleID = nil
        }
    }

    @objc func moduleItemViewDidLoad(_ notification: Notification) {
        guard
            splitViewController?.isCollapsed == false,
            let userInfo = notification.userInfo,
            let moduleID = userInfo["moduleID"] as? String,
            let itemID = userInfo["itemID"] as? String,
            let section = modules.all.firstIndex(where: { $0.id == moduleID })
        else {
            return
        }
        let module = modules[section]
        guard let row = module?.items.firstIndex(where: { $0.id == itemID }) else { return }
        let indexPath = IndexPath(row: row, section: section)
        if tableView.indexPathsForSelectedRows?.contains(indexPath) == true { return }
        tableView.indexPathsForSelectedRows?.forEach { tableView.deselectRow(at: $0, animated: true) }
        if tableView.cellForRow(at: indexPath) != nil {
            tableView.selectRow(
                at: indexPath,
                animated: true,
                scrollPosition: tableView.indexPathsForVisibleRows?.contains(indexPath) == true
                    ? .none
                    : .bottom
            )
        }
    }
}

extension ModuleListViewController: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return modules.count
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let module = modules[section] else { return nil }
        let header = tableView.dequeueHeaderFooter(ModuleSectionHeaderView.self)
        header.update(module, section: section, isExpanded: isSectionExpanded(section)) { [weak self] in
            self?.toggleSection(section)
        }
        return header
    }

    func toggleSection(_ section: Int) {
        guard let module = modules[section] else { return }
        if isSectionExpanded(section) {
            collapsedIDs[courseID]?.insert(module.id)
        } else {
            collapsedIDs[courseID]?.remove(module.id)
        }
        tableView.reloadSections([section], with: .automatic)
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard isSectionExpanded(section) else { return 0 }
        return max(modules[section]?.items.count ?? 0, 1)
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let module = modules[indexPath.section]
        if indexPath.row == module?.items.count {
            return tableView.dequeue(for: indexPath) as EmptyCell
        }
        let item = module?.items[indexPath.row]
        switch item?.type {
        case .subHeader:
            let cell: ModuleItemSubHeaderCell = tableView.dequeue(for: indexPath)
            if let item = item {
                cell.update(item)
            }
            return cell
        default:
            let cell: ModuleItemCell = tableView.dequeue(for: indexPath)
            if let item = item {
                cell.update(item, indexPath: indexPath)
            }
            return cell
        }
    }
}

extension ModuleListViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let module = modules[indexPath.section], module.items.count > indexPath.row else { return }
        let item = module.items[indexPath.row]
        if let masteryPath = item.masteryPath, masteryPath.needsSelection {
            let viewController = MasteryPathViewController.create(masteryPath: masteryPath)
            viewController.delegate = self
            env.router.show(viewController, from: self)
        }
        guard let htmlURL = item.htmlURL else {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        env.router.route(to: htmlURL, from: self, options: .detail)
    }

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        moduleID = nil // stop auto scrolling
    }
}

extension ModuleListViewController {
    class EmptyCell: UITableViewCell {
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: .default, reuseIdentifier: reuseIdentifier)

            fullDivider = true
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = NSLocalizedString("This module is empty.", bundle: .core, comment: "")
            label.textAlignment = .center
            label.font = .scaledNamedFont(.medium12)
            label.textColor = .named(.textDark)
            contentView.addSubview(label)
            label.pin(inside: contentView, leading: 8, trailing: -8, top: 12, bottom: 12)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

extension ModuleListViewController: MasteryPathDelegate {
    func didSelectMasteryPath(id: String, inModule moduleID: String, item itemID: String) {
        spinnerView.isHidden = false
        let request = PostSelectMasteryPath(
            courseID: courseID,
            moduleID: moduleID,
            moduleItemID: itemID,
            assignmentSetID: id
        )
        env.api.makeRequest(request) { [weak self] _, _, error in performUIUpdate {
            self?.spinnerView.isHidden = true
            if let error = error {
                self?.showError(error)
                return
            }
            self?.refresh()
        } }
    }
}
