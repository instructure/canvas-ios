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

protocol ModuleItemSequenceInteractor {
    func fetchModuleItems(
        assetId: String,
        moduleID: String?,
        itemID: String?
    ) -> AnyPublisher<(GetModuleItemSequence.Model?, GetModuleItem.Model?), Never>

    func markAsViewed(moduleID: String,
                      itemID: String
    ) -> AnyPublisher<[MarkModuleItemRead.Model], Error>

    func markAsDone(
        item: ModuleItem?,
        moduleID: String,
        itemID: String
    ) -> AnyPublisher<[MarkModuleItemDone.Model], Error>

    func getCourseName() -> AnyPublisher<String, Never>
    func setOfflineMode(assetID: String) -> String?
}

final class ModuleItemSequenceInteractorLive: ModuleItemSequenceInteractor {
    typealias AssetType = GetModuleItemSequenceRequest.AssetType

    // MARK: - Dependencies

    private let courseID: String
    private let assetType: AssetType
    private let environment: AppEnvironment
    private let offlineModeInteractor: OfflineModeInteractor

    init(
        courseID: String,
        assetType: AssetType,
        environment: AppEnvironment,
        offlineModeInteractor: OfflineModeInteractor = OfflineModeAssembly.make()
    ) {
        self.courseID = courseID
        self.assetType = assetType
        self.environment = environment
        self.offlineModeInteractor = offlineModeInteractor
    }

    func fetchModuleItems(
        assetId: String,
        moduleID: String?,
        itemID: String?
    ) -> AnyPublisher<(GetModuleItemSequence.Model?, GetModuleItem.Model?), Never> {
        let sequenceUseCase = GetModuleItemSequence(courseID: courseID, assetType: assetType, assetID: assetId)
        let sequencePublisher = ReactiveStore(useCase: sequenceUseCase)
            .getEntities()
            .replaceError(with: [])

        return sequencePublisher
            .flatMap { [weak self] moduleItemSequence -> AnyPublisher<([GetModuleItemSequence.Model], [GetModuleItem.Model]), Never> in
                guard let self else {
                    return Just(([], [])).eraseToAnyPublisher()
                }

                guard let firstSequence = moduleItemSequence.first else {
                    return Just(([], [])).eraseToAnyPublisher()
                }

                let moduleId = moduleID ?? firstSequence.current?.moduleID
                let itemId = itemID ?? firstSequence.current?.id

                if let moduleId, let itemId {
                    let getModuleItemUseCase = GetModuleItem(courseID: courseID, moduleID: moduleId, itemID: itemId)
                    let moduleItemPublisher = ReactiveStore(useCase: getModuleItemUseCase)
                        .getEntities()
                        .replaceError(with: [])

                    return moduleItemPublisher
                        .map { moduleItems in (moduleItemSequence, moduleItems) }
                        .eraseToAnyPublisher()
                } else {
                    return Just((moduleItemSequence, [])).eraseToAnyPublisher()
                }
            }
            .removeDuplicates(by: { $0.0 == $1.0 && $0.1 == $1.1 })
            .receive(on: DispatchQueue.main)
            .compactMap { (moduleItemSequence, moduleItems) -> (GetModuleItemSequence.Model?, GetModuleItem.Model?) in
                (moduleItemSequence.first, moduleItems.first)
            }
            .eraseToAnyPublisher()
    }

    func setOfflineMode(assetID: String) -> String? {
        guard offlineModeInteractor.isOfflineModeEnabled(), Int(assetID) == nil else { return nil }
        let moduleItems: [ModuleItem] = environment.database.viewContext.fetch(scope: .where(#keyPath(ModuleItem.pageId), equals: assetID))
        let firstItem = moduleItems.first
        return firstItem?.id
    }

    func markAsViewed(moduleID: String, itemID: String) -> AnyPublisher<[MarkModuleItemRead.Model], Error> {
        let useCase = MarkModuleItemRead(courseID: courseID, moduleID: moduleID, moduleItemID: itemID)
        return ReactiveStore(useCase: useCase)
            .getEntities()
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func markAsDone(
        item: ModuleItem?,
        moduleID: String,
        itemID: String
    ) -> AnyPublisher<[MarkModuleItemDone.Model], Error> {

        let useCase = MarkModuleItemDone(
            courseID: courseID,
            moduleID: moduleID,
            moduleItemID: itemID,
            done: item?.completed == false
        )
        return ReactiveStore(useCase: useCase)
            .getEntities()
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func getCourseName() -> AnyPublisher<String, Never> {
        ReactiveStore(useCase: GetCourse(courseID: courseID))
            .getEntities()
            .replaceError(with: [])
            .map { $0.first?.name ?? "" }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
