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
import CombineSchedulers
import Core

protocol GetCoursesInteractor {
    func getCourses() -> AnyPublisher<[HCourse], Never>
}

final class GetCoursesInteractorLive: GetCoursesInteractor {
    // MARK: - Properties

    private let appEnvironment: AppEnvironment
    private let scheduler: AnySchedulerOf<DispatchQueue>
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init

    init(
        appEnvironment: AppEnvironment,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.appEnvironment = appEnvironment
        self.scheduler = scheduler
    }

    // MARK: - Functions

    func getCourses() -> AnyPublisher<[HCourse], Never> {
        fetchCourseProgression()
            .receive(on: scheduler)
            .map { coursesProgressions in
                coursesProgressions.map { coursesProgression in
                    HCourse(from: coursesProgression)
                }
            }
            .eraseToAnyPublisher()
    }

    private func fetchCourseProgression() -> AnyPublisher<[CDCourseProgression], Never> {
        let userId = appEnvironment.currentSession?.userID ?? ""

        return ReactiveStore(useCase: GetCoursesProgressionUseCase(userId: userId))
            .getEntities()
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
}

extension HCourse {
    init(from courseProgression: CDCourseProgression) {
        self.id = courseProgression.courseID
        self.name = courseProgression.courseName ?? ""
        if let imageUrl = courseProgression.imageUrl {
            self.imageURL = URL(string: imageUrl)
        } else {
            self.imageURL = nil
        }
        self.overviewDescription = courseProgression.overviewDescription
        self.modules = []
    }
}
