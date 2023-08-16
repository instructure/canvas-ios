//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

#if DEBUG

import SwiftUI

struct K5Preview {

    /**
     Helper method to enable K5 fonts for K5 SwiftUI previews.

     Add the following lines to your static preview function before you create any views:
     ```
     // swiftlint:disable:next redundant_discardable_let
     let _ = K5Preview.setupK5Mode()
     ```
     */
    static func setupK5Mode() {
        let session = LoginSession(
            accessToken: "token",
            baseURL: URL(string: "https://canvas.instructure.com")!,
            expiresAt: nil,
            lastUsedAt: Date(),
            locale: "en",
            masquerader: nil,
            refreshToken: nil,
            userAvatarURL: nil,
            userID: "1",
            userName: "Eve",
            userEmail: nil,
            clientID: nil,
            clientSecret: nil
        )
        AppEnvironment.shared.userDidLogin(session: session)
        AppEnvironment.shared.k5.userDidLogin(isK5Account: true)
        AppEnvironment.shared.userDefaults?.isElementaryViewEnabled = true
        ExperimentalFeature.K5Dashboard.isEnabled = true
    }

    static func tearDownK5Mode() {
        AppEnvironment.shared.userDefaults?.isElementaryViewEnabled = false
    }

    struct Data {
        struct Schedule {
            static let entries = [
                K5ScheduleEntryViewModel(
                    leading: .checkbox(isChecked: false),
                    icon: .calendarTab,
                    title: "I created this todo for today",
                    subtitle: nil,
                    labels: [],
                    score: nil,
                    dueText: "To Do: 1:59 PM",
                    route: nil,
                    apiService: PlannerOverrideUpdater(api: AppEnvironment.shared.api, plannable: .make())),
                K5ScheduleEntryViewModel(
                    leading: .checkbox(isChecked: true),
                    icon: .assignmentLine,
                    title: "Attributes of Polygons",
                    subtitle: .init(text: "You've marked it as done", color: .ash, font: .regular12),
                    labels: [
                        .init(text: "REPLIES", color: .ash),
                        .init(text: "REDO", color: .crimson),
                    ],
                    score: "5 pts",
                    dueText: "Due: 11:59 PM",
                    route: nil,
                    apiService: PlannerOverrideUpdater(api: AppEnvironment.shared.api, plannable: .make())),
                K5ScheduleEntryViewModel(
                    leading: .warning,
                    icon: .assignmentLine,
                    title: "Identifying Physical Changes I.",
                    subtitle: .init(text: "SCIENCE", color: Color(hexString: "#8BD448")!, font: .regular10),
                    labels: [],
                    score: "5 pts",
                    dueText: "Due Yesterday",
                    route: nil,
                    apiService: PlannerOverrideUpdater(api: AppEnvironment.shared.api, plannable: .make())),
            ]

            static let subjects = [
                K5ScheduleSubjectViewModel(subject: K5ScheduleSubject(name: "Math", color: Color(hexString: "#FF8277")!,
                                                                      image: URL(string: "https://inst.prod.acquia-sites.com/sites/default/files/image/2021-01/Instructure%20Office.jpg")!,
                                                                      route: URL(string: "https://i.com"), shouldHideQuantitativeData: false), entries: entries),
                K5ScheduleSubjectViewModel(subject: K5ScheduleSubject(name: "To Do", color: .electric, image: nil, route: nil, shouldHideQuantitativeData: false), entries: entries),
                K5ScheduleSubjectViewModel(subject: K5ScheduleSubject(name: "Physics", color: Color(hexString: "#6789AF")!,
                                                                      image: URL(string: "https://inst.prod.acquia-sites.com/sites/default/files/image/2021-01/Instructure%20Office.jpg")!,
                                                                      route: URL(string: "https://i.com"), shouldHideQuantitativeData: true), entries: entries),
                K5ScheduleSubjectViewModel(subject: K5ScheduleSubject(name: "To Do", color: .electric, image: nil, route: nil, shouldHideQuantitativeData: true), entries: entries),
            ]

            static let missingItems = [
                K5ScheduleEntryViewModel(
                    leading: .warning,
                    icon: .assignmentLine,
                    title: "Attributes of Polygons",
                    subtitle: .init(text: "Math", color: Color(hexString: "#FF8277")!, font: .bold11),
                    labels: [],
                    score: "10 pts",
                    dueText: "Due Yesterday",
                    route: URL(string: "https://i.com")!),
                K5ScheduleEntryViewModel(
                    leading: .warning,
                    icon: .assignmentLine,
                    title: "Identifying Physical Changes I.",
                    subtitle: .init(text: "Science", color: Color(hexString: "#8BD448")!, font: .bold11),
                    labels: [],
                    score: "5 pts",
                    dueText: "Due Yesterday",
                    route: nil),
            ]

            static let weeks = [
                K5ScheduleWeekViewModel(weekRange: Date()..<Date(), isTodayButtonAvailable: true, days: [
                    K5ScheduleDayViewModel(weekday: "Monday", date: "September 24", subjects: .data([K5Preview.Data.Schedule.subjects[0]])),
                    K5ScheduleDayViewModel(weekday: "Today", date: "September 25", subjects: .data(K5Preview.Data.Schedule.subjects), missingItems: missingItems),
                    K5ScheduleDayViewModel(weekday: "Tomorrow", date: "September 26", subjects: .data([K5Preview.Data.Schedule.subjects[1]])),
                    K5ScheduleDayViewModel(weekday: "Thursday", date: "September 27", subjects: .empty),
                    K5ScheduleDayViewModel(weekday: "Friday", date: "September 28", subjects: .empty),
                    K5ScheduleDayViewModel(weekday: "Saturday", date: "September 29", subjects: .empty),
                    K5ScheduleDayViewModel(weekday: "Sunday", date: "September 30", subjects: .empty),
                ]),
                K5ScheduleWeekViewModel(weekRange: Date()..<Date(), isTodayButtonAvailable: false, days: [
                    K5ScheduleDayViewModel(weekday: "Monday", date: "October 1", subjects: .loading),
                    K5ScheduleDayViewModel(weekday: "Tuesday", date: "October 2", subjects: .empty),
                    K5ScheduleDayViewModel(weekday: "Wednesday", date: "October 3", subjects: .data([K5Preview.Data.Schedule.subjects[1]])),
                    K5ScheduleDayViewModel(weekday: "Thursday", date: "October 4", subjects: .empty),
                    K5ScheduleDayViewModel(weekday: "Friday", date: "October 5", subjects: .empty),
                    K5ScheduleDayViewModel(weekday: "Saturday", date: "October 6", subjects: .empty),
                    K5ScheduleDayViewModel(weekday: "Sunday", date: "October 7", subjects: .empty),
                ]),
            ]

            static let rootModel = K5ScheduleViewModel(weekModels: weeks)
        }
    }
}

#endif
