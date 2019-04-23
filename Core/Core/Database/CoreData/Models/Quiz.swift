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
import CoreData

public class Quiz: NSManagedObject {
    @NSManaged public var courseID: String
    @NSManaged public var details: String?
    @NSManaged public var dueAt: Date?
    @NSManaged public var htmlURL: URL
    @NSManaged public var id: String
    @NSManaged public var lockAt: Date?
    @NSManaged public var order: String?
    @NSManaged var pointsPossibleRaw: NSNumber?
    @NSManaged public var questionCount: Int
    @NSManaged var quizTypeRaw: String
    @NSManaged public var title: String

    public var pointsPossible: Double? {
        get { return pointsPossibleRaw?.doubleValue }
        set { pointsPossibleRaw = NSNumber(value: newValue) }
    }

    public var quizType: QuizType {
        get { return QuizType(rawValue: quizTypeRaw) ?? .assignment }
        set { quizTypeRaw = newValue.rawValue }
    }
}

extension Quiz: DueViewable, GradeViewable, QuestionCountViewable, LockStatusViewable {
    public var gradingType: GradingType { return .points }
    public var viewableGrade: String? { return nil }
    public var viewableScore: Double? { return nil }
}
