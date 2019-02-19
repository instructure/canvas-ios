//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation

public class GetCourse: DetailUseCase<GetCourseRequest, Course> {
    let courseID: String

    public init(courseID: String, env: AppEnvironment = .shared) {
        self.courseID = courseID
        let request = GetCourseRequest(courseID: courseID)
        super.init(api: env.api, database: env.database, request: request)
    }

    override public var predicate: NSPredicate {
        return NSPredicate(format: "%K == %@", #keyPath(Course.id), courseID)
    }

    override public func updateModel(_ model: Course, using item: APICourse, in client: PersistenceClient) throws {
        if model.id.isEmpty { model.id = item.id }
        model.name = item.name
        model.isFavorite = item.is_favorite ?? false
        model.courseCode = item.course_code
        model.imageDownloadURL = item.image_download_url

        try model.enrollments?.forEach { try client.delete($0) }
        model.enrollments = nil

        if let apiEnrollments = item.enrollments {
            let enrollmentModels: [Enrollment] = try apiEnrollments.map { apiItem in
                let e: Enrollment = client.insert()
                try e.update(fromApiModel: apiItem, course: model, in: client)
                return e
            }
            model.enrollments = Set(enrollmentModels)
        }
    }
}

// TODO: rename to GetCourse when we migrate to using Store
public class GetCourseUseCase: APIUseCase {
    public typealias Model = Course

    public let courseID: String

    public init(courseID: String) {
        self.courseID = courseID
    }

    public var cacheKey: String {
        return "get-course-\(courseID)"
    }

    public var scope: Scope {
        return .where(#keyPath(Course.id), equals: courseID)
    }

    public var request: GetCourseRequest {
        return GetCourseRequest(courseID: courseID)
    }

    public func write(response: APICourse?, urlResponse: URLResponse?, to client: PersistenceClient) throws {
        guard let item = response else {
            return
        }
        let model: Course = client.fetch(scope.predicate).first ?? client.insert()
        model.id = item.id
        model.name = item.name
        model.isFavorite = item.is_favorite ?? false
        model.courseCode = item.course_code
        model.imageDownloadURL = item.image_download_url

        try model.enrollments?.forEach { try client.delete($0) }
        model.enrollments = nil

        if let apiEnrollments = item.enrollments {
            let enrollmentModels: [Enrollment] = try apiEnrollments.map { apiItem in
                let e: Enrollment = client.insert()
                try e.update(fromApiModel: apiItem, course: model, in: client)
                return e
            }
            model.enrollments = Set(enrollmentModels)
        }
    }
}
