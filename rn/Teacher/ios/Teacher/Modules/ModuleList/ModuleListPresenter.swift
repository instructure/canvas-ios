//
// Copyright (C) 2019-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
import Core
import CanvasCore
import SafariServices

private var collapsedIDs: [String: Set<String>] = [:] // [courseID: [moduleID]]

class ModuleListPresenter {
    let env: AppEnvironment
    let courseID: String
    let moduleID: String?
    weak var view: ModuleListViewProtocol?

    private var hasScrolledToModule = false

    var course: Core.Course? {
        return courses.first
    }

    lazy var modules: Store<GetModules> = {
        let useCase = GetModules(courseID: courseID)
        return env.subscribe(useCase) { [weak self] in
            self?.view?.reloadModules()

            if let moduleID = self?.moduleID, self?.hasScrolledToModule == false {
                self?.scroll(toModule: moduleID)
            }
        }
    }()

    private lazy var courses: Store<GetCourseUseCase> = {
        let useCase = GetCourseUseCase(courseID: courseID)
        return env.subscribe(useCase) { [weak self] in
            self?.view?.reloadCourse()
        }
    }()

    private lazy var colors: Store<GetCustomColors> = {
        let useCase = GetCustomColors()
        return env.subscribe(useCase) { [weak self] in
            self?.view?.reloadCourse()
        }
    }()

    init(env: AppEnvironment, view: ModuleListViewProtocol, courseID: String, moduleID: String? = nil) {
        self.env = env
        self.courseID = courseID
        self.moduleID = moduleID
        self.view = view

        collapsedIDs[courseID] = collapsedIDs[courseID] ?? Set()
        if let moduleID = moduleID {
            collapsedIDs[courseID]?.remove(moduleID)
        }
    }

    func viewIsReady() {
        refreshModules()
        courses.refresh()
        colors.refresh()
    }

    func forceRefresh() {
        view?.showPending()
        modules.refresh(force: true) { [weak self] _ in
            self?.view?.hidePending()
        }
    }

    func refreshModules() {
        modules.exhaust { [weak self] modules in
            guard let moduleID = self?.moduleID else {
                // If no moduleID is specified we only get the first page
                return false
            }
            // Keep exhausting until we sync the module with `moduleID`
            return !modules.map({ $0.id.value }).contains(moduleID)
        }
    }

    private func scroll(toModule moduleID: String) {
        if let section = modules.enumerated().first(where: { $0.1.id == moduleID })?.0 {
            hasScrolledToModule = true
            view?.scrollToRow(at: IndexPath(row: 0, section: section))
        }
    }

    func getNextPage() {
        modules.getNextPage()
    }

    func tappedSection(_ section: Int) {
        guard let module = modules[section] else { return }
        let expanded = isSectionExpanded(section)
        if expanded {
            collapsedIDs[courseID]?.insert(module.id)
        } else {
            collapsedIDs[courseID]?.remove(module.id)
        }
        view?.reloadModuleInSection(section)
    }

    func isSectionExpanded(_ section: Int) -> Bool {
        guard let module = modules[section] else { return false }
        return collapsedIDs[courseID]?.contains(module.id) == false
    }

    func showItem(_ item: Core.ModuleItem, from viewController: UIViewController) {
        switch item.type {
        case .externalTool(_, let url)?, .externalURL(let url)?:
            let safari = SFSafariViewController(url: url)
            safari.modalPresentationStyle = .overFullScreen
            viewController.present(safari, animated: true, completion: nil)
        default:
            guard let url = item.url else { return }
            env.router.route(to: url, from: viewController, options: nil)
        }
    }
}
