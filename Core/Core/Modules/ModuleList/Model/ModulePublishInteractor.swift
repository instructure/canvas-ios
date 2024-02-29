//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

import Combine

class ModulePublishInteractor {
    public let isPublishActionAvailable: Bool
    public private(set) var moduleItemsUpdating = CurrentValueSubject<Set<String>, Never>(Set())

    private let courseId: String
    private var subscriptions = Set<AnyCancellable>()

    init(app: AppEnvironment.App?, courseId: String) {
        self.courseId = courseId
        isPublishActionAvailable = app == .teacher && ExperimentalFeature.teacherBulkPublish.isEnabled
    }

    func changeItemPublishedState(
        moduleId: String,
        moduleItemId: String,
        action: PutModuleItemPublishRequest.Action
    ) {
        moduleItemsUpdating.value.insert(moduleItemId)
        let useCase = PutModuleItemPublishState(
            courseId: courseId,
            moduleId: moduleId,
            moduleItemId: moduleItemId,
            action: action
        )
        ReactiveStore(useCase: useCase)
            .forceRefresh()
            .sink { [weak moduleItemsUpdating] in
                guard let moduleItemsUpdating else { return }
                moduleItemsUpdating.value.remove(moduleItemId)
            }
            .store(in: &subscriptions)
    }
}
