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

public final class PageDetailsViewController: UIViewController, ColoredNavViewProtocol, ErrorViewController {
    lazy var optionsButton = UIBarButtonItem(image: .moreLine, style: .plain, target: self, action: #selector(showOptions))
    @IBOutlet weak var webViewContainer: UIView!
    let webView = CoreWebView()
    let refreshControl = CircleRefreshControl()
    public let titleSubtitleView = TitleSubtitleView.create()

    var app = App.student
    public var color: UIColor?
    var context = Context.currentUser
    var env: AppEnvironment = .shared
    var pageURL = ""

    lazy var colors = env.subscribe(GetCustomColors()) { [weak self] in
        self?.updateNavBar()
    }
    lazy var courses = env.subscribe(GetCourse(courseID: context.id)) { [weak self] in
        self?.updateNavBar()
    }
    lazy var groups = env.subscribe(GetGroup(groupID: context.id)) { [weak self] in
        self?.updateNavBar()
    }
    lazy var pages = env.subscribe(GetPage(context: context.local, url: pageURL)) { [weak self] in
        self?.updatePages()
    }
    var localPages: Store<LocalUseCase<Page>>?

    var page: Page? { localPages?.first }

    var canEdit: Bool {
        app == .teacher ||
        page?.editingRoles.contains("students") == true ||
        page?.editingRoles.contains("public") == true ||
        page?.editingRoles.contains("members") == true
    }

    var canDelete: Bool {
        app == .teacher && page?.isFrontPage != true
    }

    private var offlineModeInteractor: OfflineModeInteractor?

    public static func create(
        context: Context,
        pageURL: String,
        app: App,
        env: AppEnvironment,
        offlineModeInteractor: OfflineModeInteractor = OfflineModeAssembly.make()
    ) -> PageDetailsViewController {
        let controller = loadFromStoryboard()
        controller.context = context
        controller.pageURL = pageURL
        controller.app = app
        controller.env = env
        controller.offlineModeInteractor = offlineModeInteractor
        return controller
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundLightest
        setupTitleViewInNavbar(title: String(localized: "Page Details", bundle: .core))
        webViewContainer.addSubview(webView)
        webView.pinWithThemeSwitchButton(inside: webViewContainer)
        webView.linkDelegate = self
        if context.contextType == .course {
            webView.addScript("window.ENV={COURSE:{id:\(CoreWebView.jsString(context.id))}}")
        }

        refreshControl.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)
        webView.scrollView.refreshControl = refreshControl

        colors.refresh()
        if context.contextType == .course {
            courses.refresh()
        } else {
            groups.refresh()
        }
        pages.refresh(force: true)
        NotificationCenter.default.post(moduleItem: .page(pageURL), completedRequirement: .view, courseID: context.id)
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if env.app != .parent {
            navigationController?.navigationBar.useContextColor(color)
        }
    }

    @objc private func refresh() {
        pages.refresh(force: true) { [weak self] _ in
            self?.refreshControl.endRefreshing()
        }
    }

    // Parent uses a different coloring logic so we prevent any update here. 
    private func updateNavBar() {
        guard
            let name = context.contextType == .course ? courses.first?.name : groups.first?.name,
            let color = context.contextType == .course ? courses.first?.color : groups.first?.color,
            env.app != .parent
        else { return }
        updateNavBar(subtitle: name, color: color)
    }

    private func update() {
        guard let page = page else { return }
        setupTitleViewInNavbar(title: page.title)
        optionsButton.accessibilityIdentifier = "PageDetails.options"
        navigationItem.rightBarButtonItem = canEdit ? optionsButton : nil

        // Offline with separate html file
        let offlinePath = URL.Paths.Offline.courseSectionResourceFolderURL(
            sessionId: env.currentSession?.uniqueID ?? "",
            courseId: courses.first?.id ?? "",
            sectionName: OfflineFolderPrefix.pages.rawValue,
            resourceId: page.id
        ).appendingPathComponent("body.html")

        webView.loadContent(
            isOffline: offlineModeInteractor?.isNetworkOffline(),
            filePath: offlinePath,
            content: page.body,
            originalBaseURL: page.htmlURL
        )
    }

    private func updatePages() {
        guard let page = pages.first else { return }
        localPages = env.subscribe(scope: .where(#keyPath(Page.id), equals: page.id)) { [weak self] in
            self?.update() }
        localPages?.refresh()
    }

    @objc private func showOptions(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(AlertAction(String(localized: "Edit", bundle: .core), style: .default) { [weak self] _ in
            guard let self = self, let page = self.page else { return }
            guard let url = page.htmlURL?.appendingPathComponent("edit") else { return }
            self.env.router.route(to: url, from: self, options: .modal(isDismissable: false, embedInNav: true))
        })
        if canDelete {
            alert.addAction(AlertAction(String(localized: "Delete", bundle: .core), style: .destructive) { [weak self] _ in
                self?.showDeleteConfirmation()
            })
        }
        alert.addAction(AlertAction(String(localized: "Cancel", bundle: .core), style: .cancel))
        alert.popoverPresentationController?.barButtonItem = sender
        env.router.show(alert, from: self, options: .modal())
    }

    private func showDeleteConfirmation() {
        let alert = UIAlertController(title: String(localized: "Are you sure you want to delete this page?", bundle: .core), message: nil, preferredStyle: .alert)
        alert.addAction(AlertAction(String(localized: "Cancel", bundle: .core), style: .cancel))
        alert.addAction(AlertAction(String(localized: "OK", bundle: .core), style: .destructive) { [weak self] _ in
            self?.deletePage()
        })
        env.router.show(alert, from: self)
    }

    private func deletePage() {
        guard let page = page else { return }
        env.api.makeRequest(DeletePageRequest(context: context, url: page.url)) { [weak self] (_, _, error) in performUIUpdate {
            guard let self = self else { return }
            if let error = error {
                return self.showError(error)
            }
            self.env.database.viewContext.delete(page)
            try? self.env.database.viewContext.save()
            self.env.router.pop(from: self)
        } }
    }
}

extension PageDetailsViewController: CoreWebViewLinkDelegate {

    public func finishedNavigation() {
        UIAccessibility.post(notification: .screenChanged, argument: titleSubtitleView)
    }
}
