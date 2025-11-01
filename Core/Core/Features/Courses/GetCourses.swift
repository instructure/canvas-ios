//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

import Foundation
import CoreData

public class GetCourse: APIUseCase {
    public typealias Model = Course

    public private(set) var courseID: String
    private let include: [GetCourseRequest.Include]
    private var isRootCalling: Bool = false

    public init(courseID: String, include: [GetCourseRequest.Include] = GetCourseRequest.defaultIncludes) {
        self.courseID = courseID
        self.include = include
    }

    public func modified(for env: AppEnvironment) -> Self {
        let modifiedCase = self

        if env.isRoot == false {
            // Should always be used in global-form ID when this
            // use case is used in inner course details pages
            modifiedCase.courseID = courseID.asGlobalID(of: env.contextShardID)
            modifiedCase.isRootCalling = true
        }

        return modifiedCase
    }

    public var cacheKey: String? {
        return "get-course-\(courseID)"
    }

    public var scope: Scope {
        return .where(#keyPath(Course.id), equals: courseID)
    }

    public var request: GetCourseRequest {
        return GetCourseRequest(courseID: courseID, include: include)
    }

    public func makeRequest(
        environment: AppEnvironment,
        completionHandler: @escaping (APICourse?, URLResponse?, Error?) -> Void
    ) {
        // Even for instances where `isRootCalling` is set to false, this use case would
        // still be calling the root API, the difference would be in tweaking `courseID`
        // parameter. 
        let env = isRootCalling ? environment.root : environment
        env.api.makeRequest(request, callback: completionHandler)
    }
}

public class GetCourses: CollectionUseCase {
    public typealias Model = Course
    public typealias Response = GetCoursesRequest.Response

    let showFavorites: Bool
    let enrollmentState: GetCoursesRequest.EnrollmentState?
    let perPage: Int

