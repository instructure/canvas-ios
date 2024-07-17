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

public class CourseSettingsInteractor {

    public init() {}

    public func courseIDs(
        where settingKey: KeyPath<CourseSettings, Bool>,
        equals expectedValue: Bool,
        fromCourseIDs courseIDs: [String],
        ignoreCache: Bool = false
    ) -> AnyPublisher<[String], Error> {
        fetchCourseSettings(
            courseIDs: courseIDs,
            ignoreCache: ignoreCache
        )
        .map { settings in
            courseIDs.filter { courseID in
                guard let courseSettings = settings.first(where: { $0.courseID == courseID }) else {
                    return false
                }
                return courseSettings[keyPath: settingKey] == expectedValue
            }
        }
        .eraseToAnyPublisher()
    }

    private func fetchCourseSettings(
        courseIDs: [String],
        ignoreCache: Bool = false
    ) -> AnyPublisher<[CourseSettings], Error> {
        return Publishers
            .Sequence(sequence: courseIDs)
            .setFailureType(to: Error.self)
            .flatMap { courseID in
                let courseSettingsUseCase = GetCourseSettings(
                    courseID: courseID
                )
                return ReactiveStore(useCase: courseSettingsUseCase)
                    .getEntities(ignoreCache: ignoreCache)
            }
            .collect()
            .map { arrayOfSettings in
                arrayOfSettings.flatMap { $0 }
            }
            .eraseToAnyPublisher()
    }
}
