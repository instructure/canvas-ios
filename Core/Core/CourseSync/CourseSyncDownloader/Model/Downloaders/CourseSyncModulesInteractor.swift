//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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
import Foundation

public protocol CourseSyncModulesInteractor: CourseSyncContentInteractor {}
public extension CourseSyncModulesInteractor {
    var associatedTabType: TabName { .modules }
}

public final class CourseSyncModulesInteractorLive: CourseSyncModulesInteractor, CourseSyncContentInteractor {
    public init() {}

    public func getContent(courseId: String) -> AnyPublisher<Void, Error> {
        ReactiveStore(
            useCase: GetModules(courseID: courseId)
        )
        .getEntities()
        .flatMap { $0.publisher }
        .flatMap { Self.getModuleItemSequence(courseID: $0.courseID, moduleItems: $0.items) }
        .collect()
        .mapToVoid()
        .eraseToAnyPublisher()
    }

    private static func getModuleItemSequence(
        courseID: String,
        moduleItems: [ModuleItem]
    ) -> AnyPublisher<Void, Error> {
        moduleItems.publisher
            .flatMap {
                ReactiveStore(
                    useCase: GetModuleItemSequence(
                        courseID: courseID,
                        assetType: .moduleItem,
                        assetID: $0.id
                    )
                )
                .getEntities()
            }
            .collect()
            .mapToVoid()
            .eraseToAnyPublisher()
    }
}
