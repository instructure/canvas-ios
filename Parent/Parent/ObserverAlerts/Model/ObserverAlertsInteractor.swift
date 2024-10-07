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

import Core
import Combine
import CombineExt

final class ObserverAlertsInteractor {
    private let studentID: String
    private var courseSettingsInteractor: CourseSettingsInteractor

    init(
        studentID: String,
        courseSettingsInteractor: CourseSettingsInteractor = CourseSettingsInteractor()
    ) {
        self.studentID = studentID
        self.courseSettingsInteractor = courseSettingsInteractor
    }

    func refresh(
        ignoreCache: Bool = false
    ) -> AnyPublisher<(alerts: [ObserverAlert], thresholds: [AlertThreshold]), Error> {
        let alerts = ReactiveStore(useCase: GetObserverAlerts(studentID: studentID))
            // Explicitly load all pages so the new alert badge count will be up-to-date
            .getEntities(ignoreCache: ignoreCache, loadAllPages: true)
            .flatMap { [courseSettingsInteractor] alerts in
                let courseIDs = Array(Set(alerts.compactMap { $0.courseID }))
                return courseSettingsInteractor.courseIDs(
                    where: \.restrictQuantitativeData,
                    equals: true,
                    fromCourseIDs: courseIDs,
                    ignoreCache: ignoreCache
                )
                .map { (alerts, $0) }
            }
            .map { (alerts, hiddenAlertCourses) in
                alerts.filter { alert in
                    guard let alertCourseID = alert.courseID else {
                        // If the alert has no course we don't need to filter it out
                        return true
                    }
                    return hiddenAlertCourses.contains(alertCourseID) == false
                }
            }
        let thresholds = ReactiveStore(useCase: GetAlertThresholds(studentID: studentID))
            .getEntities(ignoreCache: ignoreCache)

        return Publishers
            .CombineLatest(alerts, thresholds)
            .map { (alerts: $0.0, thresholds: $0.1) }
            .eraseToAnyPublisher()
    }

    func dismissAlert(id: String) -> AnyPublisher<Void, Error> {
        let useCase = DismissObserverAlert(alertID: id)
        return ReactiveStore(useCase: useCase)
            .getEntities()
            .mapToVoid()
            .eraseToAnyPublisher()
    }
}
