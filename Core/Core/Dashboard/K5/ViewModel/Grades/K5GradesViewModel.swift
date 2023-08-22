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

public class K5GradesViewModel: ObservableObject {

    @Published public private(set) var grades: [K5GradeCellViewModel] = []
    @Published public private(set) var gradingPeriods: [K5GradingPeriod] = []
    @Published public private(set) var currentGradingPeriod: K5GradingPeriod

    private let env = AppEnvironment.shared
    private var studentID = ""
    private lazy var courses = env.subscribe(GetUserCourses(userID: studentID)) { [weak self] in
        self?.coursesUpdated()
    }
    private let defaultCurrentGradingPeriod = K5GradingPeriod(periodID: nil, title: NSLocalizedString("Current Grading Period", bundle: .core, comment: ""))

    // MARK: Refresh
    private var refreshCompletion: (() -> Void)?
    private var forceRefresh = false

    init() {
        studentID = env.currentSession?.userID ?? ""
        currentGradingPeriod = defaultCurrentGradingPeriod
        courses.refresh()
    }

    private func coursesUpdated() {
        gradingPeriods = [defaultCurrentGradingPeriod]
        grades = courses.filter({ !$0.isHomeroomCourse }).map {
            let enrollment = $0.enrollments?.first
            let isMultiGradingPeriod = enrollment?.multipleGradingPeriodsEnabled ?? false
            let hideQuantitativeData = enrollment?.hideQuantitativeData == true
            let score = hideQuantitativeData ? nil : isMultiGradingPeriod ? enrollment?.currentPeriodComputedCurrentScore : enrollment?.computedCurrentScore
            let grade: String? = {
                if hideQuantitativeData {
                    return enrollment?.computedCurrentLetterGrade
                } else {
                    return isMultiGradingPeriod ? enrollment?.currentPeriodComputedCurrentGrade : enrollment?.computedCurrentGrade
                }
            }()
            return K5GradeCellViewModel(title: $0.name,
                                        imageURL: $0.imageDownloadURL,
                                        grade: grade,
                                        score: score,
                                        color: $0.color,
                                        courseID: $0.id,
                                        hideGradeBar: hideQuantitativeData)
        }
        var gradingPeriodModels = courses.compactMap { $0.gradingPeriods }.flatMap { $0 }
        gradingPeriodModels.sort(by: {
            guard let date0 = $0.startDate, let date1 = $1.startDate else { return false }
            return date0 < date1
        })
        gradingPeriods.append(contentsOf: gradingPeriodModels.map { K5GradingPeriod(periodID: $0.id, title: $0.title) })
        finishRefresh()
    }

    private func updateEnrollments(for gradingPeriodID: String) {
        let request = GetEnrollmentsRequest(context: .currentUser, userID: studentID, gradingPeriodID: gradingPeriodID, types: [ Role.student.rawValue ], states: [ .active ])
        env.api.makeRequest(request) { [weak self] apiEnrollments, _, _ in
            var grades: [K5GradeCellViewModel] = []
            apiEnrollments?.forEach { enrollment in
                guard let course = self?.courses.first(where: { $0.id == enrollment.course_id?.rawValue }), !course.isHomeroomCourse else { return }
                let shouldHideQuantitativeData = course.hideQuantitativeData
                let grade: String? = {
                    if shouldHideQuantitativeData {
                        return enrollment.computed_current_letter_grade
                    } else {
                        return enrollment.computed_current_grade ?? enrollment.grades?.current_grade
                    }
                }()
                let cellModel = K5GradeCellViewModel(title: course.name ?? "",
                                                     imageURL: course.imageDownloadURL,
                                                     grade: grade,
                                                     score: shouldHideQuantitativeData ? nil : enrollment.computed_current_score ?? enrollment.grades?.current_score,
                                                     color: course.color,
                                                     courseID: course.id,
                                                     hideGradeBar: shouldHideQuantitativeData)
                grades.append(cellModel)
            }
            grades.sort(by: {$0.title < $1.title})
            performUIUpdate {
                self?.grades = grades
            }
            self?.finishRefresh()
        }
    }

    private func finishRefresh() {
        forceRefresh = false
        performUIUpdate {
            self.refreshCompletion?()
            self.refreshCompletion = nil
        }
    }

    public func didSelect(gradingPeriod: K5GradingPeriod) {
        currentGradingPeriod = gradingPeriod
        reloadData()
    }
}

extension K5GradesViewModel: Refreshable {

    @available(*, renamed: "refresh()")
    public func refresh(completion: @escaping () -> Void) {
        Task {
            await refresh()
            completion()
        }
    }

    public func refresh() async {
        forceRefresh = true
        return await withCheckedContinuation { continuation in
            refreshCompletion = {
                continuation.resume()
            }
            reloadData()
        }
    }

    func reloadData() {
        guard let periodID = currentGradingPeriod.periodID else {
            courses.exhaust(force: true)
            return
        }
        updateEnrollments(for: periodID)
    }
}

public struct K5GradingPeriod: Hashable {
    let periodID: String?
    let title: String?
}
