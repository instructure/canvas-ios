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

class PageDetailsPresenter {

    let env: AppEnvironment
    weak var viewController: PageDetailsViewProtocol?
    let context: Context
    let pageURL: String
    let app: App

    init(env: AppEnvironment = .shared, viewController vc: PageDetailsViewProtocol, context: Context, pageURL: String, app: App) {
        self.env = env
        self.context = context
        self.pageURL = pageURL
        self.app = app
        self.viewController = vc
    }

    lazy var colors = env.subscribe(GetCustomColors()) { [weak self] in
        self?.updateNavBar()
    }

    lazy var courses = env.subscribe(GetCourse(courseID: context.id)) { [weak self] in
        self?.updateNavBar()
    }

    lazy var groups = env.subscribe(GetGroup(groupID: context.id)) { [weak self] in
        self?.updateNavBar()
    }

    var page: Page? {
        return pages.first
    }
    lazy var pages = env.subscribe(GetPage(context: context, url: pageURL)) { [weak self] in
        self?.viewController?.update()
    }

    public func viewIsReady() {
        if context.contextType == .course {
            courses.refresh()
        } else {
            groups.refresh()
        }
        colors.refresh()
        pages.refresh(force: true)

        NotificationCenter.default.addObserver(self, selector: #selector(pageEdited), name: Notification.Name("page-edit"), object: nil)

    }

    @objc
    func pageEdited(notification: NSNotification) {
        guard let rawEditData = notification.userInfo else {
            return
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let jsonData = try? JSONSerialization.data(withJSONObject: rawEditData, options: .prettyPrinted), let apiPage = try? decoder.decode(APIPage.self, from: jsonData) else {
            return
        }

        // if the front page was changed, ensure only one page has the front page set
        let frontPageChanged = apiPage.front_page != page?.isFrontPage
        if frontPageChanged {
            let scope = GetFrontPage(context: context).scope
            let currentFrontPage: Page? = env.database.viewContext.fetch(scope.predicate, sortDescriptors: nil).first
            currentFrontPage?.isFrontPage = false
        }

        page?.update(from: apiPage)
        try? env.database.viewContext.save()

        pages = self.env.subscribe(GetPage(context: context, url: apiPage.url)) { [weak self] in
            self?.viewController?.update()
        }
        pages.refresh()
    }

    func deletePage() {
        guard let page = page else {
            return
        }
        env.api.makeRequest(DeletePageRequest(context: context, url: page.url)) { [weak self] (_, _, error) in
            if let error = error {
                self?.viewController?.showError(error)
                return
            }

            self?.env.database.viewContext.delete(page)
            DispatchQueue.main.async {
                guard let vc = self?.viewController as? UIViewController else {
                    return
                }
                self?.env.router.pop(from: vc)
            }
        }
    }

    func updateNavBar() {
        guard let name = courses.first?.name ?? groups.first?.name, let color = courses.first?.color ?? groups.first?.color else {
            return
        }
        self.viewController?.updateNavBar(subtitle: name, color: color)
    }

    func canEdit() -> Bool {
        switch app {
        case .student:
            guard let page = page else {
                return false
            }
            return page.editingRoles.contains("students") == true || page.editingRoles.contains("public") || page.editingRoles.contains("members")
        case .teacher:
            return true
        default:
            return false
        }
    }

    func canDelete() -> Bool {
        return app == .teacher && page?.isFrontPage != true
    }
}
