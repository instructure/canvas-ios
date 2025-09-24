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
import Combine

protocol CourseToolsInteractor {
    func getTools(courseID: String, ignoreCache: Bool) -> AnyPublisher<[ToolLinkItem], Never>
}

final class CourseToolsInteractorLive: CourseToolsInteractor {
    func getTools(courseID: String, ignoreCache: Bool) -> AnyPublisher<[ToolLinkItem], Never> {
        ReactiveStore(useCase: CourseToolsUseCase(courseContextsCodes: [Context(.course, id: courseID).canvasContextID]))
            .getEntities(ignoreCache: ignoreCache)
            .replaceError(with: [])
            .flatMap { Publishers.Sequence(sequence: $0) }
            .map { ToolLinkItem(id: $0.id, title: $0.name, iconUrl: $0.iconURL, url: $0.url) }
            .collect()
            .eraseToAnyPublisher()
    }
}
