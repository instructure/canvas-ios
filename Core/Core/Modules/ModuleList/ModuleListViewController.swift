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

public class ModuleListViewController: UIViewController, ColoredNavViewProtocol {
    let refreshControl = CircleRefreshControl()
    @IBOutlet weak var emptyMessageLabel: UILabel!
    @IBOutlet weak var emptyTitleLabel: UILabel!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var errorView: ListErrorView!
    @IBOutlet weak var spinnerView: CircleProgressView!
    @IBOutlet weak var tableView: UITableView!
    public let titleSubtitleView = TitleSubtitleView.create()

    struct Section {
        var module: APIModule
        var nextItems: GetNextRequest<[APIModuleItem]>?
        var nextItemsPending: Bool = false
    }

    let env = AppEnvironment.shared
    public var color: UIColor?
    var courseID = ""
    var data: [String: Section] = [:]
    var moduleID: String?
    var modules: [APIModule] {
        return data.values.map { $0.module }.sorted { $0.position < $1.position }
    }
    var nextPage: GetNextRequest<[APIModule]>?

    lazy var colors = env.subscribe(GetCustomColors()) { [weak self] in
        self?.reloadCourse()
    }
    lazy var courses = env.subscribe(GetCourse(courseID: courseID)) { [weak self] in
        self?.reloadCourse()
    }
    lazy var store = ModuleStore(courseID: courseID)

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
        tableView.registerCell(LoadingCell.self)
        tableView.registerHeaderFooterView(ModuleSectionHeaderView.self, fromNib: false)
        if let footer = tableView.tableFooterView as? UILabel {
            footer.isHidden = true
            footer.text = NSLocalizedString("Loading more modules...", bundle: .core, comment: "")
            tableView.contentInset.bottom = -footer.frame.height
        }

        NotificationCenter.default.addObserver(self, selector: #selector(moduleItemViewDidLoad), name: .moduleItemViewDidLoad, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshProgress), name: .moduleItemRequirementCompleted, object: nil)

        courses.refresh()
        colors.refresh()

        store.delegate = self
        store.refresh()
        moduleStoreDidChange(store)
        if !store.shouldRefresh {
            scrollToModule()
        }
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

    func reloadCourse() {
        updateNavBar(subtitle: courses.first?.name, color: courses.first?.color)
        view.tintColor = color
    }

    @objc func refresh() {
        errorView.isHidden = true
        store.refresh(force: true)
    }

    @objc func refreshProgress() {
        errorView.isHidden = true
        spinnerView.isHidden = false
        store.refresh(force: true)
    }

    func isSectionExpanded(_ section: Int) -> Bool {
        return collapsedIDs[courseID]?.contains(store[section].id) == false
    }

    func showLoadingNextPage() {
        tableView.contentInset.bottom = 0
        tableView.tableFooterView?.isHidden = false
    }

    func hideLoadingNextPage() {
        let footerHeight = tableView.tableFooterView?.frame.height ?? 0
        tableView.contentInset.bottom = -footerHeight
        tableView.tableFooterView?.isHidden = true
    }

    func scrollToModule() {
        if let moduleID = moduleID, let section = store.sectionForModule(moduleID) {
            let rect = tableView.rect(forSection: section)
            tableView.setContentOffset(CGPoint(x: 0, y: rect.minY), animated: true)
        }
    }

    @objc func moduleItemViewDidLoad(_ notification: Notification) {
        guard
            splitViewController?.isCollapsed == false,
            let userInfo = notification.userInfo,
            let moduleID = userInfo["moduleID"] as? String,
            let itemID = userInfo["itemID"] as? String,
            let section = store.sectionForModule(moduleID)
        else {
            return
        }
        let module = store[section]
        guard let row = module.items.firstIndex(where: { $0.id == itemID }) else { return }
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
        return store.count
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let module = store[section]
        let header = tableView.dequeueHeaderFooter(ModuleSectionHeaderView.self)
        header.update(module, isExpanded: isSectionExpanded(section)) { [weak self] in
            self?.toggleSection(section)
        }
        return header
    }

    func toggleSection(_ section: Int) {
        let module = store[section]
        if isSectionExpanded(section) {
            let remove = (0..<tableView.numberOfRows(inSection: section)).map { IndexPath(row: $0, section: section) }
            collapsedIDs[courseID]?.insert(module.id)
            tableView.deleteRows(at: remove, with: .automatic)
        } else {
            collapsedIDs[courseID]?.remove(module.id)
            let add = (0..<tableView(tableView, numberOfRowsInSection: section)).map { IndexPath(row: $0, section: section) }
            tableView.insertRows(at: add, with: .automatic)
        }
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let module = store[section]
        if isSectionExpanded(section) == true {
            if store.isLoadingItemsForModule(module.id) {
                return module.items.count + 1 // loading cell
            }
            if module.items.count == 0 {
                return 1 // empty cell
            }
            return module.items.count
        }
        return 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let module = store[indexPath.section]
        if indexPath.row == module.items.count {
            if store.isLoadingItemsForModule(module.id) {
                return tableView.dequeue(for: indexPath) as LoadingCell
            }
            return tableView.dequeue(for: indexPath) as EmptyCell
        }
        let item = module.items[indexPath.row]
        switch item.type {
        case .subHeader:
            let cell: ModuleItemSubHeaderCell = tableView.dequeue(for: indexPath)
            cell.update(item)
            return cell
        default:
            let cell: ModuleItemCell = tableView.dequeue(for: indexPath)
            cell.update(item)
            return cell
        }
    }
}

extension ModuleListViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard store.count > indexPath.section, store[indexPath.section].items.count > indexPath.row else { return }
        let item = store[indexPath.section].items[indexPath.row]
        guard let htmlURL = item.htmlURL else { return }
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

extension ModuleListViewController: ModuleStoreDelegate {
    func moduleStoreDidChange(_ moduleStore: ModuleStore) {
        if store.isLoading {
            spinnerView.isHidden = refreshControl.isRefreshing
            if store.count > 0 {
                emptyView.isHidden = true
                showLoadingNextPage()
            }
        } else {
            emptyView.isHidden = store.count > 0
            spinnerView.isHidden = true
            refreshControl.endRefreshing()
            hideLoadingNextPage()
        }
        let selected = tableView.indexPathForSelectedRow
        tableView.reloadData()
        if let selected = selected, tableView.cellForRow(at: selected) != nil {
            tableView.selectRow(at: selected, animated: false, scrollPosition: .none)
        }
        scrollToModule()
    }

    func moduleStoreDidEncounterError(_ error: Error) {
        errorView.isHidden = false
    }
}
