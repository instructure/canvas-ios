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

public class PageListViewController: ScreenViewTrackableViewController, ColoredNavViewProtocol {
    private enum Section: Hashable { case frontPage, pages }
    private enum PageItem: Hashable {
        case frontPage(id: String)
        case page(id: String)
        case loading
    }

    @IBOutlet weak var emptyMessageLabel: UILabel!
    @IBOutlet weak var emptyTitleLabel: UILabel!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var errorView: ListErrorView!
    @IBOutlet weak var loadingView: CircleProgressView!
    @IBOutlet weak var tableView: UITableView!
    let refreshControl = UIRefreshControl()
    public let titleSubtitleView = TitleSubtitleView.create()

    var app = App.student
    var canCreatePage: Bool { app == .teacher || context.contextType == .group }
    public var color: UIColor?
    var context = Context.currentUser
    private(set) var env = AppEnvironment.shared
    var selectedFirstPage: Bool = false
    private var dataSource: UITableViewDiffableDataSource<Section, PageItem>!
    public lazy var screenViewTrackingParameters = ScreenViewTrackingParameters(
        eventName: "\(context.pathComponent)/pages"
    )

    lazy var colors = env.subscribe(GetCustomColors()) { [weak self] in
        self?.updateNavBar()
    }
    lazy var course = env.subscribe(GetCourse(courseID: context.id)) { [weak self] in
        self?.updateNavBar()
    }
    lazy var group = env.subscribe(GetGroup(groupID: context.id)) { [weak self] in
        self?.updateNavBar()
    }
    lazy var frontPage = env.subscribe(GetFrontPage(context: context.local)) { [weak self] in
        self?.update()
    }
    lazy var pages = env.subscribe(GetPages(context: context.local)) { [weak self] in
        self?.update()
    }

    public static func create(context: Context, app: App, env: AppEnvironment) -> PageListViewController {
        let controller = loadFromStoryboard()
        controller.app = app
        controller.env = env
        controller.context = context
        return controller
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 26, *) {
            navigationItem.title = String(localized: "Pages", bundle: .core)
        } else {
            setupTitleViewInNavbar(title: String(localized: "Pages", bundle: .core))
        }

        if canCreatePage {
            let item = UIBarButtonItem(image: .addSolid, style: .plain, target: self, action: #selector(createPage))
            item.accessibilityIdentifier = "PageList.add"
            navigationItem.rightBarButtonItem = item
        }

        emptyMessageLabel.text = String(localized: "There are no pages to display yet.", bundle: .core)
        emptyTitleLabel.text = String(localized: "No Pages", bundle: .core)
        errorView.messageLabel.text = String(localized: "There was an error loading pages. Pull to refresh to try again.", bundle: .core)
        errorView.retryButton.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)

