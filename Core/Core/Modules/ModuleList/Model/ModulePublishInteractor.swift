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
    public let moduleItemsUpdating = CurrentValueSubject<Set<String>, Never>(Set())
    public let statusUpdates = PassthroughSubject<String, Never>()

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
        ReactiveStore(offlineModeInteractor: nil, useCase: useCase)
            .getEntities(
                ignoreCache: true,
                keepObservingDatabaseChanges: false
            )
            .mapToVoid()
            .sink(receiveCompletion: { [weak moduleItemsUpdating, weak statusUpdates] result in
                guard let moduleItemsUpdating else { return }
                moduleItemsUpdating.value.remove(moduleItemId)
                statusUpdates?.send(result.moduleItemStatusUpdateText(for: action))
            }, receiveValue: {})
            .store(in: &subscriptions)
    }
}

extension Subscribers.Completion<Error> {

    func moduleItemStatusUpdateText(for action: PutModuleItemPublishRequest.Action) -> String {
        switch self {
        case .finished:
            switch action {
            case .publish: return String(localized: "Item published")
            case .unpublish: return String(localized: "Item unpublished")
            }
        case .failure: return String(localized: "Failed to update module item")
        }
    }
}
