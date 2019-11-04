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

protocol ModuleListViewProtocol: ErrorViewController, ColoredNavViewProtocol {
    func reloadModules()
    func reloadCourse()
    func showPending()
    func hidePending()
    func scrollToRow(at indexPath: IndexPath)
    func reloadModuleInSection(_ section: Int)
}

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

    static func create(env: AppEnvironment = .shared, courseID: String, moduleID: String? = nil) -> ModuleListViewController {
        let view = loadFromStoryboard()
        view.env = env
        view.courseID = courseID
        view.moduleID = moduleID
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
        reloadData()
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
        tableView.contentInset.bottom -= footer.frame.height
    }

    func reloadData() {
        showPending()
        let request = GetModulesRequest(courseID: courseID)
        let callback = { [weak self] (response: [APIModule]?, urlResponse: URLResponse?, error: Error?) -> Void in
            performUIUpdate {
                self?.hidePending()
                guard let response = response else {
                    self?.showError(error ?? NSError.internalError())
                    return
                }
                self?.data = response.reduce(into: [:]) { result, module in
                    result[module.id.value] = Section(module: module)
                }
                self?.nextPage = urlResponse.flatMap { request.getNext(from: $0) }
                self?.tableView.reloadData()
                response.filter { $0.items == nil }.forEach { self?.getItems(for: $0) }
                self?.scrollToModule()
            }
        }
        if moduleID != nil {
            env.api.exhaust(request, callback: callback)
        } else {
            env.api.makeRequest(request, callback: callback)
        }
    }

    func reloadCourse() {
        updateNavBar(subtitle: courses.first?.name, color: courses.first?.color)
        tableView.reloadData() // update icon course colors
    }

    @objc
    func refresh() {
        reloadData()
    }

    func showPending() {
        tableView.refreshControl?.beginRefreshing()
    }

    func hidePending() {
        tableView.refreshControl?.endRefreshing()
    }

    func scrollToModule() {
        guard let moduleID = moduleID else { return }
        self.moduleID = nil
        if let section = modules.enumerated().first(where: { $0.1.id.value == moduleID })?.0 {
            let indexPath = IndexPath(row: 0, section: section)
            if tableView.numberOfRows(inSection: section) > 0 {
                tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            }
        }
    }

    func getItems(for module: APIModule) {
        let request = GetModuleItemsRequest(courseID: courseID, moduleID: module.id.value)
        let callback: ([APIModuleItem]?, URLResponse?, Error?) -> Void = { [weak self] response, urlResponse, _ in
            guard let self = self else { return }
            performUIUpdate {
                let next = urlResponse.flatMap { request.getNext(from: $0) }
                var module = module
                module.items = (module.items ?? []) + (response ?? [])
                self.data[module.id.value] = Section(module: module, nextItems: next, nextItemsPending: false)
                self.tableView.reloadData()
            }
        }
        if let next = data[module.id.value]?.nextItems {
            self.data[module.id.value]?.nextItemsPending = true
            env.api.makeRequest(next, callback: callback)
        } else {
            env.api.makeRequest(request, callback: callback)
        }
    }

    func getNextPage() {
        guard let nextPage = nextPage else { return }
        self.nextPage = nil
        let contentInset = tableView.contentInset
        tableView.contentInset.bottom = 0
        tableView.tableFooterView?.isHidden = false
        env.api.makeRequest(nextPage) { [weak self] response, urlResponse, error in
            performUIUpdate {
                self?.tableView.contentInset = contentInset
                self?.tableView.tableFooterView?.isHidden = true
                guard let response = response else {
                    self?.showError(error ?? NSError.internalError())
                    return
                }
                self?.nextPage = urlResponse.flatMap { nextPage.getNext(from: $0) }
                for module in response {
                    self?.data[module.id.value] = Section(module: module)
                    self?.tableView.reloadData()
                    response.filter { $0.items == nil }.forEach { self?.getItems(for: $0) }
                    self?.scrollToModule()
                }
            }
        }
    }

    func isSectionExpanded(_ section: Int) -> Bool {
        return collapsedIDs[courseID]?.contains(modules[section].id.value) == false
    }
}

extension ModuleListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return modules.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let module = modules[section]
        if isSectionExpanded(section) == true {
            if let items = module.items {
                if data[module.id.value]?.nextItems != nil {
                    return items.count + 1 // load next page of items
                }
                return max(items.count, 1) // count or empty cell
            }
            return 1 // loading first page of items
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let module = modules[indexPath.section]
        if module.items == nil {
            return tableView.dequeue(for: indexPath) as LoadingCell
        }
        if module.items?.isEmpty == true {
            return tableView.dequeue(for: indexPath) as EmptyCell
        }
        if let items = module.items, indexPath.row == items.count {
            if data[module.id.value]?.nextItemsPending == false {
                getItems(for: module)
            }
            return tableView.dequeue(for: indexPath) as LoadingCell
        }
        let item = module.items?[indexPath.row]
        switch item?.content {
        case .subHeader:
            let cell: ModuleItemSubHeaderCell = tableView.dequeue(for: indexPath)
            cell.label.text = item?.title
            cell.isUserInteractionEnabled = false
            cell.accessoryType = .none
            cell.publishedIconView.published = item?.published == true
            cell.indent = item?.indent ?? 0
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
        let module = modules[section]
        let header = tableView.dequeueHeaderFooter(ModuleSectionHeaderView.self)
        header.title = module.name
        header.published = module.published
        header.onTap = { [weak self] in
            guard let self = self else { return }
            let expanded = self.isSectionExpanded(section)
            if expanded {
                collapsedIDs[self.courseID]?.insert(module.id.value)
            } else {
                collapsedIDs[self.courseID]?.remove(module.id.value)
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
        guard let item = modules[indexPath.section].items?[indexPath.row] else { return }
        switch item.content {
        case .externalTool(let id, _):
            LTITools(context: ContextModel(.course, id: courseID), id: id).presentToolInSFSafariViewController(from: self, animated: true) { [weak tableView] _ in
                tableView?.deselectRow(at: indexPath, animated: true)
            }
        case .externalURL(let url):
            let safari = SFSafariViewController(url: url)
            safari.modalPresentationStyle = .overFullScreen
            env.router.show(safari, from: self, options: [.modal])
            tableView.deselectRow(at: indexPath, animated: true)
        default:
            if let url = item.url {
                env.router.route(to: url, from: self, options: [.detail])
            }
        }
    }
}

extension ModuleListViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isBottomReached() {
            getNextPage()
        }
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
