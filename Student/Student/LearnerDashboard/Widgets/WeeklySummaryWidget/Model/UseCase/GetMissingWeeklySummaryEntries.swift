//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

import BusinessLogic
import Combine
import Core
import CoreData
import Foundation

final class GetMissingWeeklySummaryEntries: UseCase {
    typealias Model = CDDashboardWeeklySummaryEntry

    struct Response: Codable {
        let missing: [APIAssignment]
        let assignmentGroupsByCourse: [String: [APIAssignmentGroup]]
    }

    static let cacheKey = "weekly-summary-missing-entries"

    var cacheKey: String? { Self.cacheKey }
    let scope = Scope(
        predicate: NSPredicate(format: "categoryRaw == %@", CDDashboardWeeklySummaryEntry.Category.missing.rawValue),
        order: [NSSortDescriptor(key: "position", ascending: true)]
    )

    private let weightLogic: BusinessLogic.AssignmentWeight.Logic
    private var cancellables = Set<AnyCancellable>()

    init(weightLogic: BusinessLogic.AssignmentWeight.Logic = BusinessLogic.AssignmentWeight.LogicLive()) {
        self.weightLogic = weightLogic
    }

    func makeRequest(environment: AppEnvironment, completionHandler: @escaping RequestCallback) {
        let api = environment.api
        fetchMissingRaw(api: api)
            .flatMap { [weak self] missing -> AnyPublisher<Response, Error> in
                guard let self else {
                    return Fail(error: NSError.instructureError("GetMissingWeeklySummaryEntries deallocated"))
                        .eraseToAnyPublisher()
                }
                let courseIds = Set(missing.map { $0.course_id.rawValue }).filter { !$0.isEmpty }
                return fetchAssignmentGroupsForCourses(courseIds, api: api)
                    .map { groupsByCourseID in
                        Response(
                            missing: missing,
                            assignmentGroupsByCourse: groupsByCourseID
                        )
                    }
                    .eraseToAnyPublisher()
            }
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        completionHandler(nil, nil, error)
                    }
                },
                receiveValue: { response in
                    completionHandler(response, nil, nil)
                }
            )
            .store(in: &cancellables)
    }

    func reset(context: NSManagedObjectContext) {
        context.delete(context.fetch(scope: scope) as [CDDashboardWeeklySummaryEntry])
    }

    func write(response: Response?, urlResponse: URLResponse?, to context: NSManagedObjectContext) {
        guard let response else { return }
        for assignment in response.missing {
            let courseId = assignment.course_id.rawValue
            let groups = response.assignmentGroupsByCourse[courseId] ?? []
            let group = groups.group(containingAssignmentWithId: assignment.id.rawValue)
            CDDashboardWeeklySummaryEntry.saveMissing(
                assignment,
                weekStart: .distantPast,
                gradeWeight: group.flatMap { weightLogic.assignmentWeightInCourse(
                    assignment: .init(isOmittedFromFinalGrade: assignment.omit_from_final_grade, pointsPossible: assignment.points_possible),
                    groupWeight: $0.group_weight,
                    assignmentsInGroup: ($0.assignments ?? []).compactMap { .init(isOmittedFromFinalGrade: $0.omit_from_final_grade, pointsPossible: $0.points_possible) }
                ) },
                in: context
            )
        }
    }

    // MARK: - Raw Data Fetching

    private func fetchMissingRaw(api: API) -> AnyPublisher<[APIAssignment], Error> {
        api.exhaust(GetMissingSubmissionsRequest(includes: [.planner_overrides, .course]))
            .map { (assignments, _) in
                assignments.sorted { ($0.due_at ?? .distantFuture) < ($1.due_at ?? .distantFuture) }
            }
            .eraseToAnyPublisher()
    }

    private func fetchAssignmentGroups(for courseId: String, api: API) -> AnyPublisher<[APIAssignmentGroup], Error> {
        api.exhaust(GetAssignmentGroupsRequest(courseID: courseId, include: [.assignments, .submission], perPage: 100))
            .map { (groups, _) in groups }
            .eraseToAnyPublisher()
    }

    private func fetchAssignmentGroupsForCourses(_ courseIds: Set<String>, api: API) -> AnyPublisher<[String: [APIAssignmentGroup]], Error> {
        guard !courseIds.isEmpty else {
            return Publishers.typedJust([:]).eraseToAnyPublisher()
        }
        let publishers = courseIds.map { courseId in
            fetchAssignmentGroups(for: courseId, api: api)
                .map { (courseId, $0) }
                .eraseToAnyPublisher()
        }
        return Publishers.MergeMany(publishers)
            .collect()
            .map { Dictionary(uniqueKeysWithValues: $0) }
            .eraseToAnyPublisher()
    }

}
