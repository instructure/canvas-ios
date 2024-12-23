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

public class StaffContactInfoService {
    private let courseIds: [String]
    private let synchronizerQueue = DispatchQueue(label: "com.instructure.staffcontactinfoservice")
    private let enrollments: [BaseEnrollmentType] = [.ta, .teacher]
    private let taskCount: Int
    private var completedTasksCount = 0
    private var collectedUsers: [APIUser] = []
    public var completion: ([APIUser]) -> Void

    public init(courses: [Course], completion: @escaping ([APIUser]) -> Void) {
        self.courseIds = courses.map { $0.id }
        self.taskCount = enrollments.count * courseIds.count
        self.completion = completion
        refresh()
    }

    private func refresh() {
        synchronizerQueue.sync {
            // A previous batch is already in progress
            if completedTasksCount < taskCount {
                return
            }

            completedTasksCount = 0
            collectedUsers = []
        }

        for enrollment in enrollments {
            for courseId in courseIds {
                let context = Context(.course, id: courseId)
                let request = GetContextUsersRequest(context: context, enrollment_type: enrollment, search_term: nil)
                AppEnvironment.shared.api.makeRequest(request) { [weak self] users, _, _ in
                    self?.taskFinished(users: users ?? [])
                }
            }
        }
    }

    private func taskFinished(users: [APIUser]) {
        synchronizerQueue.sync {
            completedTasksCount += 1
            collectedUsers += users

            if completedTasksCount == taskCount {
                completion(collectedUsers)
            }
        }
    }
}
