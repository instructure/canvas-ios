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
    @Published public private(set) var gradingPeriods: [GradingPeriod] = []

    private let env = AppEnvironment.shared
    // MARK: Data Sources
    private var studentID = ""
    private lazy var courses = env.subscribe(GetUserCourses(userID: studentID)) { [weak self] in
        self?.coursesUpdated()
    }
    // MARK: Refresh
    private var refreshCompletion: (() -> Void)?
    private var forceRefresh = false

    init() {
        studentID = env.currentSession?.userID ?? ""
        courses.refresh()
    }

    private func coursesUpdated() {
        grades.removeAll()
        grades = courses.filter({ !$0.isHomeroomCourse }).map {
            return K5GradeCellViewModel(a11yId: "K5GradeCell.\($0.id)",
                                        title: $0.name ?? "",
                                        imageURL: $0.imageDownloadURL,
                                        grade: $0.enrollments?.first?.computedCurrentGrade,
                                        score: $0.enrollments?.first?.computedCurrentScore,
                                        color: $0.color,
                                        courseID: $0.id)
        }
        gradingPeriods = courses.compactMap { $0.gradingPeriods }.flatMap { $0 }
        finishRefresh()
    }

    private func finishRefresh() {
        forceRefresh = false
        performUIUpdate {
            self.refreshCompletion?()
            self.refreshCompletion = nil
        }
    }
}

extension K5GradesViewModel: Refreshable {

    public func refresh(completion: @escaping () -> Void) {
        forceRefresh = true
        refreshCompletion = completion
        courses.refresh(force: true)
    }
}
