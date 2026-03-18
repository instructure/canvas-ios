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
        let applyGroupWeightsByCourse: [String: Bool]
    }

    static let cacheKey = "weekly-summary-missing-entries"

    var cacheKey: String? { Self.cacheKey }
    let scope = Scope(
        predicate: NSPredicate(format: "categoryRaw == %@", CDDashboardWeeklySummaryEntry.Category.missing.rawValue),
        order: [NSSortDescriptor(key: "position", ascending: true)]
    )

    private let assignmentWeight: BusinessLogic.AssignmentWeight.Logic
    private var cancellables = Set<AnyCancellable>()

    init(assignmentWeight: BusinessLogic.AssignmentWeight.Logic = BusinessLogic.AssignmentWeight.LogicLive()) {
        self.assignmentWeight = assignmentWeight
    }

    func makeRequest(environment: AppEnvironment, completionHandler: @escaping RequestCallback) {
        let api = environment.api
        fetchMissingRaw(api: api)
            .flatMap { [weak self] missing -> AnyPublisher<Response, Error> in
                guard let self else {
                    return Fail(error: NSError.instructureError("GetMissingWeeklySummaryEntries deallocated"))
                        .eraseToAnyPublisher()
                }
                let applyGroupWeights = Self.extractApplyGroupWeights(from: missing)
                let courseIds = Set(missing.map { $0.course_id.rawValue }).filter { !$0.isEmpty }
                return fetchAssignmentGroupsForCourses(courseIds, api: api)
                    .map { groupsDict in
                        Response(
                            missing: missing,
                            assignmentGroupsByCourse: groupsDict,
                            applyGroupWeightsByCourse: applyGroupWeights
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
            CDDashboardWeeklySummaryEntry.saveMissing(
                assignment,
                weekStart: .distantPast,
                gradeWeight: computeWeight(
                    assignmentId: assignment.id.rawValue,
                    courseId: assignment.course_id.rawValue,
                    applyGroupWeights: response.applyGroupWeightsByCourse,
                    groupsDict: response.assignmentGroupsByCourse
                ),
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

    // MARK: - Weight Computation

    private static func extractApplyGroupWeights(from assignments: [APIAssignment]) -> [String: Bool] {
        var result: [String: Bool] = [:]
        for assignment in assignments {
            if let course = assignment.course {
                result[course.id.rawValue] = course.apply_assignment_group_weights ?? false
            }
        }
        return result
    }

    private func computeWeight(
        assignmentId: String,
        courseId: String,
        applyGroupWeights: [String: Bool],
        groupsDict: [String: [APIAssignmentGroup]]
    ) -> Double? {
        guard applyGroupWeights[courseId] == true, !courseId.isEmpty else { return nil }
        guard let groups = groupsDict[courseId] else { return nil }
        for group in groups {
            guard let assignment = group.assignments?.first(where: { $0.id.rawValue == assignmentId }) else { continue }
            guard assignment.omit_from_final_grade != true else { return nil }
            guard let groupWeight = group.group_weight, groupWeight > 0 else { return nil }
            guard let points = assignment.points_possible, points > 0 else { return nil }
            return computeCourseGradeWeight(assignmentPoints: points, group: group, groupWeight: groupWeight)
        }
        return nil
    }

    private func computeCourseGradeWeight(
        assignmentPoints: Double,
        group: APIAssignmentGroup,
        groupWeight: Double
    ) -> Double? {
        let groupAssignments: [BusinessLogic.AssignmentWeight.GroupAssignment] = (group.assignments ?? []).compactMap {
            guard $0.omit_from_final_grade != true,
                  let pointsPossible = $0.points_possible,
                  pointsPossible > 0
            else {
                return nil
            }

            return BusinessLogic.AssignmentWeight.GroupAssignment(
                id: $0.id.rawValue,
                pointsPossible: pointsPossible,
                scorePercentage: ($0.submission?.values.first?.score ?? 0) / pointsPossible,
                isGraded: $0.submission?.values.first?.workflow_state == .graded
            )
        }

        return assignmentWeight.computeCourseGradeWeight(
            assignmentPoints: assignmentPoints,
            groupWeight: groupWeight,
            assignments: groupAssignments,
            rules: .init(
                dropLowest: group.rules?.drop_lowest ?? 0,
                dropHighest: group.rules?.drop_highest ?? 0,
                neverDropIds: group.rules?.never_drop?.map { $0.rawValue } ?? []
            )
        )
    }
}
