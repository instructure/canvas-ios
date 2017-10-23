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


/// The Canvas™ assessment tool of choice.
struct Quiz {
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
    let lockAt: Date?
    
    /// Whether or not this is locked for the user
    let lockedForUser: Bool
    
    /// An explanation of why this is locked for the user
    let lockExplanation: String?
    
    /// Whether or not the quiz is locked to certain IP addresses
    let ipFilter: String? // right now we aren't doing anything special with them. It will be a string that is comma delimited, just what the api gives us
    
    /// A url suitable for loading the quiz in a mobile webview.  it will persiste the
    /// headless session and, for quizzes in courses, will force the user to
    /// login
    let mobileURL: URL
    
    /// Whether or not the answers should be shuffled for the student
    let shuffleAnswers: Bool
    
    /// Whether or not the quiz has an access code
    let hasAccessCode: Bool

    /// Whether or not lockdown browser is required
    let requiresLockdownBrowser: Bool

    /// Whether or not lockdown browser is required in order to view the results
    let requiresLockdownBrowserForResults: Bool
    
    /**
        When is the quiz due?

        - NoDueDate: The quiz doesn't have a due date.
        - Date: The date that the quiz is due.
    */
    enum Due {
        init(date: Foundation.Date?) {
            if let d = date {
                self = .date(d)
            } else {
                self = .noDueDate
            }
        }
        
        case noDueDate
        case date(Foundation.Date)
        
        
        var description: String {
            switch self {
            case .date(let d):
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                dateFormatter.timeStyle = .medium
                return dateFormatter.string(from: d)
            case .noDueDate:
                return NSLocalizedString("No Due Date", tableName: "Localizable", bundle: .core, value: "", comment: "A quiz that has no due date")
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
                self = .noTimeLimit
            } else {
                self = .minutes(minutes)
            }
        }
        
        case noTimeLimit
        case minutes(Int)
        
        
        var description: String {
            let NoTimeLimit = NSLocalizedString("No time limit", tableName: "Localizable", bundle: .core, value: "", comment: "when a quiz has no time limit")
            
            switch self {
            case .minutes(let minutes):
                let components = DateComponents(minute: minutes)
                let dateComponentsFormatter = DateComponentsFormatter()
                dateComponentsFormatter.unitsStyle = .short
                dateComponentsFormatter.allowedUnits = [.hour, .minute]

                return dateComponentsFormatter.string(from: components) ?? ""
            case .noTimeLimit:
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
                self = .unlimited
            } else {
                self = .count(allowed)
            }
        }
        
        case unlimited
        case count(Int)
        
        var description: String {
            switch self {
            case .count(let limit):
                let formatter = NumberFormatter()
                formatter.numberStyle = .none
                return formatter.string(from: NSNumber(value: limit)) ?? ""
            case .unlimited:
                return NSLocalizedString("Unlimited", tableName: "Localizable", bundle: .core, value: "", comment: "When a quiz has no limit on the number of attempts")
            }
        }
        
        func canRetakeAfterLatestAttemptNumber(_ attempt: Int) -> Bool {
            switch self {
            case .count(let limit):
                return attempt < limit
            case .unlimited:
                return true
            }
        }
    }
    
    /**

    */
    enum HideResults {
        case always
        case untilAfterLastAttempt
        case never
    }
    
    enum Scoring: CustomStringConvertible {
        case ungraded
        case pointsPossible(Int)
        
        var description: String {
            switch self {
            case .pointsPossible(let points):
                let formatter = NumberFormatter()
                formatter.numberStyle = .none
                return formatter.string(from: NSNumber(value: points)) ?? ""
            default: return NSLocalizedString("Ungraded", tableName: "Localizable", bundle: .core, value: "", comment: "Ungraded quiz")
            }
        }
    }
}


extension Quiz.Due: JSONDecodable {
    static func fromJSON(_ json: Any?) -> Quiz.Due? {
        return Quiz.Due(date: Foundation.Date.fromJSON(json))
    }
}

