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

import Combine
import Core
import CombineSchedulers

protocol ModuleItemSequenceInteractor {
    func fetchModuleItems(
        assetId: String,
        moduleID: String?,
        itemID: String?
    ) -> AnyPublisher<(HModuleItemSequence?, HModuleItem?), Never>

    func markAsViewed(moduleID: String,
                      itemID: String
    ) -> AnyPublisher<[HModuleItem], Error>

    func markAsDone(
        completed: Bool,
        moduleID: String,
        itemID: String
    ) -> AnyPublisher<[HModuleItem], Error>

    func getCourse() -> AnyPublisher<HCourse, Never>
}

final class ModuleItemSequenceInteractorLive: ModuleItemSequenceInteractor {
    typealias AssetType = GetModuleItemSequenceRequest.AssetType

    // MARK: - Dependencies

    private let courseID: String
    private let assetType: AssetType
    private let offlineModeInteractor: OfflineModeInteractor
    private let scheduler: AnySchedulerOf<DispatchQueue>

    init(
        courseID: String,
        assetType: AssetType,
        scheduler: AnySchedulerOf<DispatchQueue> = .main,
        offlineModeInteractor: OfflineModeInteractor = OfflineModeAssembly.make()
    ) {
        self.courseID = courseID
        self.assetType = assetType
        self.scheduler = scheduler
        self.offlineModeInteractor = offlineModeInteractor
    }

    func fetchModuleItems(
        assetId: String,
        moduleID: String?,
        itemID: String?
    ) -> AnyPublisher<(HModuleItemSequence?, HModuleItem?), Never> {
        let sequenceUseCase = GetModuleItemSequence(courseID: courseID, assetType: assetType, assetID: assetId)
        let sequencePublisher = ReactiveStore(useCase: sequenceUseCase)
            .getEntities()
            .replaceError(with: [])
            .flatMap { Publishers.Sequence(sequence: $0) }
            .map { HModuleItemSequence(entity: $0) }
            .collect()

        return sequencePublisher
            .flatMap { [weak self] moduleItemSequence -> AnyPublisher<([HModuleItemSequence], [HModuleItem]), Never> in
                guard let self else {
                    return Just(([], [])).eraseToAnyPublisher()
                }

                guard let firstSequence = moduleItemSequence.first else {
                    return Just(([], [])).eraseToAnyPublisher()
                }

                let moduleId = moduleID ?? firstSequence.moduleID
                let itemId = itemID ?? firstSequence.itemID
                if let moduleId, let itemId {
                    let getModuleItemUseCase = GetModuleItem(courseID: courseID, moduleID: moduleId, itemID: itemId)
                    let moduleItemPublisher = ReactiveStore(useCase: getModuleItemUseCase)
                        .getEntities()
                        .replaceError(with: [])
                        .flatMap { Publishers.Sequence(sequence: $0) }
                        .map { HModuleItem(from: $0) }
                        .collect()

                    return moduleItemPublisher
                        .map { moduleItems in (moduleItemSequence, moduleItems) }
                        .eraseToAnyPublisher()
                } else {
                    return Just((moduleItemSequence, [])).eraseToAnyPublisher()
                }
            }
            .removeDuplicates(by: { $0.0 == $1.0 && $0.1 == $1.1 })
            .receive(on: scheduler)
            .compactMap { (moduleItemSequence, moduleItems) -> (HModuleItemSequence?, HModuleItem?) in
                (moduleItemSequence.first, moduleItems.first)
            }
            .eraseToAnyPublisher()
    }

//    func setOfflineMode(assetID: String) -> String? {
//        guard offlineModeInteractor.isOfflineModeEnabled(), Int(assetID) == nil else { return nil }
//        let moduleItems: [ModuleItem] = environment.database.viewContext.fetch(scope: .where(#keyPath(ModuleItem.pageId), equals: assetID))
//        let firstItem = moduleItems.first
//        return firstItem?.id
//    }

    func markAsViewed(moduleID: String, itemID: String) -> AnyPublisher<[HModuleItem], Error> {
        let useCase = MarkModuleItemRead(courseID: courseID, moduleID: moduleID, moduleItemID: itemID)
        return ReactiveStore(useCase: useCase)
            .getEntities()
            .flatMap { Publishers.Sequence(sequence: $0).setFailureType(to: Error.self) }
            .map { HModuleItem(from: $0) }
            .collect()
            .receive(on: scheduler)
            .eraseToAnyPublisher()
    }

    func markAsDone(
        completed: Bool,
        moduleID: String,
        itemID: String
    ) -> AnyPublisher<[HModuleItem], Error> {

        let useCase = MarkModuleItemDone(
            courseID: courseID,
            moduleID: moduleID,
            moduleItemID: itemID,
            done: completed
        )
        return ReactiveStore(useCase: useCase)
            .getEntities()
            .flatMap { Publishers.Sequence(sequence: $0).setFailureType(to: Error.self) }
            .map { HModuleItem(from: $0) }
            .collect()
            .receive(on: scheduler)
            .eraseToAnyPublisher()
    }

    func getCourse() -> AnyPublisher<HCourse, Never> {
        ReactiveStore(useCase: GetCourse(courseID: courseID))
            .getEntities()
            .replaceError(with: [])
            .compactMap { $0.first }
            .flatMap {
                $0.publisher
                    .flatMap { course in
                        ReactiveStore(
                            useCase: GetModules(courseID: course.id)
                        )
                        .getEntities()
                        .replaceError(with: [])
                        .map {
                            HCourse(
                                from: course,
                                modulesEntity: $0
                            )
                        }
                    }
            }
            .receive(on: scheduler)
            .eraseToAnyPublisher()
    }
}

extension HCourse {
    init(from entity: Course, modulesEntity: [Module]) {
        self.id = entity.id
        self.institutionName = ""
        self.name = entity.name ?? ""
        self.overviewDescription = entity.syllabusBody ?? ""
        self.progress = 0
        self.modules = modulesEntity.map { HModule(from: $0) }
        self.incompleteModules = []
    }
}

extension HModule {
    init(from entity: Module) {
        self.id = entity.id
        self.name = entity.name
        self.courseID = entity.courseID
        self.items = entity.items.map { HModuleItem(from: $0) }
        contentItems = items.filter { $0.type?.isContentItem == true  }
        moduleStatus = .init(
            items: contentItems,
            state: entity.state,
            lockMessage: entity.lockedMessage,
            countOfPrerequisite: entity.prerequisiteModuleIDs.count
        )
    }
}
