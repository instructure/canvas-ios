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

import Combine
import CoreData
import Foundation

public struct InvitationAcceptResponse: Codable {
    let success: Bool
    let course: APICourse?
    let enrollments: [APIEnrollment]?
}

public class AcceptCourseInvitation: UseCase {
    public typealias Model = Enrollment
    public typealias Response = InvitationAcceptResponse

    public var scope: Scope {
        .where(#keyPath(Enrollment.id), equals: enrollmentID)
    }
    public let cacheKey: String? = nil
    public let ttl: TimeInterval = 0

    private let courseID: String
    private let enrollmentID: String
    private var subscriptions = Set<AnyCancellable>()

    public init(courseID: String, enrollmentID: String) {
        self.courseID = courseID
        self.enrollmentID = enrollmentID
    }

    public func makeRequest(environment: AppEnvironment, completionHandler: @escaping RequestCallback) {
        let handleRequest = HandleCourseInvitationRequest(
            courseID: courseID,
            enrollmentID: enrollmentID,
            isAccepted: true
        )
        let courseID = courseID

        environment.api.makeRequest(handleRequest)
            .flatMap { handleResponse, handleURLResponse -> AnyPublisher<(InvitationAcceptResponse, URLResponse?), Error> in
                guard handleResponse.success else {
                    return Fail(error: NSError.internalError())
                        .eraseToAnyPublisher()
                }

                let getCoursePublisher = environment.api.makeRequest(GetCourseRequest(courseID: courseID))
                    .map { $0.body }
                    .catch { _ -> Just<APICourse?> in
                        return Just(nil)
                    }
                    .setFailureType(to: Error.self)

                let getEnrollmentsPublisher = environment.api.makeRequest(GetEnrollmentsRequest(context: .course(courseID)))
                    .map { $0.body }
                    .catch { _ -> Just<[APIEnrollment]?> in
                        return Just(nil)
                    }
                    .setFailureType(to: Error.self)

                return Publishers.Zip(getCoursePublisher, getEnrollmentsPublisher)
                    .map { courseResponse, enrollmentsResponse in
                        let response = InvitationAcceptResponse(
                            success: true,
                            course: courseResponse,
                            enrollments: enrollmentsResponse
                        )
                        return (response, handleURLResponse)
                    }
                    .eraseToAnyPublisher()
            }
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        completionHandler(nil, nil, error)
                    }
                },
                receiveValue: { response, urlResponse in
                    completionHandler(response, urlResponse, nil)
                }
            )
            .store(in: &subscriptions)
    }

    public func write(response: InvitationAcceptResponse?, urlResponse: URLResponse?, to context: NSManagedObjectContext) {
        guard let response else { return }

        if let apiCourse = response.course {
            Course.save(apiCourse, in: context)
        }

        guard let apiEnrollments = response.enrollments else {
            return
        }

        for apiEnrollment in apiEnrollments {
            guard let enrollmentId = apiEnrollment.id?.value else { continue }
            let enrollment: Enrollment = context.first(
                where: #keyPath(Enrollment.id),
                equals: enrollmentId
            ) ?? context.insert()

            enrollment.update(
                fromApiModel: apiEnrollment,
                course: nil,
                in: context
            )

            if enrollmentId == self.enrollmentID {
                enrollment.isFromInvitation = false
            }
        }
    }
}
