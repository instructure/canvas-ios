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

    private var submissionObserver: Store<LocalUseCase<Submission>>?
    private var courses: Store<GetCourses>?
    private var plannableDownloadTask: APITask?
    private var isDownloadStarted = false
    private var isForceUpdate = false
    private var pullToRefreshCompletion: (() -> Void)?

    private var plannables: [APIPlannable] = []
    private var missingSubmissions: [APIAssignment] = []
    private var courseInfoByCourseIDs: [String: (color: Color, image: URL?, isHomeroom: Bool, shouldHideQuantitativeData: Bool)] = [:]

    public init(weekRange: Range<Date>, isTodayButtonAvailable: Bool, days: [K5ScheduleDayViewModel]) {
        self.weekRange = weekRange
        self.isTodayButtonAvailable = isTodayButtonAvailable
        self.days = days
    }

    public func viewDidAppear() {
        if isDownloadStarted {
            return
        }

        downloadPlannables()
        startSubmissionObserving()
    }

    public func isTodayModel(_ model: K5ScheduleDayViewModel) -> Bool {
        model.weekday == todayViewId
    }

    private func downloadPlannables() {
        isDownloadStarted = true
        let plannablesRequest = GetPlannablesRequest(userID: nil, startDate: weekRange.lowerBound, endDate: weekRange.upperBound, contextCodes: [], filter: "")
        plannableDownloadTask = AppEnvironment.shared.api.makeRequest(plannablesRequest) { [weak self] plannables, _, _ in
            guard let self = self else { return }
            // Filter to active todo items
            self.plannables = (plannables ?? []).filter {
                guard let override = $0.planner_override else { return true }
                return !override.dismissed
            }

            self.downloadMissingAssignments()
        }
    }

    private func downloadMissingAssignments() {
        if isTodayButtonAvailable {
            let missingSubmissionsRequest = GetMissingSubmissionsRequest(includes: [.course, .planner_overrides])
            AppEnvironment.shared.api.exhaust(missingSubmissionsRequest) { [weak self] missingSubmissions, _, _ in
                self?.missingSubmissions = missingSubmissions ?? []
                self?.downloadCourses()
            }
        } else {
            downloadCourses()
        }
    }

    private func downloadCourses() {
        let courses = AppEnvironment.shared.subscribe(GetCourses(enrollmentState: nil)) { [weak self] in
            self?.coursesRefreshed()
         }
        self.courses = courses
        courses.refresh(force: self.isForceUpdate)
    }

    private func coursesRefreshed() {
        guard let courses = courses else { return }

        if courses.pending || !courses.requested {
            return
        }

        setupCourseColors(courses.all)
        let missingItems = makeMissingItems()

        for day in days {
            let plannablesForDay = plannables.filter { day.range.contains($0.plannable_date) }
            let subjects = self.subjects(from: plannablesForDay)
            performUIUpdate {
                day.subjects = subjects

                if self.isTodayModel(day) {
                    day.missingItems = missingItems
                }
            }
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
        let courseInfoByCourseIDs = coursesByIDs.mapValues { (Color($0[0].color), $0[0].imageDownloadURL, isHomeroom: $0[0].isHomeroomCourse, shouldHideQuantitativeData: $0[0].hideQuantitativeData) }
        self.courseInfoByCourseIDs = courseInfoByCourseIDs
    }

    private func makeMissingItems() -> [K5ScheduleEntryViewModel] {
        return missingSubmissions.map { assignment in
            let shouldHideQuantitativeData = courseInfoByCourseIDs[assignment.course_id.rawValue]?.shouldHideQuantitativeData == true
            let score = APIPlannable.k5SchedulePoints(from: assignment.points_possible) ?? ""
            let dueText = assignment.due_at?.relativeShortDateOnlyString ?? ""
            let courseColor: Color = courseInfoByCourseIDs[assignment.course_id.rawValue]?.color ?? .oxford
            return K5ScheduleEntryViewModel(leading: .warning,
                                            icon: .assignmentLine,
                                            title: assignment.name,
                                            subtitle: .init(text: assignment.course?.name?.uppercased() ?? "", color: courseColor, font: .bold10),
                                            labels: [],
                                            score: shouldHideQuantitativeData ? nil : score,
                                            dueText: dueText,
                                            route: assignment.html_url)
        }
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
                                                score: subject.shouldHideQuantitativeData ? nil : plannable.k5SchedulePoints,
                                                dueText: plannable.k5ScheduleDueText,
                                                route: plannable.htmlURL,
                                                apiService: apiService)
            }

            subjects.append(K5ScheduleSubjectViewModel(subject: subject, entries: entries))
        }

        subjects.sort { $0.subject.name < $1.subject.name }

        return .data(subjects)
    }

    /**
     In case a submission happens it's written back to CoreData. In order to hide the completed item from screen we subscribe to Submission changes in CoreData to trigger a refresh.
     We do this only for the current week.
     */
    private func startSubmissionObserving() {
        guard submissionObserver == nil, isTodayButtonAvailable else { return }
        submissionObserver = AppEnvironment.shared.subscribe(scope: .all(orderBy: #keyPath(Submission.userID))) { [weak self] in
            self?.refresh()
        }
    }

    private func refresh() {
        if isDownloadStarted {
            return
        }

        downloadPlannables()
    }
}