        refreshControl.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)
        view.backgroundColor = .backgroundLightest
        tableView.backgroundColor = .backgroundLightest
        tableView.refreshControl = refreshControl
        tableView.selectionFollowsFocus = false

        setupDataSource()

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
        navigationController?.navigationBar.useContextColor(color)
    }

    private func setupDataSource() {
        dataSource = UITableViewDiffableDataSource(tableView: tableView) { [weak self] tableView, indexPath, item in
            guard let self else { return UITableViewCell() }
            switch item {
            case .frontPage:
                let cell: PageListFrontPageCell = tableView.dequeue(for: indexPath)
                cell.update(self.frontPage.first)
                return cell
            case .page(let id):
                let cell: PageListCell = tableView.dequeue(for: indexPath)
                let page = self.pages.all.first(where: { $0.id == id })
                cell.update(page, indexPath: indexPath, color: self.color)
                return cell
            case .loading:
                return LoadingCell(style: .default, reuseIdentifier: nil)
            }
        }
        tableView.delegate = self
    }

    func updateNavBar() {
        guard
            let name = context.contextType == .course ? course.first?.name : group.first?.name,
            let color = context.contextType == .course ? course.first?.color : group.first?.color
        else {
            return
        }
        loadingView.color = color
        view.tintColor = color
        if #available(iOS 26, *) {
            navigationItem.subtitle = name
        } else {
            updateNavBar(subtitle: name, color: color)
        }
    }

    func update() {
        let isLoading = !frontPage.requested || frontPage.pending || !pages.requested || pages.pending
        loadingView.isHidden = pages.error != nil || !isLoading || refreshControl.isRefreshing
        emptyView.isHidden = pages.error != nil || isLoading || !frontPage.isEmpty || !pages.isEmpty
        errorView.isHidden = pages.error == nil
        applySnapshot()
    }

    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, PageItem>()

        if !frontPage.isEmpty, let fp = frontPage.first {
            snapshot.appendSections([.frontPage])
            snapshot.appendItems([.frontPage(id: fp.id)], toSection: .frontPage)
        }

        snapshot.appendSections([.pages])
        var pageItems = pages.all.map { PageItem.page(id: $0.id) }
        if pages.hasNextPage {
            pageItems.append(.loading)
        }
        snapshot.appendItems(pageItems, toSection: .pages)

        let updatedFrontPageIDs = Set(frontPage.updatedObjects.map { $0.id })
        let updatedPageIDs = Set(pages.updatedObjects.map { $0.id })
        let reconfigureItems = snapshot.itemIdentifiers.filter { item in
            switch item {
            case .frontPage(let id): return updatedFrontPageIDs.contains(id)
            case .page(let id): return updatedPageIDs.contains(id)
            case .loading: return false
            }
        }
        if !reconfigureItems.isEmpty {
            snapshot.reconfigureItems(reconfigureItems)
        }

        dataSource.apply(snapshot, animatingDifferences: true)
        selectFirstPageIfNeeded()
    }

    private func selectFirstPageIfNeeded() {
        let isLoading = !frontPage.requested || frontPage.pending || !pages.requested || pages.pending
        guard !selectedFirstPage, !isLoading, let url = frontPage.first?.htmlURL ?? pages.first?.htmlURL else { return }
        selectedFirstPage = true
        if splitViewController?.isCollapsed == false, !isInSplitViewDetail {
            env.router.route(to: url, from: self, options: .detail)
        }
    }

    @objc func createPage() {
        env.router.route(
            to: "\(context.pathComponent)/pages/new",
            from: self,
            options: .modal(isDismissable: false, embedInNav: true)
        )
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

extension PageListViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        let page: Page?
        switch item {
        case .frontPage:
            page = frontPage.first
        case .page(let id):
            page = pages.all.first(where: { $0.id == id })
        case .loading:
            return
        }
        guard let url = page?.htmlURL else { return }
        env.router.route(to: url, from: self, options: .detail)
    }

    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell is LoadingCell {
            pages.getNextPage()
        }

        if #available(iOS 26, *) {
            if indexPath.section == 0 && indexPath.row == 0 {
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            }
        }
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if case .loading = dataSource.itemIdentifier(for: indexPath) {
            return 73
        }
        return UITableView.automaticDimension
    }
}

class PageListFrontPageCell: UITableViewCell {
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!

    func update(_ page: Page?) {
        backgroundColor = .backgroundLightest
        accessibilityIdentifier = "PageList.frontPage"
        headingLabel.text = String(localized: "Front Page", bundle: .core)
        headingLabel.accessibilityIdentifier = "PageList.frontPageHeading"
        titleLabel.text = page?.title
        titleLabel.accessibilityIdentifier = "PageList.frontPageTitle"
    }
}

class PageListCell: UITableViewCell {
    @IBOutlet weak var accessIconView: AccessIconView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupInstDisclosureIndicator()
    }

    func update(_ page: Page?, indexPath: IndexPath, color: UIColor?) {
        backgroundColor = .backgroundLightest
        titleLabel.accessibilityIdentifier = "PageList.\(indexPath.row)"
        selectedBackgroundView = ContextCellBackgroundView.create(color: color)
        accessIconView.icon = UIImage.documentLine
        accessIconView.published = page?.published == true
        let dateText = page?.lastUpdated.map { // TODO: page?.lastUpdated?.dateTimeString
            DateFormatter.localizedString(from: $0, dateStyle: .medium, timeStyle: .short)
        }
        dateLabel.setText(dateText, style: .textCellSupportingText)
        titleLabel.setText(page?.title, style: .textCellTitle)
    }
}
