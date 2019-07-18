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

protocol ModuleListViewProtocol: ErrorViewController, ColoredNavViewProtocol {
    func reloadModules()
    func reloadCourse()
    func showPending()
    func hidePending()
    func scrollToRow(at indexPath: IndexPath)
    func reloadModuleInSection(_ section: Int)
}

class ModuleListViewController: UIViewController, ModuleListViewProtocol {
    @IBOutlet weak var tableView: UITableView!

    var titleSubtitleView: TitleSubtitleView = TitleSubtitleView.create()

    var presenter: ModuleListPresenter?
    var color: UIColor?

    static func create(courseID: String, moduleID: String? = nil) -> ModuleListViewController {
        let view = loadFromStoryboard()
        let presenter = ModuleListPresenter(env: .shared, view: view, courseID: courseID, moduleID: moduleID)
        view.presenter = presenter
        return view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTitleViewInNavbar(title: NSLocalizedString("Modules", bundle: .teacher, comment: ""))

        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = 54

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.refreshControl = refreshControl

        presenter?.viewIsReady()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: true)
        }
    }

    func reloadModules() {
        tableView.reloadData()
    }

    func reloadCourse() {
        updateNavBar(subtitle: presenter?.course?.name, color: presenter?.course?.color)
        tableView.reloadData() // update icon course colors
    }

    @objc
    func refresh() {
        presenter?.forceRefresh()
    }

    func showPending() {
        tableView.refreshControl?.beginRefreshing()
    }

    func hidePending() {
        tableView.refreshControl?.endRefreshing()
    }

    func scrollToRow(at indexPath: IndexPath) {
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }

    func reloadModuleInSection(_ section: Int) {
        tableView.reloadSections([section], with: .automatic)
    }
}

extension ModuleListViewController: UITableViewDataSource { 
    func numberOfSections(in tableView: UITableView) -> Int {
        return presenter?.modules.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if presenter?.isSectionExpanded(section) == true {
            return presenter?.modules[section]?.items.count ?? 0
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = presenter?.modules[indexPath.section]?.items[indexPath.row]
        switch item?.type {
        case .subHeader?:
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
            cell.tintColor = presenter?.course?.color
            return cell
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let module = presenter?.modules[section] else {
            return nil
        }
        let header = ModuleSectionHeaderView()
        header.title = module.name
        header.published = module.published
        header.onTap = {
            self.presenter?.tappedSection(section)
        }
        let expanded = presenter?.isSectionExpanded(section) == true
        header.collapsableIndicator.setCollapsed(!expanded, animated: true)
        return header
    }
}

extension ModuleListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = presenter?.modules[indexPath.section]?.items[indexPath.row] else { return }
        switch item.type {
        case .externalTool(let id, _)?:
            LTITools(id: id).presentToolInSFSafariViewController(from: self, animated: true) { [weak tableView] _ in
                tableView?.deselectRow(at: indexPath, animated: true)
            }
        case .externalURL(let url)?:
            let safari = SFSafariViewController(url: url)
            safari.modalPresentationStyle = .overFullScreen
            present(safari, animated: true) {
                tableView.deselectRow(at: indexPath, animated: true)
            }
        default:
            presenter?.showItem(item, from: self)
        }
    }
}

extension ModuleListViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isBottomReached() {
            presenter?.getNextPage()
        }
    }
}
