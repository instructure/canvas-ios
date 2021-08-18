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

import SwiftUI

public class K5ScheduleWeekViewModel: ObservableObject {
    public let todayViewId = NSLocalizedString("Today", comment: "")

    public let weekRange: Range<Date>
    public let isTodayButtonAvailable: Bool
    @Published public var days: [K5ScheduleDayViewModel]

    private var courses: Store<GetCourses>?
    private var plannableDownloadTask: APITask?
    private var isDownloadStarted = false
    private var isForceUpdate = false
    private var pullToRefreshCompletion: (() -> Void)?

    private var plannables: [APIPlannable] = []
    private var courseInfoByCourseIDs: [String: (color: Color, image: URL?)] = [:]

    public init(weekRange: Range<Date>, isTodayButtonAvailable: Bool, days: [K5ScheduleDayViewModel]) {
        self.weekRange = weekRange
        self.isTodayButtonAvailable = isTodayButtonAvailable
        self.days = days
    }

    public func viewDidAppear() {
        if isDownloadStarted {
            return
        }

        downloadData()
    }

    public func pullToRefreshTriggered(completion: @escaping () -> Void) {
        if isDownloadStarted {
            completion()
            return
        }

        isForceUpdate = true
        pullToRefreshCompletion = completion
        downloadData()
    }

    public func isTodayModel(_ model: K5ScheduleDayViewModel) -> Bool {
        model.weekday == todayViewId
    }

    private func downloadData() {
        isDownloadStarted = true
        let plannablesRequest = GetPlannablesRequest(userID: nil, startDate: weekRange.lowerBound, endDate: weekRange.upperBound, contextCodes: [], filter: "")
        plannableDownloadTask = AppEnvironment.shared.api.makeRequest(plannablesRequest) { [weak self] plannables, _, _ in
            guard let self = self else { return }
            // Filter to active todo items
            self.plannables = (plannables ?? []).filter {
                guard let override = $0.planner_override else { return true }
                return !override.dismissed
            }

            let courses = AppEnvironment.shared.subscribe(GetCourses(enrollmentState: nil)) { [weak self] in
                self?.coursesRefreshed()
             }
            self.courses = courses
            courses.refresh(force: self.isForceUpdate)
        }
    }

    private func coursesRefreshed() {
        guard let courses = courses else { return }

        if courses.pending || !courses.requested {
            return
        }

        setupCourseColors(courses.all)

        for day in days {
            let plannablesForDay = plannables.filter { day.range.contains($0.plannable_date) }
            let subjects = self.subjects(from: plannablesForDay)
            performUIUpdate { day.subjects = subjects }
        }

        performUIUpdate { [weak self] in
            // Modifying an object inside `days` doesn't trigger a UI update so we do it manually
            self?.objectWillChange.send()
            self?.courses = nil
            self?.isForceUpdate = false
            self?.pullToRefreshCompletion?()
            self?.pullToRefreshCompletion = nil
            self?.isDownloadStarted = false
        }
    }

    private func setupCourseColors(_ courses: [Course]) {
        let coursesByIDs = Dictionary(grouping: courses) { $0.id }
        let courseInfoByCourseIDs = coursesByIDs.mapValues { (Color($0[0].color), $0[0].imageDownloadURL) }
        self.courseInfoByCourseIDs = courseInfoByCourseIDs
    }

    private func subjects(from plannables: [APIPlannable]) -> K5ScheduleDayViewModel.Subject {
        if plannables.isEmpty {
            return .empty
        }

        let plannablesBySubjects: [K5ScheduleSubject: [APIPlannable]] = Dictionary(grouping: plannables) { plannable in
            plannable.k5ScheduleSubject(courseInfoByCourseIDs: courseInfoByCourseIDs)
        }

        var subjects: [K5ScheduleSubjectViewModel] = []

        for (subject, plannables) in plannablesBySubjects {
            let entries: [K5ScheduleEntryViewModel] = plannables.map { plannable in
                let isCompleted = (plannable.planner_override?.marked_complete == true)
                let apiService = PlannerOverrideUpdater(api: AppEnvironment.shared.api, plannable: plannable)
                return K5ScheduleEntryViewModel(leading: .checkbox(isChecked: isCompleted),
                                                icon: plannable.k5ScheduleIcon,
                                                title: plannable.plannableTitle ?? "",
                                                subtitle: nil,
                                                labels: plannable.k5ScheduleLabels.map { K5ScheduleEntryViewModel.LabelViewModel(text: $0.text, color: $0.color)},
                                                score: plannable.k5SchedulePoints,
                                                dueText: plannable.k5ScheduleDueText,
                                                route: plannable.htmlURL,
                                                apiService: apiService)
            }

            subjects.append(K5ScheduleSubjectViewModel(subject: subject, entries: entries))
        }

        subjects.sort { $0.subject.name < $1.subject.name }

        return .data(subjects)
    }
}
