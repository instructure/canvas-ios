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
import CombineExt

/**
 This entity is responsible to keep the published state of objects associated to module items (assignments, pages, files, etc)
 up-to-date after a bulk publish action has been taken place.
 */
protocol BulkPublishLocalStateRefresher {
    func refreshStates() -> any Publisher<Void, Error>
}

struct BulkPublishLocalStateRefresherLive: BulkPublishLocalStateRefresher {
    private let courseId: String
    private let moduleIds: [String]
    private let moduleItemsUpdated: Bool

    init(
        courseId: String,
        moduleIds: [String],
        action: ModulePublishAction
    ) {
        self.courseId = courseId
        self.moduleIds = moduleIds
        self.moduleItemsUpdated = action.updatesModuleItems
    }

    func refreshStates() -> any Publisher<Void, Error> {
        moduleIds
            .refreshModules(courseId: courseId)
            .flatMap { modules in
                if moduleItemsUpdated {
                    return modules
                        .refreshPublishStateOnAssociatedItems()
                        .flatMap {
                            modules
                                .refreshFilePublishedStates(courseId: courseId)
                        }
                        .eraseToAnyPublisher()
                } else {
                    return Just(()).eraseToAnyPublisher()
                }
            }
    }
}

typealias ModuleId = String
extension Array where Element == ModuleId {

    func refreshModules(courseId: String) -> some Publisher<[Module], Error> {
        let useCase = GetModules(courseID: courseId)
        return ReactiveStore(useCase: useCase)
            .getEntities(
                ignoreCache: true,
                loadAllPages: true,
                keepObservingDatabaseChanges: false
            )
            .map { modules in
                modules.filter { contains($0.id) }
            }
    }
}

extension Array where Element == Module {

    func refreshPublishStateOnAssociatedItems() -> some Publisher<Void, Never> {
        let allItems = flatMap { $0.items }
        return Publishers.Sequence(sequence: allItems)
            .flatMap { $0.updatePublishedStateOnAssociatedItem() }
    }

    func refreshFilePublishedStates(courseId: String) -> some Publisher<Void, Never> {
        typealias FileID = String

        return Just(self)
            .map { modules -> [FileID] in
                let allItems = modules.flatMap { $0.items }
                return allItems.compactMap { $0.type.fileId }
            }
            .flatMap { Publishers.Sequence(sequence: $0).setFailureType(to: Error.self) }
            .flatMap { fileId in
                let useCase = GetFile(context: .course(courseId), fileID: fileId)
                return ReactiveStore(useCase: useCase)
                    .forceRefresh()
                    .replaceError(with: ())
            }
            .replaceError(with: ())
    }
}

extension ModuleItem {

    func updatePublishedStateOnAssociatedItem() -> Future<Void, Never> {
        Future { [weak self] promise in
            defer { promise(.success(())) }

            guard let self,
                  let context = managedObjectContext,
                  let published
            else { return }

            let type = type

            context.performAndWait {
                switch type {
                case .assignment(let id):
                    let assignment: Assignment? = context.first(where: (\Assignment.id).string, equals: id)
                    assignment?.published = published
                case .discussion(let id):
                    let discussion: DiscussionTopic? = context.first(where: (\DiscussionTopic.id).string, equals: id)
                    discussion?.published = published
                case .page(let id):
                    let page: Page? = context.first(where: (\Page.id).string, equals: id)
                    page?.published = published
                case .quiz(let id):
                    let quiz: Quiz? = context.first(where: (\Quiz.id).string, equals: id)
                    quiz?.published = published
                case .file:
                    // Files have more granular published states so we can't use the flag from the module item
                    break
                default: break
                }

                try? context.save()
            }
        }
    }
}
