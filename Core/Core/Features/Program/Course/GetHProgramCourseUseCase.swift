//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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
import Foundation

public final class GetHProgramCourseUseCase: APIUseCase {
    public struct RequestModel {
        let programId: String
        let courseIds: [String]

        public init(programId: String, courseIds: [String]) {
            self.programId = programId
            self.courseIds = courseIds
        }

        var cacheKey: String {
            return "\(programId)-\(courseIds.joined(separator: ","))"
        }
    }

    public typealias Model = CDHProgramCourse
    private let programs: [RequestModel]
    private let userId: String
    private let maxLimit = 100
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init

    public init(userId: String, programs: [RequestModel]) {
        self.userId = userId
        self.programs = programs
    }

    public var request: GetHCoursesByIdsRequest {
        let courseIDs = programs.map { $0.courseIds }.flatMap { $0 }
        return GetHCoursesByIdsRequest(courseIDs: courseIDs, userId: userId)
    }

    public var cacheKey: String? {  programs.map { $0.cacheKey }.joined(separator: "-") }

    public func write(
        response: GetHCoursesByIdsResponse?,
        urlResponse _: URLResponse?,
        to client: NSManagedObjectContext
    ) {
        guard let responseData = response?.data?.courses else { return }
        let courseMap = Dictionary(responseData.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })

        for index in programs.indices {
            let program = programs[index]
            let courses = program.courseIds.compactMap { courseMap[$0] }
            courses.forEach { course in
                CDHProgramCourse.save(
                    course,
                    programID: program.programId,
                    in: client
                )
            }
        }
    }

    public func makeRequest(environment: AppEnvironment, completionHandler: @escaping RequestCallback) {
        let allCourseIDs = programs.flatMap { $0.courseIds }
        let uniqueCourseIDs = Array(Set(allCourseIDs))

        func fallbackToSingleCourses() -> AnyPublisher<GetHCoursesByIdsResponse, Error> {
            let singleRequests = uniqueCourseIDs.map { courseID in
                fetchSingleCourse(courseID: courseID, environment: environment)
            }

            return Publishers.MergeMany(singleRequests)
                .collect()
                .map { responses in
                    let mergedCourses = responses.compactMap { $0.data?.course }
                    return GetHCoursesByIdsResponse(
                        data: .init(courses: mergedCourses, course: nil)
                    )
                }
                .eraseToAnyPublisher()
        }

        let chunkedRequests = uniqueCourseIDs
            .chunked(into: maxLimit)
            .map { fetch(request: GetHCoursesByIdsRequest(courseIDs: $0, userId: userId), environment: environment) }

        Publishers.MergeMany(chunkedRequests)
            .flatMap { response -> AnyPublisher<GetHCoursesByIdsResponse, Error> in
                if response.body.data?.courses == nil {
                    return fallbackToSingleCourses()
                }
                return Just(response.body)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            .catch { _ in
                fallbackToSingleCourses()
            }
            .collect()
            .map { responses -> GetHCoursesByIdsResponse in
                let mergedCourses = responses.flatMap { $0.data?.courses ?? [] }
                return GetHCoursesByIdsResponse(
                    data: .init(courses: mergedCourses, course: nil)
                )
            }
            .sinkFailureOrValue(
                receiveFailure: { error in
                    completionHandler(nil, nil, error)
                },
                receiveValue: { response in
                    completionHandler(response, nil, nil)
                }
            )
            .store(in: &subscriptions)
    }

    private func fetchSingleCourse(
        courseID: String,
        environment: AppEnvironment
    ) -> AnyPublisher<GetHCoursesByIdsResponse, Error> {
        fetch(request: GetHCoursesByIdRequest(courseID: courseID), environment: environment)
            .map { response in
                GetHCoursesByIdsResponse(data: .init(courses: nil, course: response.body.data?.course))
            }
            .eraseToAnyPublisher()
    }

    private func fetch<Request: APIRequestable>(
        request: Request,
        environment: AppEnvironment
    ) -> AnyPublisher<(body: Request.Response, urlResponse: HTTPURLResponse?), Error> {
        environment.api.makeRequest(request)
    }
}
