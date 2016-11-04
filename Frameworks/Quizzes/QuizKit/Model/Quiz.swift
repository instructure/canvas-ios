
//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    
    

import UIKit
import SoLazy

/// The Canvas™ assessment tool of choice.
struct Quiz {
    init(id: String, title: String, description: String, due: Due, timeLimit: TimeLimit, scoring: Scoring, questionCount: Int, questionTypes: [Question.Kind], attemptLimit: AttemptLimit, oneQuestionAtATime: Bool, cantGoBack: Bool, hideResults: HideResults, lockAt: NSDate?, lockedForUser: Bool, lockExplanation: String?, ipFilter: String?, mobileURL: NSURL, shuffleAnswers: Bool, hasAccessCode: Bool) {
        self.id = id
        self.title = title
        self.description = description
        self.due = due
        self.timeLimit = timeLimit
        self.scoring = scoring
        self.questionCount = questionCount
        self.questionTypes = questionTypes
        self.attemptLimit = attemptLimit
        self.oneQuestionAtATime = oneQuestionAtATime
        self.cantGoBack = cantGoBack
        self.hideResults = hideResults
        self.lockAt = lockAt
        self.lockedForUser = lockedForUser
        self.lockExplanation = lockExplanation
        self.ipFilter = ipFilter
        self.mobileURL = mobileURL
        self.shuffleAnswers = shuffleAnswers
        self.hasAccessCode = hasAccessCode
    }
    
    /// The id of the quiz.
    let id: String

    /// The title of the quiz.
    let title: String
    
    /// The HTML description of the quiz.
    let description: String
    
    /// The due date of the quiz.
    let due: Due
    
    /// The time limit of the quiz.
    let timeLimit: TimeLimit
    
    /// The points possible for the quiz.
    let scoring: Scoring
    
    /// The number of questions
    let questionCount: Int
    
    /// The types of questions in the quiz
    let questionTypes: [Question.Kind]
    
    /// The number of attempts that are allowed for this quiz.
    let attemptLimit: AttemptLimit
    
    /// Show one question at a time?
    let oneQuestionAtATime: Bool
    
    /// Lock questions after answering? Only applicable if oneQuestionAtATime is true
    /// I would prefer "can" rather than "can't" but that's the way the api does it so...
    let cantGoBack: Bool
    
    /// Let students see their quiz responses?
    let hideResults: HideResults
    
    /// When to lock the quiz
    let lockAt: NSDate?
    
    /// Whether or not this is locked for the user
    let lockedForUser: Bool
    
    /// An explanation of why this is locked for the user
    let lockExplanation: String?
    
    /// Whether or not the quiz is locked to certain IP addresses
    let ipFilter: String? // right now we aren't doing anything special with them. It will be a string that is comma delimited, just what the api gives us
    
    /// A url suitable for loading the quiz in a mobile webview.  it will persiste the
    /// headless session and, for quizzes in courses, will force the user to
    /// login
    let mobileURL: NSURL
    
    /// Whether or not the answers should be shuffled for the student
    let shuffleAnswers: Bool
    
    /// Whether or not the quiz has an access code
    let hasAccessCode: Bool
    
    /**
        When is the quiz due?

        - NoDueDate: The quiz doesn't have a due date.
        - Date: The date that the quiz is due.
    */
    enum Due {
        init(date: NSDate?) {
            if let d = date {
                self = .Date(d)
            } else {
                self = .NoDueDate
            }
        }
        
        case NoDueDate
        case Date(NSDate)
        
        
        var description: String {
            switch self {
            case .Date(let d):
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateStyle = .MediumStyle
                dateFormatter.timeStyle = .MediumStyle
                return dateFormatter.stringFromDate(d)
            case .NoDueDate:
                return NSLocalizedString("No Due Date", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "A quiz that has no due date")
            }
        }
    }

    /**
        The time limit status of the quiz.

        - None: There is no time limit.
        - Minutes: The number of minutes the quiz session is limited to.
    */
    enum TimeLimit {
        init(minutes: Int) {
            if minutes < 0 {
                self = .NoTimeLimit
            } else {
                self = .Minutes(minutes)
            }
        }
        
        case NoTimeLimit
        case Minutes(Int)
        
        
        var description: String {
            let NoTimeLimit = NSLocalizedString("No time limit", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "when a quiz has no time limit")
            
            switch self {
            case .Minutes(let minutes):
                let i18nHours = NSLocalizedString("hr", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "Hours label for time limit")
                let i18nMin = NSLocalizedString("min", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "Minutes label localized")
                
                switch (minutes / 60, minutes % 60) {
                case let (hours, minutes) where hours == 0:
                    return "\(minutes) \(i18nMin)"
                    
                case let (hours, minutes) where minutes == 0:
                    return "\(hours) \(i18nHours)"
                    
                case let (hours, minutes):
                    return "\(hours) \(i18nHours) \(minutes) \(i18nMin)"
                }
            case .NoTimeLimit:
                return NoTimeLimit
            }
        }
    }
    
