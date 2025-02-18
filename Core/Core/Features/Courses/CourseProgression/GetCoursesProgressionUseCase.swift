//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

public class GetCoursesProgressionUseCase: APIUseCase {

    // MARK: - Typealias

    public typealias Model = CDCourseProgression
    public typealias Request = GetCoursesProgressionRequest

    // MARK: - Properties

    public var cacheKey: String?
    private let courseId: String?
    private let userId: String
    private let searchTerm: String?
    private let orderByInstitution: Bool

    public var request: GetCoursesProgressionRequest {
        .init(userId: userId)
    }

    // MARK: - Init

    public init(
        userId: String,
        courseId: String? = nil,
        searchTerm: String? = nil,
        orderByInstitution: Bool = false
    ) {
        self.userId = userId
        self.courseId = courseId
        self.searchTerm = searchTerm
        self.orderByInstitution = orderByInstitution
    }

    // MARK: - Functions

    public func write(
        response: GetCoursesProgressionResponse?,
        urlResponse: URLResponse?,
        to client: NSManagedObjectContext
    ) {
        let enrollments = response?.data?.user?.enrollments ?? []
        enrollments.forEach { enrollment in
            CDCourseProgression.save(enrollment, in: client)
        }
    }

    public var scope: Scope {
        if let courseId = courseId {
            return .where(#keyPath(CDCourseProgression.courseID), equals: courseId)
        }

        var predicate: NSPredicate?

        if let searchTerm = searchTerm, searchTerm.isEmpty == false {
            let namePredicate = NSPredicate(format: "%K CONTAINS[c] %@", #keyPath(CDCourseProgression.course.name), searchTerm)
            let institutionNamePredicate = NSPredicate(format: "%K CONTAINS[c] %@", #keyPath(CDCourseProgression.institutionName), searchTerm)
            predicate = NSCompoundPredicate(type: .or, subpredicates: [namePredicate, institutionNamePredicate])
        }

        if orderByInstitution {
            return Scope(predicate: predicate ?? .all, order: [NSSortDescriptor(key: #keyPath(CDCourseProgression.institutionName), ascending: true)])
        }
        
        return .all
    }

}
