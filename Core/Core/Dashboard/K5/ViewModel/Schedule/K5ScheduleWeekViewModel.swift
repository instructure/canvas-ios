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

public class K5ScheduleWeekViewModel: ObservableObject {
    public let todayViewId = NSLocalizedString("Today", comment: "")

    public let weekRange: Range<Date>
    public let isTodayButtonAvailable: Bool
    @Published public var days: [K5ScheduleDayViewModel]

    private var downloadTask: APITask?
    private var isDownloadFinished: Bool {
        guard let downloadTask = downloadTask else { return false }
        return downloadTask.state == .completed
    }

    public init(weekRange: Range<Date>, isTodayButtonAvailable: Bool, days: [K5ScheduleDayViewModel]) {
        self.weekRange = weekRange
        self.isTodayButtonAvailable = isTodayButtonAvailable
        self.days = days
    }

    public func viewDidAppear() {
        if isDownloadFinished {
            return
        }

        let request = GetPlannablesRequest(userID: nil, startDate: weekRange.lowerBound, endDate: weekRange.upperBound, contextCodes: [], filter: "")
        downloadTask = AppEnvironment.shared.api.makeRequest(request) { [weak self] entities, _, _ in
            self?.downloadFinished(entities: entities ?? [])
        }
    }

    private func downloadFinished(entities: [APIPlannable]) {
        let activeItems = entities.filter {
            guard let override = $0.planner_override else { return true }
            return !override.dismissed && !override.marked_complete
        }
        for day in days {
            let plannables = activeItems.filter { day.range.contains($0.plannable_date) }
            performUIUpdate { day.subjects = self.subjects(from: plannables) }
        }
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

            return K5ScheduleSubject(name: name, color: .electric, image: nil)
        }

        var subjects: [K5ScheduleSubjectViewModel] = []

        for (subject, plannables) in plannablesBySubjects {
            let entries: [K5ScheduleEntryViewModel] = plannables.map { plannable in
                let dueText: String = {
                    if plannable.plannable?.all_day == true {
                        return NSLocalizedString("All Day", comment: "")
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

                return K5ScheduleEntryViewModel(leading: .checkbox(isChecked: false), icon: plannable.k5ScheduleIcon, title: plannable.plannableTitle ?? "", subtitle: nil, labels: labels, score: pointsText, dueText: dueText, checkboxChanged: nil, action: {})
            }
            subjects.append(K5ScheduleSubjectViewModel(name: subject.name, color: subject.color, image: subject.image, entries: entries, tapAction: nil))
        }

        subjects.sort { $0.subject.name < $1.subject.name }

        return .data(subjects)
    }
}
