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

import CombineSchedulers
import Combine
import Observation
import Foundation

@Observable
final class TimeSpentWidgetViewModel {
    // MARK: - Outputs

    private(set) var state: HViewState = .loading
    private(set) var courses: [TimeSpentWidgetModel] = []
    private(set) var courseDurationText: String?
    private(set) var isListCoursesVisiable = false
    var accessibilityCourseTimeSpent: String {
        if selectedCourse?.id == "-1" { // refer to all courses seleted
            return String.localizedStringWithFormat(
                 String(localized: "Time spent for all courses is %@ %@", bundle: .horizon),
                 selectedCourse?.formattedHours.value ?? "",
                 selectedCourse?.formattedHours.unit ?? ""
             )
        } else {
           return String.localizedStringWithFormat(
                String(localized: "Time spent for course %@ is %@ %@", bundle: .horizon),
                selectedCourse?.courseName ?? "",
                selectedCourse?.formattedHours.value ?? "",
                selectedCourse?.formattedHours.unit ?? ""
            )
        }
    }

    // MARK: - Private Propertites

    private var subscriptions = Set<AnyCancellable>()
    private let scheduler: AnySchedulerOf<DispatchQueue>

    // MARK: - Input / Outputs

    var selectedCourse: TimeSpentWidgetModel? {
        didSet {
            guard let selectedCourse else {
                courseDurationText = nil
                return
            }

            let unit = selectedCourse.formattedHours.unit
            let key: String = courses.count == 1
            ? String(localized: "%@ in your course", bundle: .horizon)
            : String(localized: "%@ in", bundle: .horizon)
            courseDurationText = String(format: key, unit)
        }
    }

    // MARK: - Dependencies

    private let interactor: TimeSpentWidgetInteractor
    private let learnCoursesInteractor: GetLearnCoursesInteractor

    init(
        interactor: TimeSpentWidgetInteractor,
        learnCoursesInteractor: GetLearnCoursesInteractor,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.interactor = interactor
        self.scheduler = scheduler
        self.learnCoursesInteractor = learnCoursesInteractor
        getTimeSpent()
    }

    func getTimeSpent(ignoreCache: Bool = false) {
        state = .loading
        courses = TimeSpentWidgetModel.loadingModels
        selectedCourse = TimeSpentWidgetModel.loadingModels.first
        isListCoursesVisiable = false
        getTimeSpentForCourses(ignoreCache: ignoreCache)
            .zip(
                getCourses(ignoreCache: ignoreCache)
                    .setFailureType(to: Error.self)
            )
            .map { timesForCourses, learnCourses -> [TimeSpentWidgetModel] in
                let courseIds = learnCourses.map(\.id)
                return timesForCourses.filter { courseIds.contains($0.id) }
            }
            .receive(on: scheduler)
            .sinkFailureOrValue { [weak self] _ in
                self?.state = .error
            } receiveValue: { [weak self] timesForCourses in
                guard let self else { return }
                self.courses.removeAll()
                if timesForCourses.count > 1 {
                    self.courses = [
                        .init(
                            id: "-1",
                            courseName: String(localized: "all courses", bundle: .horizon),
                            minutesPerDay: timesForCourses.totalMinutesPerDay
                        )
                    ]
                    self.isListCoursesVisiable = true
                }

                self.courses.append(contentsOf: timesForCourses)
                self.state = timesForCourses.isEmpty ? .empty : .data
                self.selectedCourse = courses.first
            }
            .store(in: &subscriptions)
    }

    private func getCourses(ignoreCache: Bool = false) -> AnyPublisher<[LearnCourse], Never> {
        learnCoursesInteractor
            .getCourses(ignoreCache: false)
            .receive(on: scheduler)
            .eraseToAnyPublisher()
    }

    private func getTimeSpentForCourses(ignoreCache: Bool = false) -> AnyPublisher<[TimeSpentWidgetModel], Error> {
        interactor
            .getTimeSpent(ignoreCache: ignoreCache)
            .receive(on: scheduler)
            .eraseToAnyPublisher()
    }
}
