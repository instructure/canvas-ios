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

final class GetWeeklyDueAndGradesEntries: UseCase {
    typealias Model = CDDashboardWeeklySummaryEntry

    struct Response: Codable {
        let due: [APIPlannable]
        let grades: [GetRecentGradedSubmissionsRequest.Response.CourseNode]
        let assignmentGroupsByCourse: [String: [APIAssignmentGroup]]
    }

    static let cacheKeyPrefix = "weekly-summary-entries/"

    let weekStart: Date
    let weekEnd: Date
    let studentId: String
    let cacheKey: String?
    let scope: Scope

    private let weightLogic: BusinessLogic.AssignmentWeight.Logic
    private var cancellables = Set<AnyCancellable>()

    init(
        weekStart: Date,
        studentId: String,
        weightLogic: BusinessLogic.AssignmentWeight.Logic = BusinessLogic.AssignmentWeight.LogicLive()
    ) {
        self.weekStart = weekStart
        self.weekEnd = weekStart.endOfWeek()
        self.studentId = studentId
        self.weightLogic = weightLogic
        self.cacheKey = "\(Self.cacheKeyPrefix)\(weekStart.isoString())"
        self.scope = Scope(
            predicate: NSPredicate(
                format: "%K == %@",
                #keyPath(CDDashboardWeeklySummaryEntry.weekStart),
                weekStart as NSDate
            ),
            order: [NSSortDescriptor(key: #keyPath(CDDashboardWeeklySummaryEntry.position), ascending: true)]
        )
    }

    func makeRequest(environment: AppEnvironment, completionHandler: @escaping RequestCallback) {
        let api = environment.api
        Publishers.Zip(
            fetchDueRaw(api: api),
            fetchRecentGradesRaw(api: api)
        )
        .flatMap { [weak self] due, grades -> AnyPublisher<Response, Error> in
            guard let self else {
                return Fail(error: NSError.instructureError("GetWeeklyDueAndGradesEntries deallocated"))
                    .eraseToAnyPublisher()
            }
            let courseIds = Set(due.map { $0.context?.id ?? "" }).filter { !$0.isEmpty }
            return self.fetchAssignmentGroupsForCourses(courseIds, api: api)
                .map { groupsByCourseID in
                    Response(due: due, grades: grades, assignmentGroupsByCourse: groupsByCourseID)
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

    func write(response: Response?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let response else { return }
        for plannable in response.due {
            let courseId = plannable.context?.id ?? ""
            let assignmentId = plannable.plannable_id.value
            let groups = response.assignmentGroupsByCourse[courseId] ?? []
            let group = groups.group(containingAssignmentWithId: assignmentId)
            guard let assignment = findAssignment(id: assignmentId, courseId: courseId, in: response.assignmentGroupsByCourse) else { continue }
            CDDashboardWeeklySummaryEntry.saveDue(
                plannable,
                assignment: assignment,
                weekStart: weekStart,
                gradeWeight: group.flatMap { weightLogic.assignmentWeightInCourse(
                    assignment: .init(isOmittedFromFinalGrade: assignment.omit_from_final_grade, pointsPossible: assignment.points_possible),
                    groupWeight: $0.group_weight,
                    assignmentsInGroup: ($0.assignments ?? []).compactMap { .init(isOmittedFromFinalGrade: $0.omit_from_final_grade, pointsPossible: $0.points_possible) }
                ) },
                in: client
            )
        }

        for courseNode in response.grades {
            for edge in courseNode.submissions.edges {
                let submission = edge.node
                if submission.gradeHidden == true { continue }
                guard let gradedAt = submission.gradedAt, gradedAt < weekEnd else { continue }
                let course: Course? = client.first(where: #keyPath(Course.id), equals: courseNode._id)
                CDDashboardWeeklySummaryEntry.saveGrade(
                    submission,
                    courseId: courseNode._id,
                    gradedAt: gradedAt,
                    weekStart: weekStart,
                    restrictQuantitativeData: course?.settings?.restrictQuantitativeData ?? false,
                    in: client
                )
            }
        }
    }

    // MARK: - Raw Data Fetching

    private func fetchDueRaw(api: API) -> AnyPublisher<[APIPlannable], Error> {
        let request = GetPlannablesRequest(
            userID: "self",
            startDate: weekStart.startOfDay(),
            endDate: weekEnd
        )
        return api.exhaust(request)
            .map { (plannables, _) in
                plannables
                    .filter { $0.plannableType == .assignment || $0.plannableType == .sub_assignment }
                    .sorted { $0.plannable_date < $1.plannable_date }
            }
            .eraseToAnyPublisher()
    }

    private func fetchRecentGradesRaw(api: API) -> AnyPublisher<[GetRecentGradedSubmissionsRequest.Response.CourseNode], Error> {
        let request = GetRecentGradedSubmissionsRequest(variables: .init(
            studentId: studentId,
            gradedSince: weekStart.startOfDay().isoString()
        ))
        return api.makeRequest(request)
            .map { (response, _) in response.data.allCourses }
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

    // MARK: - Assignment Lookup

    private func findAssignment(id: String, courseId: String, in groupsByCourseID: [String: [APIAssignmentGroup]]) -> APIAssignment? {
        groupsByCourseID[courseId]?
            .flatMap { $0.assignments ?? [] }
            .first { $0.id.rawValue == id }
    }
}
