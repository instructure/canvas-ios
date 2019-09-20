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
    weak var view: PageListViewProtocol?
    var course: Store<GetCourse>?
    var group: Store<GetGroup>?

    lazy var colors = env.subscribe(GetCustomColors()) { [weak self] in
        self?.update()
    }
    lazy var frontPage = env.subscribe(GetFrontPage(context: context)) { [weak self] in
        self?.update()
    }
    lazy var pages = env.subscribe(GetPages(context: context)) { [weak self] in
        self?.update()
    }

    init(env: AppEnvironment = .shared, view: PageListViewProtocol, context: Context) {
        self.context = context
        self.env = env
        self.view = view

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
        view?.update(isLoading: pages.pending)
        if let error = course?.error ?? group?.error {
            view?.showError(error)
        }
    }

    func viewIsReady() {
        colors.refresh()
        pages.refresh()
        frontPage.refresh()
        course?.refresh()
        group?.refresh()

        NotificationCenter.default.addObserver(self, selector: #selector(refreshPages), name: Notification.Name("refresh-pages"), object: nil)
    }

    func select(_ page: Page, from view: UIViewController) {
        env.router.route(to: page.htmlURL, from: view, options: [.detail, .embedInNav])
    }

    func newPage(from view: UIViewController) {
        env.router.route(to: "/courses/\(context.id)/pages/new", from: view, options: [.modal, .embedInNav])
    }

    @objc func refreshPages() {
        pages.refresh(force: true)
        frontPage.refresh(force: true)
    }

}
