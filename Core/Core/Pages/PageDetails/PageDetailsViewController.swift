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

protocol PageDetailsViewProtocol: ColoredNavViewProtocol, ErrorViewController {
    func update()
    func dismiss(animated flag: Bool, completion: (() -> Void)?)
}

public class PageDetailsViewController: UIViewController, PageDetailsViewProtocol {
    var env: AppEnvironment!
    var context: Context!
    var pageURL: String!
    var app: App!
    var presenter: PageDetailsPresenter!

    public var titleSubtitleView: TitleSubtitleView = TitleSubtitleView.create()
    public var color: UIColor?

    @IBOutlet weak var webView: CoreWebView?

    public static func create(env: AppEnvironment = .shared, context: Context, pageURL: String, app: App) -> PageDetailsViewController {
        let vc = loadFromStoryboard()
        vc.env = env
        vc.context = context
        vc.pageURL = pageURL
        vc.app = app
        vc.presenter = PageDetailsPresenter(env: env, viewController: vc, context: context, pageURL: pageURL, app: app)
        return vc
    }

    override public func viewDidLoad() {
        setupTitleViewInNavbar(title: NSLocalizedString("Page Details", bundle: .core, comment: ""))
        webView?.linkDelegate = self

        let refresh = CircleRefreshControl()
        refresh.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        webView?.scrollView.refreshControl = refresh

        presenter.viewIsReady()
    }

    @objc func refresh(_ refresh: CircleRefreshControl) {
        presenter.pages.refresh(force: true)
    }

    @objc
    func kabobPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.popoverPresentationController?.barButtonItem = sender

        alert.addAction(AlertAction(NSLocalizedString("Edit", bundle: .core, comment: ""), style: .default) { [weak self] _ in
            guard let vc = self, let page = vc.presenter.page else {
                return
            }
            guard let url = page.htmlURL?.appendingPathComponent("edit") else { return }
            self?.env.router.route(to: url, from: vc, options: .modal(.formSheet, embedInNav: true))
        })

        if presenter.canDelete() {
            alert.addAction(AlertAction(NSLocalizedString("Delete", bundle: .core, comment: ""), style: .destructive) { [weak self] _ in
                self?.showDeleteConfirmation()
            })
        }
        alert.addAction(AlertAction(NSLocalizedString("Cancel", bundle: .core, comment: ""), style: .cancel))
        env.router.show(alert, from: self, options: .modal())
    }

    func showDeleteConfirmation() {
        let alert = UIAlertController(title: NSLocalizedString("Are you sure you want to delete this page?", bundle: .core, comment: ""), message: nil, preferredStyle: .alert)
        alert.addAction(AlertAction(NSLocalizedString("Cancel", bundle: .core, comment: ""), style: .cancel))
        alert.addAction(AlertAction(NSLocalizedString("OK", bundle: .core, comment: ""), style: .destructive) { [weak self] _ in
            self?.presenter.deletePage()
        })
        env.router.show(alert, from: self)
    }

    func update() {
        guard let page = presenter.page else {
            return
        }

        titleSubtitleView.title = page.title
        webView?.loadHTMLString(page.body)

        let buttonCount = navigationItem.rightBarButtonItems?.count ?? 0
        if presenter.canEdit() && buttonCount < 1 {
            addNavigationButton(UIBarButtonItem(image: UIImage.icon(.more), style: .plain, target: self, action: #selector(kabobPressed)), side: .right)
        }

        if webView?.scrollView.refreshControl?.isRefreshing == true && presenter.pages.pending == false {
            webView?.scrollView.refreshControl?.endRefreshing()
        }
    }
}

extension PageDetailsViewController: CoreWebViewLinkDelegate {
    public func handleLink(_ url: URL) -> Bool {
        env.router.route(to: url, from: self)
        return true
    }
}