    public var scope: Scope {
        let order = [
            NSSortDescriptor(key: #keyPath(Course.name), ascending: true, naturally: true),
            NSSortDescriptor(key: #keyPath(Course.id), ascending: true)
        ]
        let predicate: NSPredicate
        if showFavorites {
            predicate = NSPredicate(key: #keyPath(Course.isFavorite), equals: true)
        } else if let enrollmentState = enrollmentState {
            predicate = NSPredicate(format: "ANY %K == %@", #keyPath(Course.enrollments.stateRaw), enrollmentState.rawValue)
        } else {
            predicate = .all
        }
        return Scope(predicate: predicate, order: order)
    }

    public var request: GetCoursesRequest {
        return GetCoursesRequest(enrollmentState: enrollmentState, perPage: perPage)
    }

    public var cacheKey: String? {
        if let enrollmentState = enrollmentState {
            return "get-courses-\(enrollmentState)"
        }
        return "get-courses"
    }

    public init(showFavorites: Bool = false, enrollmentState: GetCoursesRequest.EnrollmentState? = .active, perPage: Int = 100) {
        self.showFavorites = showFavorites
        self.enrollmentState = enrollmentState
        self.perPage = perPage
    }
}

public class GetAllCourses: CollectionUseCase {
    public typealias Model = Course
    public typealias Response = [APICourse]

    public let cacheKey: String? = "courses"

    public var request: GetCoursesRequest {
        return GetCoursesRequest(enrollmentState: nil, state: [ .current_and_concluded ], perPage: 100)
    }

    private var scopePredicate: NSPredicate {
        var predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "NONE %K IN %@", #keyPath(Course.enrollments.stateRaw), [EnrollmentState.invited.rawValue]),
            NSPredicate(format: "ANY %K != %@", #keyPath(Course.enrollments.stateRaw), EnrollmentState.deleted.rawValue),
            NSPredicate(key: #keyPath(Course.isCourseDeleted), equals: false) ])
        if AppEnvironment.shared.app == .student && AppEnvironment.shared.currentSession?.isFakeStudent == false {
            predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate,
                                                                            NSPredicate(format: "%K == YES", #keyPath(Course.isPublished)) ])
        }
        return predicate
    }

    public var scope: Scope {
        Scope(predicate: scopePredicate, order: [
            NSSortDescriptor(key: #keyPath(Course.isPastEnrollment), ascending: true),
            NSSortDescriptor(key: #keyPath(Course.name), ascending: true, naturally: true),
            NSSortDescriptor(key: #keyPath(Course.id), ascending: true)
        ], sectionNameKeyPath: #keyPath(Course.isPastEnrollment))
    }

    public init() {}
}

public class GetUserCourses: CollectionUseCase {
    public typealias Model = Course
    public typealias Response = Request.Response

    let userID: String

    public init(userID: String) {
        self.userID = userID
    }

    public var cacheKey: String? { "users/\(userID)/courses" }
    public var request: GetCoursesRequest {
        GetCoursesRequest(perPage: 100)
    }

    public var scope: Scope { Scope(
        predicate: NSPredicate(format: "ANY %K == %@", #keyPath(Course.enrollments.userID), userID),
        order: [
            NSSortDescriptor(key: #keyPath(Course.name), ascending: true, naturally: true),
            NSSortDescriptor(key: #keyPath(Course.id), ascending: true)
        ]
    ) }
}

public class GetCourseSettings: APIUseCase {
    public typealias Model = CourseSettings

    private(set) var courseID: String
    private var isRootCalling: Bool = false

    public init(courseID: String) {
        self.courseID = courseID
    }

    public var cacheKey: String? { "courses/\(courseID)/settings" }
    public var request: GetCourseSettingsRequest {
        GetCourseSettingsRequest(courseID: courseID)
    }

    public var scope: Scope {
        .where(#keyPath(CourseSettings.courseID), equals: courseID)
    }

    public func modified(for env: AppEnvironment) -> Self {
        let modifiedCase = self

        if env.isRoot == false {
            modifiedCase.courseID = courseID.asGlobalID(of: env.contextShardID)
            modifiedCase.isRootCalling = true
        }

        return modifiedCase
    }

    public func makeRequest(
        environment: AppEnvironment,
        completionHandler: @escaping (APICourseSettings?, URLResponse?, Error?) -> Void
    ) {
        let env = isRootCalling ? environment.root : environment
        env.root.api.makeRequest(request, callback: completionHandler)
    }

    public func write(response: APICourseSettings?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        if let item = response {
            CourseSettings.save(item, courseID: courseID, in: client)
        }
    }
}

public class MarkFavoriteCourse: APIUseCase {
    let courseID: String
    let markAsFavorite: Bool

    public var cacheKey: String? { nil }
    public var request: MarkFavoriteRequest {
        MarkFavoriteRequest(context: .course(courseID), markAsFavorite: markAsFavorite)
    }

    public init(courseID: String, markAsFavorite: Bool) {
        self.courseID = courseID
        self.markAsFavorite = markAsFavorite
    }

    public var scope: Scope {
        .where(#keyPath(Course.id), equals: courseID)
    }

    public func write(response: APIFavorite?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let item = response else {
            return
        }

        if let course: Course = client.first(where: #keyPath(Course.id),
                                             equals: item.context_id.value) {
            course.isFavorite = markAsFavorite
        }

        if let course: CDAllCoursesCourseItem = client.first(where: #keyPath(CDAllCoursesCourseItem.courseId),
                                                             equals: item.context_id.value) {
            course.isFavorite = markAsFavorite
        }

        NotificationCenter.default.post(name: .favoritesDidChange, object: nil, userInfo: [:])
    }
}

struct UpdateCourse: APIUseCase {
    typealias Model = Course

    private(set) var courseId: String

    let name: String?
    let defaultView: CourseDefaultView?
    let syllabusBody: String?
    let syllabusSummary: Bool?

    let cacheKey: String? = nil
    private var isRootCalling: Bool = false

    init(
        courseID: String,
        name: String? = nil,
        defaultView: CourseDefaultView? = nil,
        syllabusBody: String? = nil,
        syllabusSummary: Bool? = nil
    ) {
        self.courseId = courseID
        self.name = name
        self.defaultView = defaultView
        self.syllabusBody = syllabusBody
        self.syllabusSummary = syllabusSummary
    }

    var request: PutCourseRequest {
        PutCourseRequest(
            courseID: courseId,
            courseName: name,
            defaultView: defaultView,
            syllabusBody: syllabusBody,
            syllabusSummary: syllabusSummary
        )
    }

    func modified(for env: AppEnvironment) -> Self {
        var modifiedCase = self

        if env.isRoot == false {
            modifiedCase.courseId = courseId.asGlobalID(of: env.contextShardID)
            modifiedCase.isRootCalling = true
        }

        return modifiedCase
    }

    func makeRequest(
        environment: AppEnvironment,
        completionHandler: @escaping (APICourse?, URLResponse?, Error?) -> Void
    ) {
        let env = isRootCalling ? environment.root : environment
        env.api.makeRequest(request, callback: completionHandler)
    }

    func write(response: APICourse?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let response = response else { return }

        let course: Course? = client.first(where: #keyPath(Course.id), equals: courseId)
        if let syllabusBody = request.body?.course.syllabus_body {
            course?.syllabusBody = syllabusBody
        }

        let settings: CourseSettings? = client.first(where: #keyPath(CourseSettings.courseID), equals: courseId)
        if let syllabusSummary = request.body?.course.syllabus_course_summary {
            settings?.syllabusCourseSummary = syllabusSummary
        }

        course?.name = response.name
        course?.defaultView = response.default_view
    }
}

struct GetCourseWithGradingSchemeOnly: APIUseCase {
    typealias Model = Course
    typealias Request = GetCourseRequest
    typealias Response = APICourse

    public private(set) var request: Request
    public let cacheKey: String?
    public let scope: Scope

    private var courseId: String

    init(courseId: String) {
        self.request = Request(courseID: courseId, include: [.grading_scheme])
        self.cacheKey = "get-course-with-grading-scheme-only-\(courseId)"
        self.scope = .where(#keyPath(Model.id), equals: courseId)
        self.courseId = courseId
    }

    func modified(for env: AppEnvironment) -> GetCourseWithGradingSchemeOnly {
        var modifiedCase = self

        if env.isRoot == false {
            let newCourseID = courseId.asGlobalID(of: env.contextShardID)
            modifiedCase.courseId = newCourseID
            modifiedCase.request = Request(courseID: newCourseID, include: request.include)
        }

        return modifiedCase
    }

    func write(response: Response?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard
            let response,
            let gradingScheme = response.grading_scheme?.compactMap(GradingSchemeEntry.init),
            let pointsBasedGradingScheme = response.points_based_grading_scheme,
            let scalingFactor = response.scaling_factor
        else { return }

        if let course: Model = client.first(where: #keyPath(Model.id), equals: courseId) {
            course.gradingSchemeRaw = gradingScheme.jsonData
            course.pointsBasedGradingScheme = pointsBasedGradingScheme
            course.scalingFactor = scalingFactor
        } else {
            Model.save(response, in: client)
        }
    }
}
