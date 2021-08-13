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

    private lazy var courses = AppEnvironment.shared.subscribe(GetCourses(enrollmentState: nil)) { [weak self] in
        self?.coursesRefreshed()
    }
    private var plannableDownloadTask: APITask?
    private var isDownloadStarted = false

    private var plannables: [APIPlannable] = []
    private var courseColorsByCourseIDs: [String: Color] = [:]

    public init(weekRange: Range<Date>, isTodayButtonAvailable: Bool, days: [K5ScheduleDayViewModel]) {
        self.weekRange = weekRange
        self.isTodayButtonAvailable = isTodayButtonAvailable
        self.days = days
    }

    public func viewDidAppear() {
        if isDownloadStarted {
            return
        }

        isDownloadStarted = true
        let plannablesRequest = GetPlannablesRequest(userID: nil, startDate: weekRange.lowerBound, endDate: weekRange.upperBound, contextCodes: [], filter: "")
        plannableDownloadTask = AppEnvironment.shared.api.makeRequest(plannablesRequest) { [weak self] plannables, _, _ in
            // Filter to active todo items
            self?.plannables = (plannables ?? []).filter {
                guard let override = $0.planner_override else { return true }
                return !override.dismissed
            }
            self?.courses.refresh()
        }
    }

    private func coursesRefreshed() {
        if courses.pending || !courses.requested {
            return
        }

        setupCourseColors()

        for day in days {
            let plannablesForDay = plannables.filter { day.range.contains($0.plannable_date) }
            let subjects = self.subjects(from: plannablesForDay)
            performUIUpdate { day.subjects = subjects }
        }
    }

    private func setupCourseColors() {
        let coursesByIDs = Dictionary(grouping: courses.all) { $0.id }
        let courseColorsByCourseIDs = coursesByIDs.mapValues { Color($0[0].color) }
        self.courseColorsByCourseIDs = courseColorsByCourseIDs
    }

    private func subjects(from plannables: [APIPlannable]) -> K5ScheduleDayViewModel.Subject {
        if plannables.isEmpty {
            return .empty
        }

        let plannablesBySubjects: [K5ScheduleSubject: [APIPlannable]] = Dictionary(grouping: plannables) { plannable in
            let name: String = {
                if plannable.plannableType == .calendar_event {
                    return NSLocalizedString("To Do", comment: "")
                } else {
                    return plannable.context_name ?? NSLocalizedString("To Do", comment: "")
                }
            }()
            let color: Color = {
                if let courseID = plannable.course_id?.value, let color = self.courseColorsByCourseIDs[courseID] {
                    return color
                } else {
                    return Color(Brand.shared.primary)
                }
            }()
            let route : URL? = {
                guard let context = plannable.context, context.contextType != .user else { return nil }
                return URL(string: context.pathComponent)
            }()
            return K5ScheduleSubject(name: name, color: color, image: nil, route: route)
        }

        var subjects: [K5ScheduleSubjectViewModel] = []

        for (subject, plannables) in plannablesBySubjects {
            let entries: [K5ScheduleEntryViewModel] = plannables.map { plannable in
                let dueText: String = {
                    if plannable.plannable?.all_day == true {
                        return NSLocalizedString("All Day", comment: "")
                    } else if let start = plannable.plannable?.start_at, let end = plannable.plannable?.end_at {
                        return start.timeIntervalString(to: end)
                    } else if plannable.plannableType == .announcement {
                        return plannable.plannable_date.timeString
                    } else {
                        let dueTemplate = NSLocalizedString("Due: %@", bundle: .core, comment: "")
                        return String.localizedStringWithFormat(dueTemplate, plannable.plannable_date.timeString)
                    }
                }()
                let pointsText: String? = {
                    guard let points = plannable.pointsPossible else { return nil }
                    let pointsTemplate = NSLocalizedString("g_pts", bundle: .core, comment: "")
                    return String.localizedStringWithFormat(pointsTemplate, points)
                }()
                let labels: [K5ScheduleEntryViewModel.LabelViewModel] = {
                    guard let submissionStates = plannable.submissions?.value1 else { return [] }
                    var labels: [K5ScheduleEntryViewModel.LabelViewModel] = []

                    if submissionStates.graded == true {
                        labels.append(K5ScheduleEntryViewModel.LabelViewModel(text: NSLocalizedString("Graded", comment: ""), color: .ash))
                    }
                    if submissionStates.late == true {
                        labels.append(K5ScheduleEntryViewModel.LabelViewModel(text: NSLocalizedString("Late", comment: ""), color: .crimson))
                    }
                    if submissionStates.has_feedback == true {
                        labels.append(K5ScheduleEntryViewModel.LabelViewModel(text: NSLocalizedString("Feedback", comment: ""), color: .ash))
                    }
                    if submissionStates.redo_request == true {
                        labels.append(K5ScheduleEntryViewModel.LabelViewModel(text: NSLocalizedString("Redo", comment: ""), color: .crimson))
                    }
                    if submissionStates.missing == true {
                        labels.append(K5ScheduleEntryViewModel.LabelViewModel(text: NSLocalizedString("Missing", comment: ""), color: .crimson))
                    }
                    if submissionStates.submitted == true && submissionStates.late == false {
                        labels.append(K5ScheduleEntryViewModel.LabelViewModel(text: NSLocalizedString("Submitted", comment: ""), color: .ash))
                    }

                    // TODO: replies
                    return labels
                }()
                let isCompleted = (plannable.planner_override?.marked_complete == true)
                let apiService = PlannerOverrideUpdater(api: AppEnvironment.shared.api, plannable: plannable)

                return K5ScheduleEntryViewModel(leading: .checkbox(isChecked: isCompleted), icon: plannable.k5ScheduleIcon, title: plannable.plannableTitle ?? "", subtitle: nil, labels: labels, score: pointsText, dueText: dueText, route: plannable.htmlURL, apiService: apiService)
            }

            subjects.append(K5ScheduleSubjectViewModel(subject: subject, entries: entries))
        }

        subjects.sort { $0.subject.name < $1.subject.name }

        return .data(subjects)
    }
}
