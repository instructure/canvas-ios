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
        setupTitleViewInNavbar(title: NSLocalizedString("Page", bundle: .core, comment: ""))
        webView?.linkDelegate = self

        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        webView?.scrollView.refreshControl = refresh

        presenter.viewDidLoad()
    }

    @objc func refresh(_ refresh: UIRefreshControl) {
        presenter.pages.refresh(force: true)
    }

    @objc
    func kabobPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.popoverPresentationController?.barButtonItem = sender

        alert.addAction(UIAlertAction(title: NSLocalizedString("Edit", comment: ""), style: .default) { [weak self] _ in
            guard let vc = self, let page = vc.presenter.page else {
                return
            }
            self?.env.router.route(to: page.htmlURL + "/edit", from: vc, options: [.modal, .embedInNav, .formSheet])
        })

        if presenter.canDelete() {
            alert.addAction(UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .destructive) { [weak self] _ in
                self?.showDeleteConfirmation()
            })
        }
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))
        env.router.show(alert, from: self, options: [.modal])
    }

    func showDeleteConfirmation() {
        let alert = UIAlertController(title: NSLocalizedString("Are you sure you want to delete this page?", comment: ""), message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .destructive) { [weak self]_ in
            self?.presenter.deletePage()
            self?.dismiss(animated: true, completion: nil)
        })
        env.router.show(alert, from: self, options: nil)
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

        if presenter.pages.pending == false {
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
