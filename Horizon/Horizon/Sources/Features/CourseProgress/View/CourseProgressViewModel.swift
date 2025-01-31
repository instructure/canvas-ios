//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

import Core
import Observation

@Observable
final class CourseProgressViewModel {
    // MARK: - Output

    private(set) var isNextButtonEnabled = false
    private(set) var isPreviousButtonEnabled = false
    private(set) var moduleName = ""
    private(set) var moduleItems: [HModuleItem] = []

    // MARK: - Private Properties

    private var currentModuleIndex = 0
    private let modulesCount: Int

    // MARK: - Dependencies

    private let router: Router
    private let course: HCourse
    var currentModuleItem: HModuleItem?
    var onSelectModuleItem: ((HModuleItem?) -> Void)?

    // MARK: - Init

    init(
        router: Router,
        course: HCourse,
        currentModuleItem: HModuleItem?
    ) {
        self.router = router
        self.currentModuleItem = currentModuleItem
        self.course = course
        self.modulesCount = course.modules.count

        currentModuleIndex = course.modules.firstIndex(where: { $0.id == currentModuleItem?.moduleID }) ?? 0
        updateCurrentModuleItems()
    }

    func dimiss(controller: WeakViewController) {
        onSelectModuleItem?(currentModuleItem)
        router.dismiss(controller)
    }

    func updateCurrentModuleItems() {
        guard currentModuleIndex >= 0, currentModuleIndex < modulesCount else {
            return
        }
        isNextButtonEnabled = currentModuleIndex < modulesCount - 1
        isPreviousButtonEnabled = currentModuleIndex > 0
        let selectModule = course.modules[safeIndex: currentModuleIndex]
        moduleName = selectModule?.name ?? ""
        moduleItems = selectModule?.items ?? []
    }

    func goToPreviousModule() {
        currentModuleIndex -= 1
        updateCurrentModuleItems()
    }

    func goToNextModule() {
        currentModuleIndex += 1
        updateCurrentModuleItems()
    }
}