    /**
        The number of attempts the quiz-taker is allowed.

        - Unlimited: The user can take the quiz adnauseam.
        - Count: The user is limited to the count provided.
    */
    enum AttemptLimit {
        init(allowed: Int) {
            if allowed <= 0 {
                self = .Unlimited
            } else {
                self = .Count(allowed)
            }
        }
        
        case Unlimited
        case Count(Int)
        
        var description: String {
            switch self {
            case .Count(let limit):
                return String(limit)
            case .Unlimited:
                return NSLocalizedString("Unlimited", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "When a quiz has no limit on the number of attempts")
            }
        }
        
        func canRetakeAfterLatestAttemptNumber(attempt: Int) -> Bool {
            switch self {
            case .Count(let limit):
                return attempt < limit
            case .Unlimited:
                return true
            }
        }
    }
    
    /**

    */
    enum HideResults {
        case Always
        case UntilAfterLastAttempt
        case Never
    }
    
    enum Scoring: CustomStringConvertible {
        case Ungraded
        case PointsPossible(Int)
        
        var description: String {
            switch self {
            case .PointsPossible(let points): return String(points)
            default: return NSLocalizedString("Ungraded", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "Ungraded quiz")
            }
        }
    }
}


extension Quiz.Due: JSONDecodable {
    static func fromJSON(json: AnyObject?) -> Quiz.Due? {
        return Quiz.Due(date: NSDate.fromJSON(json))
    }
}

extension Quiz.TimeLimit: JSONDecodable {
    static func fromJSON(json: AnyObject?) -> Quiz.TimeLimit? {
        if let minutes = json as? Int {
            return Quiz.TimeLimit(minutes: minutes)
        }
        return .NoTimeLimit
    }
}

extension Quiz.AttemptLimit: JSONDecodable {
    static func fromJSON(json: AnyObject?) -> Quiz.AttemptLimit? {
        if let count = json as? Int {
            return Quiz.AttemptLimit(allowed: count)
        }
        
        return .Unlimited
    }
}

extension Quiz.HideResults: JSONDecodable {
    static func fromJSON(json: AnyObject?) -> Quiz.HideResults? {
        if let setting = json as? String {
            if setting == "always" {
                return .Always
            } else if setting == "until_after_last_attempt" {
                return .UntilAfterLastAttempt
            }
        }
        
        return .Never
    }
}

extension Quiz.Scoring: JSONDecodable {
    static func fromJSON(json: AnyObject?) -> Quiz.Scoring? {
        let points = json as? Int
        return points.map({ .PointsPossible($0) }) ?? .Ungraded
    }
}

extension Quiz: JSONDecodable {
    static func fromJSON(json: AnyObject?) -> Quiz? {
        if let json = json as? [String: AnyObject] {
            let id = idString(json["id"])
            let title = json["title"] as? String
            let description = json["description"] as? String
            let due = Quiz.Due.fromJSON(json["due_at"])
            let timeLimit = Quiz.TimeLimit.fromJSON(json["time_limit"])
            let scoring = Quiz.Scoring.fromJSON(json["points_possible"])
            let questionCount = json["question_count"] as? Int
            let questionTypes: [Question.Kind] = decodeArray(json["question_types"] as? [AnyObject] ?? [])
            let allowedAttempts = Quiz.AttemptLimit.fromJSON(json["allowed_attempts"])
            let oqqaat = json["one_question_at_a_time"] as? Bool
            let cantGoBack = json["cant_go_back"] as? Bool
            let hideResults = Quiz.HideResults.fromJSON(json["hide_results"])
            let lockedForUser = json["locked_for_user"] as? Bool
            let lockExplanation = json["lock_explanation"] as? String
            let mobileURL = NSURL.fromJSON(json["mobile_url"])
            let shuffleAnswers = json["shuffle_answers"] as? Bool
            let hasAccessCode = json["has_access_code"] as? Bool ?? true
            
            if let id = id, title = title, description=description, due = due, timeLimit = timeLimit, scoring = scoring, questionCount = questionCount, allowedAttempts = allowedAttempts, oqqaat = oqqaat, cantGoBack = cantGoBack, hideResults=hideResults, lockedForUser = lockedForUser, mobileURL = mobileURL, shuffleAnswers = shuffleAnswers
            {
                return Quiz(id: id, title: title, description: description, due: due, timeLimit: timeLimit, scoring: scoring, questionCount: questionCount, questionTypes: questionTypes, attemptLimit: allowedAttempts, oneQuestionAtATime: oqqaat, cantGoBack: cantGoBack, hideResults: hideResults, lockAt: NSDate.fromJSON(json["lock_at"]), lockedForUser: lockedForUser, lockExplanation: lockExplanation, ipFilter: json["ip_filter"] as? String, mobileURL: mobileURL, shuffleAnswers: shuffleAnswers, hasAccessCode: hasAccessCode)
            }
        }
        
        return nil
    }
}

