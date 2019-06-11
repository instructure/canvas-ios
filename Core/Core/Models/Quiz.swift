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
    @NSManaged public var allowedAttempts: Int
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
    @NSManaged public var submission: QuizSubmission?
    @NSManaged var timeLimitRaw: NSNumber? // minutes
    @NSManaged public var title: String

    public var pointsPossible: Double? {
        get { return pointsPossibleRaw?.doubleValue }
        set { pointsPossibleRaw = NSNumber(value: newValue) }
    }

    public var quizType: QuizType {
        get { return QuizType(rawValue: quizTypeRaw) ?? .assignment }
        set { quizTypeRaw = newValue.rawValue }
    }

    public var timeLimit: Double? {
        get { return timeLimitRaw?.doubleValue }
        set { timeLimitRaw = NSNumber(value: newValue) }
    }
}

extension Quiz: DueViewable, GradeViewable, LockStatusViewable {
    public var gradingType: GradingType { return .points }
    public var viewableGrade: String? { return nil }
    public var viewableScore: Double? { return nil }

    public var allowedAttemptsText: String {
        if allowedAttempts < 1 {
            return NSLocalizedString("Unlimited", bundle: .core, comment: "")
        }
        return NumberFormatter.localizedString(from: NSNumber(value: allowedAttempts), number: .none)
    }

    public var questionCountText: String {
        return NumberFormatter.localizedString(from: NSNumber(value: questionCount), number: .none)
    }

    public var nQuestionsText: String {
        let format = NSLocalizedString("d_questions", bundle: .core, comment: "")
        return String.localizedStringWithFormat(format, questionCount)
    }

    public var timeLimitText: String? {
        guard let limit = timeLimit else {
            return NSLocalizedString("None", bundle: .core, comment: "")
        }
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .brief
        return formatter.string(from: TimeInterval(limit * 60))
    }
}

extension Quiz {
    @discardableResult
    static func save(_ item: APIQuiz, in context: NSManagedObjectContext) -> Quiz {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(Quiz.id), item.id.value)
        let model: Quiz = context.fetch(predicate).first ?? context.insert()
        model.allowedAttempts = item.allowed_attempts
        model.details = item.description
        model.dueAt = item.due_at
        model.htmlURL = item.html_url
        model.id = item.id.value
        model.lockAt = item.lock_at
        model.pointsPossible = item.points_possible
        model.questionCount = item.question_count
        model.quizType = item.quiz_type
        model.timeLimit = item.time_limit
        model.title = item.title
        let orderDate = (item.quiz_type == .assignment ? item.due_at : item.lock_at) ?? Date.distantFuture
        model.order = orderDate.isoString()
        return model
    }
}
