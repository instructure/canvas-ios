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
import Core
import SafariServices

private var collapsedIDs: [String: Set<String>] = [:] // [courseID: [moduleID]]

class ModuleListViewController: UIViewController, ErrorViewController, ColoredNavViewProtocol {
    @IBOutlet weak var tableView: UITableView!
    struct Section {
        var module: APIModule
        var nextItems: GetNextRequest<[APIModuleItem]>?
        var nextItemsPending: Bool = false
    }

    var titleSubtitleView: TitleSubtitleView = TitleSubtitleView.create()

    var env: AppEnvironment!
    var courseID: String!
    var moduleID: String?
    var color: UIColor?
    var data: [String: Section] = [:]
    var modules: [APIModule] {
        return data.values.map { $0.module }.sorted { $0.position < $1.position }
    }
    var nextPage: GetNextRequest<[APIModule]>?

    lazy var courses = env.subscribe(GetCourse(courseID: courseID)) { [weak self] in
        self?.reloadCourse()
    }

    lazy var colors = env.subscribe(GetCustomColors()) { [weak self] in
        self?.reloadCourse()
    }

    var store: ModuleStore!

    static func create(env: AppEnvironment = .shared, courseID: String, moduleID: String? = nil) -> ModuleListViewController {
        let view = loadFromStoryboard()
        view.env = env
        view.courseID = courseID
        view.moduleID = moduleID
        let modules = ModuleStore(courseID: courseID)
        modules.delegate = view
        view.store = modules
        return view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        collapsedIDs[courseID] = collapsedIDs[courseID] ?? []
        if let moduleID = moduleID {
            collapsedIDs[courseID]?.remove(moduleID)
        }
        setupTitleViewInNavbar(title: NSLocalizedString("Modules", bundle: .teacher, comment: ""))
        configureTableView()
        configureFooter()
        courses.refresh()
        colors.refresh()
        store.refresh()
        tableView.reloadData()
        if !store.shouldRefresh {
            scrollToModule()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: true)
        }
    }

    func configureTableView() {
        tableView.backgroundColor = .named(.backgroundLightest)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = 54
        tableView.registerCell(LoadingCell.self)
        tableView.registerCell(EmptyCell.self)
        tableView.registerHeaderFooterView(ModuleSectionHeaderView.self, fromNib: false)

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }

    func configureFooter() {
        let footer = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 20))
        footer.text = NSLocalizedString("Loading more modules...", comment: "")
        footer.font = .scaledNamedFont(.medium12)
        footer.textColor = .named(.textDark)
        footer.textAlignment = .center
        footer.isHidden = true
        tableView.tableFooterView = footer
        tableView.contentInset.bottom = -footer.frame.height
    }

    func reloadCourse() {
        updateNavBar(subtitle: courses.first?.name, color: courses.first?.color)
        tableView.reloadData() // update icon course colors
    }

    @objc
    func refresh() {
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
}

extension ModuleListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return store.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
            cell.label.text = item.title
            cell.isUserInteractionEnabled = false
            cell.accessoryType = .none
            cell.publishedIconView.published = item.published
            cell.indent = item.indent
            return cell
        default:
            let cell: ModuleItemCell = tableView.dequeue(for: indexPath)
            cell.item = item
            cell.accessoryType = .disclosureIndicator
            cell.tintColor = courses.first?.color
            return cell
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let module = store[section]
        let header = tableView.dequeueHeaderFooter(ModuleSectionHeaderView.self)
        header.title = module.name
        header.published = module.published
        header.onTap = { [weak self] in
            guard let self = self else { return }
            let expanded = self.isSectionExpanded(section)
            if expanded {
                collapsedIDs[self.courseID]?.insert(module.id)
            } else {
                collapsedIDs[self.courseID]?.remove(module.id)
            }
            tableView.reloadSections([section], with: .automatic)
        }
        let expanded = isSectionExpanded(section) == true
        header.collapsableIndicator.setCollapsed(!expanded, animated: true)
        return header
    }
}

extension ModuleListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard store.count > indexPath.section, store[indexPath.section].items.count > indexPath.row else { return }
        let item = store[indexPath.section].items[indexPath.row]
        switch item.type {
        case .externalTool(let id, _):
            let lti = LTITools(context: ContextModel(.course, id: courseID), id: id, launchType: .module_item, moduleItemID: item.id)
            lti.presentTool(from: self, animated: true) { [weak tableView] _ in
                tableView?.deselectRow(at: indexPath, animated: true)
            }
        case .externalURL(let url):
            let safari = SFSafariViewController(url: url)
            safari.modalPresentationStyle = .overFullScreen
            env.router.show(safari, from: self, options: .modal()) {
                tableView.deselectRow(at: indexPath, animated: true)
            }
        default:
            if let url = item.url {
                env.router.route(to: url, from: self, options: .detail())
            }
        }
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        moduleID = nil // stop auto scrolling
    }
}

extension ModuleListViewController {
    class LoadingCell: UITableViewCell {
        let activity: UIActivityIndicatorView

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            activity = UIActivityIndicatorView(style: .gray)
            activity.startAnimating()
            activity.translatesAutoresizingMaskIntoConstraints = false
            super.init(style: .default, reuseIdentifier: reuseIdentifier)
            contentView.addSubview(activity)
            activity.pin(inside: contentView)
            activity.heightAnchor.constraint(equalToConstant: 44).isActive = true
            fullDivider = true
        }

        override func prepareForReuse() {
            super.prepareForReuse()
            activity.startAnimating()
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    class EmptyCell: UITableViewCell {
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: .default, reuseIdentifier: reuseIdentifier)

            fullDivider = true
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = NSLocalizedString("This module is empty.", comment: "")
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
            if store.count > 0 {
                showLoadingNextPage()
            } else {
                tableView.refreshControl?.beginRefreshing()
            }
        } else {
            tableView.refreshControl?.endRefreshing()
            hideLoadingNextPage()
        }
        tableView.reloadData()
        scrollToModule()
    }

    func moduleStoreDidEncounterError(_ error: Error) {
        showError(error)
    }
}
