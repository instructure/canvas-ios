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

public class Quiz: NSManagedObject {
    @NSManaged public var accessCode: String?
    @NSManaged public var allowedAttempts: Int
    @NSManaged public var cantGoBack: Bool
    @NSManaged public var courseID: String
    @NSManaged public var details: String?
    @NSManaged public var dueAt: Date?
    @NSManaged public var hasAccessCode: Bool
    @NSManaged var hideResultsRaw: String?
    @NSManaged public var htmlURL: URL?
    @NSManaged public var id: String
    @NSManaged public var ipFilter: String?
    @NSManaged public var lockAt: Date?
    @NSManaged public var lockExplanation: String?
    @NSManaged public var lockedForUser: Bool
    @NSManaged public var mobileURL: URL?
    @NSManaged public var oneQuestionAtATime: Bool
    @NSManaged public var order: String?
    @NSManaged var pointsPossibleRaw: NSNumber?
    @NSManaged public var questionCount: Int
    @NSManaged var questionTypesRaw: [String]
    @NSManaged var quizTypeRaw: String
    @NSManaged public var requireLockdownBrowser: Bool
    @NSManaged public var requireLockdownBrowserForResults: Bool
    @NSManaged public var shuffleAnswers: Bool
    @NSManaged public var submission: QuizSubmission?
    @NSManaged var timeLimitRaw: NSNumber? // minutes
    @NSManaged public var title: String
    @NSManaged public var unlockAt: Date?

    public var hideResults: QuizHideResults? {
        get { return hideResultsRaw.flatMap { QuizHideResults(rawValue: $0) } }
        set { hideResultsRaw = newValue?.rawValue }
    }

    public var pointsPossible: Double? {
        get { return pointsPossibleRaw?.doubleValue }
        set { pointsPossibleRaw = NSNumber(value: newValue) }
    }

    public var questionTypes: [QuizQuestionType] {
        get { return questionTypesRaw.compactMap { QuizQuestionType(rawValue: $0) } }
        set { questionTypesRaw = newValue.map { $0.rawValue } }
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
        guard var limit = timeLimit else {
            return NSLocalizedString("None", bundle: .core, comment: "")
        }
        limit += submission?.extraTime ?? 0
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .brief
        return formatter.string(from: TimeInterval(limit * 60))
    }

    public var takeInWebOnly: Bool {
        return (
            questionTypes.isEmpty ||
            questionTypes.contains(.calculated_question) || questionTypes.contains(.fill_in_multiple_blanks_question) ||
            hasAccessCode ||
            ipFilter != nil ||
            oneQuestionAtATime ||
            requireLockdownBrowser
        )
    }
}

extension Quiz {
    @discardableResult
    static func save(_ item: APIQuiz, in context: NSManagedObjectContext) -> Quiz {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(Quiz.id), item.id.value)
        let model: Quiz = context.fetch(predicate).first ?? context.insert()
        model.accessCode = item.access_code
        model.allowedAttempts = item.allowed_attempts
        model.cantGoBack = item.cant_go_back ?? false
        model.details = item.description
        model.dueAt = item.due_at
        model.hasAccessCode = item.has_access_code
        model.hideResults = item.hide_results
        model.htmlURL = item.html_url
        model.id = item.id.value
        model.ipFilter = item.ip_filter
        model.lockAt = item.lock_at
        model.lockExplanation = item.lock_explanation
        model.lockedForUser = item.locked_for_user
        model.mobileURL = item.mobile_url
        model.oneQuestionAtATime = item.one_question_at_a_time
        model.pointsPossible = item.points_possible
        model.questionCount = item.question_count
        model.questionTypes = item.question_types ?? []
        model.quizType = item.quiz_type
        model.requireLockdownBrowser = item.require_lockdown_browser
        model.requireLockdownBrowserForResults = item.require_lockdown_browser_for_results
        model.shuffleAnswers = item.shuffle_answers
        model.timeLimit = item.time_limit
        model.title = item.title
        model.unlockAt = item.unlock_at
        let orderDate = (item.quiz_type == .assignment ? item.due_at : item.lock_at) ?? Date.distantFuture
        model.order = orderDate.isoString()
        return model
    }
}
