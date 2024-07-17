//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

import CoreData
import Combine

/// This usecase fetches all grading periods in a given course, then fetches all assignment groups
/// and their assignments in each grading period. API calls are exhausting requests so no paging here.
/// The following objects are saved and linked together: Assignment, AssignmentGroup, GradingPeriod
public class GetAssignmentsByGroup: UseCase {
    public typealias Model = Assignment
    public typealias Response = [AssignmentGroupsByGradingPeriod]
    public typealias GradingPeriodID = ID?
    public struct AssignmentGroupsByGradingPeriod: Codable {
        let gradingPeriod: APIGradingPeriod?
        let assignmentGroups: [APIAssignmentGroup]
    }

    public var cacheKey: String? { "courses/\(courseID)/assignment_groups" }
    public let scope: Scope

    private let gradingPeriodID: String?
    private let courseID: String
    private let gradedOnly: Bool
    private var subscriptions = Set<AnyCancellable>()

    /// - parameters:
    ///     - gradingPeriodID: The grading period used to filter assignments. This parameter only affects the CoreData filtering, in the background all grading periods' assignments are fetched.
    public init(
        courseID: String,
        gradingPeriodID: String? = nil,
        gradedOnly: Bool = false
    ) {
        self.courseID = courseID
        self.gradingPeriodID = gradingPeriodID
        self.gradedOnly = gradedOnly

        let predicate: NSPredicate = {
            var predicate = NSPredicate(key: #keyPath(Assignment.assignmentGroup.courseID), equals: courseID)

            if gradedOnly {
                predicate = predicate.and(NSPredicate(format: "%K != %@", #keyPath(Assignment.gradingTypeRaw), "not_graded"))
            }

            if let gradingPeriodID {
                predicate = predicate.and(NSPredicate(format: "gradingPeriod.id == %@", gradingPeriodID))
            }

            return predicate
        }()

        scope = Scope(
            predicate: predicate,
            order: [
                .init(key: #keyPath(Assignment.assignmentGroup.position), ascending: true),
                .init(key: #keyPath(Assignment.assignmentGroup.name), ascending: true, naturally: true),
                .init(key: #keyPath(Assignment.dueAtSortNilsAtBottom), ascending: true),
                .init(key: #keyPath(Assignment.position), ascending: true),
                .init(key: #keyPath(Assignment.name), ascending: true, naturally: true),
            ],
            sectionNameKeyPath: #keyPath(Assignment.assignmentGroup.position)
        )
    }

    public func makeRequest(
        environment: AppEnvironment,
        completionHandler: @escaping RequestCallback
    ) {
        let getAssignmentGroups: (GradingPeriodID) -> AnyPublisher<[APIAssignmentGroup], Error> = { [courseID] gradingPeriodID in
            let request = GetAssignmentGroupsRequest(
                courseID: courseID,
                gradingPeriodID: gradingPeriodID?.value,
                perPage: 100
            )
            return environment.api.exhaust(request)
                .map(\.body)
                .eraseToAnyPublisher()
        }

        let gradingPeriodsRequest = GetGradingPeriodsRequest(courseID: courseID)
        environment.api.exhaust(gradingPeriodsRequest)
            .flatMap { (gradingPeriods, _) in
                if gradingPeriods.isEmpty {
                    return getAssignmentGroups(nil)
                        .map { [AssignmentGroupsByGradingPeriod(gradingPeriod: nil, assignmentGroups: $0)] }
                        .eraseToAnyPublisher()
                } else {
                    return Publishers
                        .Sequence(sequence: gradingPeriods)
                        .flatMap { gradingPeriod in
                            getAssignmentGroups(gradingPeriod.id)
                                .map { AssignmentGroupsByGradingPeriod(gradingPeriod: gradingPeriod, assignmentGroups: $0) }
                        }
                        .collect()
                        .eraseToAnyPublisher()
                }
            }
            .sink { completion in
                if case .failure(let error) = completion {
                    completionHandler(nil, nil, error)
                }
            } receiveValue: { result in
                completionHandler(result, nil, nil)
            }
            .store(in: &subscriptions)
    }

    public func reset(context: NSManagedObjectContext) {
        let predicate = NSPredicate(key: #keyPath(Assignment.assignmentGroup.courseID), equals: courseID)
        context.delete(context.fetch(predicate) as [Assignment])
    }

    public func write(
        response: [AssignmentGroupsByGradingPeriod]?,
        urlResponse: URLResponse?,
        to client: NSManagedObjectContext
    ) {
        guard let response else { return }

        // For teacher roles this API doesn't return any submissions so we don't want to remove them if they already in CoreData
        let updateSubmission = AppEnvironment.shared.app != .teacher && GetAssignmentGroupsRequest.Include.allCases.contains(.submission)

        response.forEach { item in
            var gradingPeriod: GradingPeriod?

            if let apiGradingPeriod = item.gradingPeriod {
                gradingPeriod = GradingPeriod.save(apiGradingPeriod, courseID: courseID, in: client)
            }

            item.assignmentGroups.forEach { apiAssignmentGroup in
                // This will save the assignments inside
                AssignmentGroup.save(
                    apiAssignmentGroup,
                    courseID: courseID,
                    in: client,
                    updateSubmission: updateSubmission,
                    updateScoreStatistics: GetAssignmentGroupsRequest.Include.allCases.contains(.score_statistics)
                )

                /// We can't iterate the CoreData assignment group since it already could contain assignments from other grading periods
                apiAssignmentGroup.assignments?.map(\.id.value).forEach { assignmentId in
                    let predicate = NSPredicate(format: "id == %@", assignmentId)
                    if let assignment = (client.fetch(predicate) as [Assignment]).first {
                        assignment.gradingPeriod = gradingPeriod
                    }
                }
            }
        }
    }
}
