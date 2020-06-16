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

public class PageListViewController: UIViewController, ColoredNavViewProtocol {
    @IBOutlet weak var emptyMessageLabel: UILabel!
    @IBOutlet weak var emptyTitleLabel: UILabel!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var errorView: ListErrorView!
    @IBOutlet weak var loadingView: CircleProgressView!
    @IBOutlet weak var tableView: UITableView!
    let refreshControl = CircleRefreshControl()
    public let titleSubtitleView = TitleSubtitleView.create()

    var app = App.student
    var canCreatePage: Bool { app == .teacher || context.contextType == .group }
    public var color: UIColor?
    var context = Context.currentUser
    let env = AppEnvironment.shared
    var selectedFirstPage: Bool = false

    lazy var colors = env.subscribe(GetCustomColors()) { [weak self] in
        self?.updateNavBar()
    }
    lazy var course = env.subscribe(GetCourse(courseID: context.id)) { [weak self] in
        self?.updateNavBar()
    }
    lazy var group = env.subscribe(GetGroup(groupID: context.id)) { [weak self] in
        self?.updateNavBar()
    }
    lazy var frontPage = env.subscribe(GetFrontPage(context: context)) { [weak self] in
        self?.update()
    }
    lazy var pages = env.subscribe(GetPages(context: context)) { [weak self] in
        self?.update()
    }

    public static func create(context: Context, app: App) -> PageListViewController {
        let controller = loadFromStoryboard()
        controller.app = app
        controller.context = context
        return controller
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupTitleViewInNavbar(title: NSLocalizedString("Pages", bundle: .core, comment: ""))
        if canCreatePage {
            let item = UIBarButtonItem(image: .icon(.add, .solid), style: .plain, target: self, action: #selector(createPage))
            item.accessibilityIdentifier = "PageList.add"
            navigationItem.rightBarButtonItem = item
        }

        emptyMessageLabel.text = NSLocalizedString("There are no pages to display yet.", bundle: .core, comment: "")
        emptyTitleLabel.text = NSLocalizedString("No Pages", bundle: .core, comment: "")
        errorView.messageLabel.text = NSLocalizedString("There was an error loading pages. Pull to refresh to try again.", bundle: .core, comment: "")
        errorView.retryButton.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)

        refreshControl.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)
        tableView.backgroundColor = .named(.backgroundLightest)
        tableView.refreshControl = refreshControl
        tableView.separatorColor = .named(.borderMedium)

        colors.refresh()
        frontPage.refresh()
        pages.refresh()
        if context.contextType == .group {
            group.refresh()
        } else {
            course.refresh()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(pageCreated), name: Notification.Name("page-created"), object: nil)
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selected = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selected, animated: true)
        }
        if let color = color {
            navigationController?.navigationBar.useContextColor(color)
        }
        env.pageViewLogger.startTrackingTimeOnViewController()
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        env.pageViewLogger.stopTrackingTimeOnViewController(eventName: "\(context.pathComponent)/pages", attributes: [:])
    }

    func updateNavBar() {
        guard
            let name = context.contextType == .course ? course.first?.name : group.first?.name,
            let color = context.contextType == .course ? course.first?.color : group.first?.color
        else {
            return
        }
        loadingView.color = color
        refreshControl.color = color
        view.tintColor = color
        updateNavBar(subtitle: name, color: color)
    }

    func update() {
        let isLoading = !frontPage.requested || frontPage.pending || !pages.requested || pages.pending
        loadingView.isHidden = pages.error != nil || !isLoading || refreshControl.isRefreshing
        emptyView.isHidden = pages.error != nil || isLoading || !frontPage.isEmpty || !pages.isEmpty
        errorView.isHidden = pages.error == nil
        let selected = tableView.indexPathForSelectedRow
        tableView.reloadData()
        tableView.selectRow(at: selected, animated: false, scrollPosition: .none) // preserve prior selection

        if !selectedFirstPage, !isLoading, let url = frontPage.first?.htmlURL ?? pages.first?.htmlURL {
            selectedFirstPage = true
            if splitViewController?.isCollapsed == false, !isInSplitViewDetail {
                env.router.route(to: url, from: self, options: .detail)
            }
        }
    }

    @objc func createPage() {
        env.router.route(to: "\(context.pathComponent)/pages/new", from: self, options: .modal(embedInNav: true))
    }

    @objc func refresh() {
        frontPage.refresh(force: true)
        pages.refresh(force: true) { [weak self] _ in
            self?.refreshControl.endRefreshing()
        }
    }

    @objc func pageCreated(notification: NSNotification) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard
            let info = notification.userInfo,
            let json = try? JSONSerialization.data(withJSONObject: info),
            let item = try? decoder.decode(APIPage.self, from: json)
        else {
            return
        }

        // if the new page is the front page, find and turn off the old front page
        if item.front_page {
            frontPage.first?.isFrontPage = false
        }
        Page.save(item, in: env.database.viewContext)
        try? env.database.viewContext.save()
    }
}

extension PageListViewController: UITableViewDataSource, UITableViewDelegate {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return frontPage.isEmpty ? 1 : 2
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 && !frontPage.isEmpty {
            return 1
        }
        return pages.hasNextPage ? pages.count + 1 : pages.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 && !frontPage.isEmpty {
            let cell: PageListFrontPageCell = tableView.dequeue(for: indexPath)
            cell.update(frontPage.first)
            return cell
        }
        if pages.hasNextPage, indexPath.row == pages.count {
            pages.getNextPage()
            return LoadingCell(style: .default, reuseIdentifier: nil)
        }
        let cell: PageListCell = tableView.dequeue(for: indexPath)
        cell.update(pages[indexPath.row], indexPath: indexPath)
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let page = (indexPath.section == 0 && !frontPage.isEmpty) ? frontPage.first : pages[indexPath.row]
        guard let url = page?.htmlURL else { return }
        env.router.route(to: url, from: self, options: .detail)
    }
}

class PageListFrontPageCell: UITableViewCell {
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!

    func update(_ page: Page?) {
        accessibilityIdentifier = "PageList.frontPage"
        headingLabel.text = NSLocalizedString("Front Page", bundle: .core, comment: "")
        headingLabel.accessibilityIdentifier = "PageList.frontPageHeading"
        titleLabel.text = page?.title
        titleLabel.accessibilityIdentifier = "PageList.frontPageTitle"
    }
}

class PageListCell: UITableViewCell {
    @IBOutlet weak var accessIconView: AccessIconView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!

    func update(_ page: Page?, indexPath: IndexPath) {
        titleLabel.accessibilityIdentifier = "PageList.\(indexPath.row)"
        accessIconView.icon = UIImage.icon(.document, .line)
        accessIconView.published = page?.published == true
        dateLabel.text = page?.lastUpdated.map { // TODO: page?.lastUpdated?.dateTimeString
            DateFormatter.localizedString(from: $0, dateStyle: .medium, timeStyle: .short)
        }
        titleLabel.text = page?.title
    }
}
