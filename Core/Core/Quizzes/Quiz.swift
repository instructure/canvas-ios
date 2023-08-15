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
    @NSManaged public var allDates: Set<AssignmentDate>
    @NSManaged public var allowedAttempts: Int
    @NSManaged public var assignmentID: String?
    @NSManaged public var cantGoBack: Bool
    @NSManaged public var courseID: String
    @NSManaged public var details: String?
    @NSManaged public var dueAt: Date?
    @NSManaged public var hasAccessCode: Bool
    @NSManaged public var hideCorrectAnswersAt: Date?
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
    @NSManaged public var published: Bool
    @NSManaged public var questionCount: Int
    @NSManaged var questionTypesRaw: [String]
    @NSManaged var quizTypeOrder: Int
    @NSManaged var quizTypeRaw: String
    @NSManaged public var requireLockdownBrowser: Bool
    @NSManaged public var requireLockdownBrowserForResults: Bool
    @NSManaged public var scoringPolicyRaw: String?
    @NSManaged public var showCorrectAnswers: Bool
    @NSManaged public var showCorrectAnswersAt: Date?
    @NSManaged public var showCorrectAnswersLastAttempt: Bool
    @NSManaged public var shuffleAnswers: Bool
    @NSManaged public var submission: QuizSubmission?
    @NSManaged var timeLimitRaw: NSNumber? // minutes
    @NSManaged public var title: String
    @NSManaged public var unlockAt: Date?
    @NSManaged public var unpublishable: Bool

    public var course: Course? {
        managedObjectContext?.first(where: #keyPath(Course.id), equals: courseID)
    }

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

    public var scoringPolicy: ScoringPolicy? {
        get { return scoringPolicyRaw.flatMap { ScoringPolicy(rawValue: $0) } }
        set { scoringPolicyRaw = newValue?.rawValue }
    }

    public var timeLimit: Double? {
        get { return timeLimitRaw?.doubleValue }
        set { timeLimitRaw = NSNumber(value: newValue) }
    }

    public var canTake: Bool {
        guard let submission = self.submission else { return !lockedForUser }
        return !lockedForUser && (
            submission.canResume ||
            allowedAttempts < 1 || submission.attemptsLeft > 0
        )
    }

    public var resultsURL: URL? {
        guard let path = submission.flatMap({ resultsPath(for: $0.attempt) }) else {
            return nil
        }
        return URL(string: path, relativeTo: AppEnvironment.shared.api.baseURL)
    }

    public var hideQuantitativeData: Bool {
        course?.hideQuantitativeData == true
    }

    public func resultsPath(for attempt: Int) -> String? {
        switch hideResults {
        case .always:
            return nil
        case .until_after_last_attempt where allowedAttempts < 1 || attempt < allowedAttempts:
            return nil
        default:
            return "/courses/\(courseID)/quizzes/\(id)/history?attempt=\(attempt)"
        }
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
}

extension Quiz {
    @discardableResult
    static func save(_ item: APIQuiz, in context: NSManagedObjectContext) -> Quiz {
        let model: Quiz = context.first(where: #keyPath(Quiz.id), equals: item.id.value) ?? context.insert()
        model.accessCode = item.access_code

        if let dates = item.all_dates {
            model.allDates = Set(dates.map {
                AssignmentDate.save($0, quizID: item.id.value, in: context)
            })
        }

        model.allowedAttempts = item.allowed_attempts ?? 0
        model.assignmentID = item.assignment_id?.value
        model.cantGoBack = item.cant_go_back ?? false
        model.details = item.description
        model.dueAt = item.due_at
        model.hasAccessCode = item.has_access_code ?? false
        model.hideCorrectAnswersAt = item.hide_correct_answers_at
        model.hideResults = item.hide_results
        model.htmlURL = item.html_url
        model.id = item.id.value
        model.ipFilter = item.ip_filter
        model.lockAt = item.lock_at
        model.lockExplanation = item.lock_explanation
        model.lockedForUser = item.locked_for_user ?? false
        model.mobileURL = item.mobile_url
        model.oneQuestionAtATime = item.one_question_at_a_time ?? false
        model.pointsPossible = item.points_possible
        model.published = item.published == true
        model.questionCount = item.question_count ?? 0
        model.questionTypes = item.question_types ?? []
        model.quizType = item.quiz_type
        model.quizTypeOrder = QuizType.allCases.firstIndex(of: item.quiz_type) ?? QuizType.allCases.count
        model.requireLockdownBrowser = item.require_lockdown_browser
        model.requireLockdownBrowserForResults = item.require_lockdown_browser_for_results
        model.scoringPolicy = item.scoring_policy
        model.showCorrectAnswers = item.show_correct_answers == true
        model.showCorrectAnswersAt = item.show_correct_answers_at
        model.showCorrectAnswersLastAttempt = item.show_correct_answers_last_attempt == true
        model.shuffleAnswers = item.shuffle_answers ?? false
        model.timeLimit = item.time_limit
        model.title = item.title
        model.unlockAt = item.unlock_at
        model.unpublishable = item.unpublishable == true
        let orderDate = (item.quiz_type == .assignment ? item.due_at : item.lock_at) ?? Date.distantFuture
        model.order = orderDate.isoString()
        return model
    }
}

public enum QuizQuestionType: String, Codable, CaseIterable {
    case calculated_question, essay_question, file_upload_question, fill_in_multiple_blanks_question,
        matching_question, multiple_answers_question, multiple_choice_question, multiple_dropdowns_question,
        numerical_question, short_answer_question, text_only_question, true_false_question
}

/** Dictates whether or not quiz results are hidden from students. If null, students can see their results after any attempt. If `always`, students can never see their results. If `until_after_last_attempt`, students can only see results after their last attempt. (Only valid if `allowed_attempts` > 1). */
public enum QuizHideResults: String, Codable, CaseIterable {
    case always, until_after_last_attempt

    public var text: String {
        switch self {
        case .always:
            return NSLocalizedString("No", bundle: .core, comment: "")
        case .until_after_last_attempt:
            return NSLocalizedString("After Last Attempt", bundle: .core, comment: "")
        }
    }
}

public enum QuizType: String, Codable, CaseIterable {
    case assignment, practice_quiz, graded_survey, survey, quizzes_next = "quizzes.next"

    public var sectionTitle: String {
        switch self {
        case .assignment:
            return NSLocalizedString("Assignments", bundle: .core, comment: "")
        case .practice_quiz:
            return NSLocalizedString("Practice Quizzes", bundle: .core, comment: "")
        case .graded_survey:
            return NSLocalizedString("Graded Surveys", bundle: .core, comment: "")
        case .survey:
            return NSLocalizedString("Surveys", bundle: .core, comment: "")
        case .quizzes_next:
            return NSLocalizedString("New Quizzes", bundle: .core, comment: "")
        }
    }

    public var name: String {
        switch self {
        case .assignment:
            return NSLocalizedString("Graded Quiz", bundle: .core, comment: "")
        case .practice_quiz:
            return NSLocalizedString("Practice Quiz", bundle: .core, comment: "")
        case .graded_survey:
            return NSLocalizedString("Graded Survey", bundle: .core, comment: "")
        case .survey:
            return NSLocalizedString("Ungraded Survey", bundle: .core, comment: "")
        case .quizzes_next:
            return NSLocalizedString("New Quiz", bundle: .core, comment: "")
        }
    }
}

public enum ScoringPolicy: String, Codable, CaseIterable {
    case keep_latest, keep_highest, keep_average

    public var text: String {
        switch self {
        case .keep_latest:
            return NSLocalizedString("Latest", bundle: .core, comment: "")
        case .keep_highest:
            return NSLocalizedString("Highest", bundle: .core, comment: "")
        case .keep_average:
            return NSLocalizedString("Average", bundle: .core, comment: "")
        }
    }
}
