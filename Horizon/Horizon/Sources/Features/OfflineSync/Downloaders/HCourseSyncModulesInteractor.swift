//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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
import Combine
import Foundation

protocol HCourseSyncModulesInteractor {
    func getModuleItems(courseId: String) -> AnyPublisher<[ModuleItem], Error>
}

final class HCourseSyncModulesInteractorLive: HCourseSyncModulesInteractor {

    func getModuleItems(courseId: String) -> AnyPublisher<[ModuleItem], Error> {
        ReactiveStore(useCase: GetModules(courseID: courseId))
            .getEntities(ignoreCache: true)
            .first()
            .flatMap { modules in
                modules.publisher
                    .flatMap { module in
                        Self.getModuleItemSequence(courseID: courseId, moduleItems: module.items)
                    }
                    .collect()
                    .map { $0.flatMap { $0 } }
            }
            .eraseToAnyPublisher()
    }

    private static func getModuleItemSequence(
        courseID: String,
        moduleItems: [ModuleItem]
    ) -> AnyPublisher<[ModuleItem], Error> {
        moduleItems.publisher
            .flatMap {
                ReactiveStore(
                    useCase: GetModuleItemSequence(
                        courseID: courseID,
                        assetType: .moduleItem,
                        assetID: $0.id
                    )
                )
                .getEntities(ignoreCache: true)
            }
            .collect()
            .map { _ in moduleItems }
            .eraseToAnyPublisher()
    }
}
