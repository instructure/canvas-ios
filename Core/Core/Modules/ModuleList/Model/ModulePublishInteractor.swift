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

protocol ModulePublishInteractor {
    var isPublishActionAvailable: Bool { get }
    var moduleItemsUpdating: CurrentValueSubject<Set<String>, Never> { get }
    var modulesUpdating: CurrentValueSubject<Set<String>, Never> { get }
    var statusUpdates: PassthroughSubject<String, Never> { get }
    var isModulePublishInProgress: Bool { get }

    func changeItemPublishedState(
        moduleId: String,
        moduleItemId: String,
        action: ModulePublishAction
    )
    func changeFilePublishState(
        fileContext: ModulePublishInteractorLive.FileContext,
        filePermissions: ModulePublishInteractorLive.FilePermission
    ) -> AnyPublisher<Void, Error>

    func getFilePermission(
        fileContext: ModulePublishInteractorLive.FileContext
    ) -> AnyPublisher<ModulePublishInteractorLive.FilePermission, Error>

    func bulkPublish(
        moduleIds: [String],
        action: ModulePublishAction
    ) -> AnyPublisher<BulkPublishInteractor.PublishProgress, Error>

    func cancelBulkPublish(
        moduleIds: [String],
        action: ModulePublishAction
    )
}

extension ModulePublishInteractor {
    var isModulePublishInProgress: Bool {
        !modulesUpdating.value.isEmpty
    }
}

class ModulePublishInteractorLive: ModulePublishInteractor {
    public struct FileContext: Equatable {
        let fileId: String
        let moduleId: String
        let moduleItemId: String
        let courseId: String
    }
    public struct FilePermission: Equatable {
        let unlockAt: Date?
        let lockAt: Date?
        let availability: FileAvailability
        let visibility: FileVisibility
    }
    public let isPublishActionAvailable: Bool
    public let moduleItemsUpdating = CurrentValueSubject<Set<String>, Never>(Set())
    public let modulesUpdating = CurrentValueSubject<Set<String>, Never>(Set())
    public let statusUpdates = PassthroughSubject<String, Never>()

    private let courseId: String
    private let api: API
    private var subscriptions = Set<AnyCancellable>()
    private var bulkPublishInteractors: [BulkPublishInteractor] = []

    init(
        app: AppEnvironment.App? = AppEnvironment.shared.app,
        courseId: String,
        api: API = AppEnvironment.shared.api
    ) {
        self.courseId = courseId
        self.api = api
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
                statusUpdates?.send(result.publishStatusUpdateText(for: action, isAllModules: false))
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

    // MARK: - Bulk Publish

    /**
     - returns: A publisher emitting progress state objects.
     To cancel the bulk publish call the `cancelBulkPublish` method.
     */
    func bulkPublish(
        moduleIds: [String],
        action: ModulePublishAction
    ) -> AnyPublisher<BulkPublishInteractor.PublishProgress, Error> {
        let interactor = BulkPublishInteractor(
            api: api,
            courseId: courseId,
            moduleIds: moduleIds,
            action: action
        )

        bulkPublishInteractors.append(interactor)
        modulesUpdating.value.formUnion(moduleIds)

        var subscription: AnyCancellable?
        subscription = interactor
            .progress
            .sink(receiveCompletion: { [weak self, weak interactor] result in
                guard let self, let interactor else { return }
                modulesUpdating.value.subtract(moduleIds)
                statusUpdates.send(result.publishStatusUpdateText(for: action, isAllModules: moduleIds.count > 1))

                if let index = bulkPublishInteractors.firstIndex(of: interactor) {
                    bulkPublishInteractors.remove(at: index)
                }
                subscription?.cancel()
            }, receiveValue: { _ in
            })

        return interactor.progress.eraseToAnyPublisher()
    }

    func cancelBulkPublish(
        moduleIds: [String],
        action: ModulePublishAction
    ) {
        let index = bulkPublishInteractors.firstIndex {
            $0.moduleIds == moduleIds && $0.action == action
        }
        guard let index else { return }

        let interactor = bulkPublishInteractors.remove(at: index)

        guard let progressId = interactor.progressId else { return }
        let request = PostCancelBulkPublishRequest(progressId: progressId)
        let courseId = courseId

        api
            .makeRequest(request)
            .flatMap { _ in
                ReactiveStore(useCase: GetModules(courseID: courseId))
                    .forceRefresh()
            }
            .sink(receiveCompletion: { [weak self] _ in
                self?.modulesUpdating.value.subtract(moduleIds)
            }, receiveValue: { _ in })
            .store(in: &subscriptions)
    }
}

extension Subscribers.Completion<Error> {

    func publishStatusUpdateText(for action: ModulePublishAction, isAllModules: Bool) -> String {
        let isPublish = action.isPublish
        switch self {
        case .finished:
            switch action.subject {
            case .none:
                return isPublish
                    ? String(localized: "Item Published")
                    : String(localized: "Item Unpublished")
            case .onlyModules:
                if isAllModules {
                    return isPublish
                        ? String(localized: "Only Modules published")
                        : String(localized: "Only Modules unpublished")
                } else {
                    return isPublish
                        ? String(localized: "Only Module published")
                        : String(localized: "Only Module unpublished")
                }
            case .modulesAndItems:
                if isAllModules {
                    return isPublish
                        ? String(localized: "All Modules and all Items published")
                        : String(localized: "All Modules and all Items unpublished")
                } else {
                    return isPublish
                        ? String(localized: "Module and all Items published")
                        : String(localized: "Module and all Items unpublished")
                }
            }
        case .failure:
            switch action.subject {
            case .none:
                return isPublish
                    ? String(localized: "Failed To Publish Item")
                    : String(localized: "Failed To Unpublish Item")
            case .onlyModules:
                if isAllModules {
                    return isPublish
                        ? String(localized: "Failed to publish only Modules")
                        : String(localized: "Failed to unpublish only Modules")
                } else {
                    return isPublish
                        ? String(localized: "Failed to publish only Module")
                        : String(localized: "Failed to unpublish only Module")
                }
            case .modulesAndItems:
                if isAllModules {
                    return isPublish
                        ? String(localized: "Failed to publish all Modules and all Items")
                        : String(localized: "Failed to unpublish all Modules and all Items")
                } else {
                    return isPublish
                        ? String(localized: "Failed to publish Module and all Items")
                        : String(localized: "Failed to unpublish Module and all Items")
                }
            }
        }
    }
}
