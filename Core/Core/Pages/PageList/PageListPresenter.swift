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

import CoreData

class PageListPresenter: PageViewLoggerPresenterProtocol {

    var pageViewEventName: String {
        return "\(context.pathComponent)/pages"
    }

    let context: Context
    let env: AppEnvironment
    let app: App
    weak var view: PageListViewProtocol?
    var course: Store<GetCourse>?
    var group: Store<GetGroup>?
    lazy var pages = Pages(context: context) { [weak self] in
        self?.update()
    }

    lazy var colors = env.subscribe(GetCustomColors()) { [weak self] in
        self?.update()
    }

    init(env: AppEnvironment = .shared, view: PageListViewProtocol, context: Context, app: App) {
        self.context = context
        self.env = env
        self.view = view
        self.app = app

        switch context.contextType {
        case .course:
            course = env.subscribe(GetCourse(courseID: context.id), { [weak self] in
                self?.update()
            })
        case .group:
            group = env.subscribe(GetGroup(groupID: context.id), { [weak self] in
                self?.update()
            })
        default:
            break
        }
    }

    private func update() {
        if colors.pending == false {
            if let course = course?.first {
                view?.updateNavBar(subtitle: course.name, color: course.color)
            } else if let group = group?.first {
                view?.updateNavBar(subtitle: group.name, color: group.color)
            }
        }
        let isLoading = pages.frontPage?.pending == true || pages.all?.pending == true
        view?.update(isLoading: isLoading)
        if let error = course?.error ?? group?.error {
            view?.showError(error)
        }
    }

    func viewIsReady() {
        colors.refresh()
        pages.refresh()
        course?.refresh()
        group?.refresh()

        NotificationCenter.default.addObserver(self, selector: #selector(pageCreated), name: Notification.Name("page-created"), object: nil)
    }

    func select(_ page: Page, from view: UIViewController) {
        guard let url = page.htmlURL else { return }
        env.router.route(to: url, from: view, options: .detail)
    }

    func newPage(from view: UIViewController) {
        env.router.route(to: "\(context.pathComponent)/pages/new", from: view, options: .modal(embedInNav: true))
    }

    @objc
    func refreshPages() {
        pages.refresh(force: true)
    }

    @objc
    func pageCreated(notification: NSNotification) {
        guard let rawCreateData = notification.userInfo else {
            return
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let jsonData = try? JSONSerialization.data(withJSONObject: rawCreateData, options: .prettyPrinted), let apiPage = try? decoder.decode(APIPage.self, from: jsonData) else {
            return
        }

        // if the new page is the front page, find and turn off the old front page
        if apiPage.front_page {
            let scope = GetFrontPage(context: context).scope
            let currentFrontPage: Page? = env.database.viewContext.fetch(scope.predicate, sortDescriptors: nil).first
            currentFrontPage?.isFrontPage = false
        }

        Page.save(apiPage, in: env.database.viewContext)
        try? env.database.viewContext.save()
    }

    func canCreatePage() -> Bool {
        return app == .teacher || context.contextType == .group
    }

}