extension Quiz.TimeLimit: JSONDecodable {
    static func fromJSON(_ json: Any?) -> Quiz.TimeLimit? {
        if let minutes = json as? Int {
            return Quiz.TimeLimit(minutes: minutes)
        }
        return .noTimeLimit
    }
}

extension Quiz.AttemptLimit: JSONDecodable {
    static func fromJSON(_ json: Any?) -> Quiz.AttemptLimit? {
        if let count = json as? Int {
            return Quiz.AttemptLimit(allowed: count)
        }
        
        return .unlimited
    }
}

extension Quiz.HideResults: JSONDecodable {
    static func fromJSON(_ json: Any?) -> Quiz.HideResults? {
        if let setting = json as? String {
            if setting == "always" {
                return .always
            } else if setting == "until_after_last_attempt" {
                return .untilAfterLastAttempt
            }
        }
        
        return .never
    }
}

extension Quiz.Scoring: JSONDecodable {
    static func fromJSON(_ json: Any?) -> Quiz.Scoring? {
        let points = json as? Int
        return points.map({ .pointsPossible($0) }) ?? .ungraded
    }
}

extension Quiz: JSONDecodable {
    static func fromJSON(_ json: Any?) -> Quiz? {
        if let json = json as? [String: Any] {
            let id = idString(json["id"])
            let title = json["title"] as? String
            let description = json["description"] as? String ?? ""
            let due = Quiz.Due.fromJSON(json["due_at"])
            let timeLimit = Quiz.TimeLimit.fromJSON(json["time_limit"])
            let scoring = Quiz.Scoring.fromJSON(json["points_possible"])
            let questionCount = json["question_count"] as? Int
            let questionTypes: [Question.Kind] = decodeArray(json["question_types"] as? [Any] ?? [])
            let allowedAttempts = Quiz.AttemptLimit.fromJSON(json["allowed_attempts"])
            let oqqaat = json["one_question_at_a_time"] as? Bool
            let cantGoBack = json["cant_go_back"] as? Bool
            let hideResults = Quiz.HideResults.fromJSON(json["hide_results"])
            let lockedForUser = json["locked_for_user"] as? Bool
            let lockExplanation = json["lock_explanation"] as? String
            let mobileURL = URL.fromJSON(json["mobile_url"])
            let shuffleAnswers = json["shuffle_answers"] as? Bool
            let hasAccessCode = json["has_access_code"] as? Bool ?? true
            let requiresLockdownBrowser = json["require_lockdown_browser"] as? Bool ?? false
            let requiresLockdownBrowserForResults = json["require_lockdown_browser_for_results"] as? Bool ?? false
            
            if let id = id, let title = title, let due = due, let timeLimit = timeLimit, let scoring = scoring, let questionCount = questionCount, let allowedAttempts = allowedAttempts, let oqqaat = oqqaat, let cantGoBack = cantGoBack, let hideResults=hideResults, let lockedForUser = lockedForUser, let mobileURL = mobileURL, let shuffleAnswers = shuffleAnswers
            {
                return Quiz(id: id, title: title, description: description, due: due, timeLimit: timeLimit, scoring: scoring, questionCount: questionCount, questionTypes: questionTypes, attemptLimit: allowedAttempts, oneQuestionAtATime: oqqaat, cantGoBack: cantGoBack, hideResults: hideResults, lockAt: Date.fromJSON(json["lock_at"]), lockedForUser: lockedForUser, lockExplanation: lockExplanation, ipFilter: json["ip_filter"] as? String, mobileURL: mobileURL, shuffleAnswers: shuffleAnswers, hasAccessCode: hasAccessCode, requiresLockdownBrowser: requiresLockdownBrowser, requiresLockdownBrowserForResults: requiresLockdownBrowserForResults)
            }
        }
        
        return nil
    }
}

