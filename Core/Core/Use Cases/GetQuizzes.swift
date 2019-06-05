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

import CoreData
import Foundation

public struct GetQuizzes: CollectionUseCase {
    public typealias Model = Quiz

    public let courseID: String

    public init(courseID: String) {
        self.courseID = courseID
    }

    public var cacheKey: String? {
        return "get-courses-\(courseID)-quizzes"
    }

    public var request: GetQuizzesRequest {
        return GetQuizzesRequest(courseID: courseID)
    }

    public var scope: Scope {
        return Scope(
            predicate: NSPredicate(format: "%K == %@", #keyPath(Quiz.courseID), courseID),
            order: [
                NSSortDescriptor(key: #keyPath(Quiz.quizTypeRaw), ascending: true),
                NSSortDescriptor(key: #keyPath(Quiz.order), ascending: true),
                NSSortDescriptor(key: #keyPath(Quiz.title), ascending: true, selector: #selector(NSString.localizedStandardCompare(_:))),
            ],
            sectionNameKeyPath: #keyPath(Quiz.quizTypeRaw)
        )
    }

    public func write(response: [APIQuiz]?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let response = response else { return }
        for item in response {
            let model = Quiz.save(item, in: client)
            model.courseID = courseID
        }
    }
}
