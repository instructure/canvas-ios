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
    public struct FileContext {
        let fileId: String
        let moduleId: String
        let moduleItemId: String
        let courseId: String
    }
    public struct FilePermission {
        let unlockAt: Date?
        let lockAt: Date?
        let availability: FileAvailability
        let visibility: FileVisibility
    }
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
        action: ModulePublishAction
    ) {
        moduleItemsUpdating.value.insert(moduleItemId)
        let useCase = PutModuleItemPublishState(
            courseId: courseId,
            moduleId: moduleId,
            moduleItemId: moduleItemId,
            action: action
        )
        ReactiveStore(offlineModeInteractor: nil, useCase: useCase)
            .getEntities(ignoreCache: true)
            .mapToVoid()
            .sink(receiveCompletion: { [weak moduleItemsUpdating, weak statusUpdates] result in
                guard let moduleItemsUpdating else { return }
                moduleItemsUpdating.value.remove(moduleItemId)
                statusUpdates?.send(result.moduleItemStatusUpdateText(for: action))
            }, receiveValue: {})
            .store(in: &subscriptions)
    }

    func changeFilePublishState(
        fileContext: FileContext,
        filePermissions: FilePermission
    ) -> AnyPublisher<Void, Error> {
        moduleItemsUpdating.value.insert(fileContext.moduleItemId)
        let updateFilePermissions = {
            let request = PutFileRequest(
                fileID: fileContext.fileId,
                visibility: filePermissions.visibility,
                availability: filePermissions.availability,
                unlockAt: filePermissions.unlockAt,
                lockAt: filePermissions.lockAt
            )
            let useCase = UpdateFile(request: request)
            return ReactiveStore(offlineModeInteractor: nil, useCase: useCase)
                .getEntities(ignoreCache: true)
                .mapToVoid()
        }
        let refreshModuleItem = {
            let useCase = GetModuleItem(
                courseID: fileContext.courseId,
                moduleID: fileContext.moduleId,
                itemID: fileContext.moduleItemId
            )
            return ReactiveStore(offlineModeInteractor: nil, useCase: useCase)
                .getEntities(ignoreCache: true)
                .mapToVoid()
        }
        return updateFilePermissions()
            .flatMap { refreshModuleItem() }
            .handleEvents(receiveCompletion: { [weak moduleItemsUpdating] _ in
                moduleItemsUpdating?.value.remove(fileContext.moduleItemId)
            })
            .eraseToAnyPublisher()
    }

    func getFilePermission(
        fileContext: FileContext
    ) -> AnyPublisher<FilePermission, Error> {
        let useCase = GetFile(
            context: .course(fileContext.courseId),
            fileID: fileContext.fileId
        )
        return ReactiveStore(useCase: useCase)
            .getEntities()
            .tryMap { files -> FilePermission in
                guard let file = files.first,
                      let visibility = file.visibilityLevel
                else {
                    throw NSError.internalError()
                }
                return FilePermission(
                    unlockAt: file.unlockAt,
                    lockAt: file.lockAt,
                    availability: file.availability,
                    visibility: visibility
                )
            }
            .eraseToAnyPublisher()
    }
}

extension Subscribers.Completion<Error> {

    func moduleItemStatusUpdateText(for action: ModulePublishAction) -> String {
        switch self {
        case .finished:
            switch action {
            case .publish: return String(localized: "Item Published")
            case .unpublish: return String(localized: "Item Unpublished")
            }
        case .failure:
            switch action {
            case .publish: return String(localized: "Failed To Publish Item")
            case .unpublish: return String(localized: "Failed To Unpublish Item")
            }

        }
    }
}
