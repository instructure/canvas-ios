//
//  QuizQuestion.swift
//  Quizzes
//
//  Created by Derrick Hathaway on 12/30/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

import UIKit
import SoLazy

struct Question {
    init(id: String, position: Int, name: String, text: String, kind: Kind, answers: [Answer], matches: [Match]? = nil) {
        self.id = id
        self.position = position
        self.name = name
        self.text = text
        self.kind = kind
        self.answers = answers
        self.matches = matches
    }
    
    let id: String
    let position: Int
    let name: String
    let text: String
    let kind: Kind
    let answers: [Answer]
    let matches: [Match]?

    enum Kind: String {
        case TrueFalse = "true_false_question" // supported
        case MultipleChoice = "multiple_choice_question" // supported
        case ShortAnswer = "short_answer_question" // supported, the web ui calls this "Fill in the blank"
        case FillInMultipleBlanks = "fill_in_multiple_blanks_question"
        case MultipleAnswers = "multiple_answers_question" // supported
        case MultipleDropdowns = "multiple_dropdowns_question"
        case Matching = "matching_question" // supported
        case Numerical = "numerical_question" // supported
        case Calculated = "calculated_question"
        case Essay = "essay_question" // supported
        case FileUpload = "file_upload_question"
        case TextOnly = "text_only_question" // supported
    }
    
    struct Match {
        let id: String
        let text: String
        
        init(id: String, text: String) {
            self.id = id
            self.text = text
        }
    }
}

func ==(lhs: Question.Kind, rhs: Question.Kind) -> Bool {
    switch (lhs, rhs) {
    case
    (.TrueFalse, .TrueFalse),
    (.MultipleChoice, .MultipleChoice),
    (.ShortAnswer, .ShortAnswer),
    (.FillInMultipleBlanks, .FillInMultipleBlanks),
    (.MultipleAnswers, .MultipleAnswers),
    (.MultipleDropdowns, .MultipleDropdowns),
    (.Matching, .Matching),
    (.Numerical, .Numerical),
    (.Calculated, .Calculated),
    (.Essay, .Essay),
    (.FileUpload, .FileUpload),
    (.TextOnly, .TextOnly):
        return true
        
    default:
        return false
    }
}


// MARK: JSON

extension Question: JSONDecodable {
    static func fromJSON(json: AnyObject?) -> Question? {
        if let json = json as? [String: AnyObject] {

            let answers: [Answer] = decodeArray(json["answers"] as? [AnyObject] ?? [])
            
            if let
                id = idString(json["id"]),
                position = json["position"] as? Int,
                name = json["question_name"] as? String,
                text = json["question_text"] as? String,
                questionType = json["question_type"] as? String,
                kind = Question.Kind(rawValue: questionType)
            {
                var matches: [Match]? = nil
                if let matchesJSON = json["matches"] as? [AnyObject] {
                    matches = decodeArray(matchesJSON)
                    matches = matches?.shuffle()
                }
                return Question(id: id, position: position, name: name, text: text, kind: kind, answers: answers, matches: matches)
            }
        }
        
        return nil
    }
}

extension Question.Kind: JSONDecodable {
    static func fromJSON(json: AnyObject?) -> Question.Kind? {
        if let string = json as? String {
            return Question.Kind(rawValue: string)
        }
        
        return nil
    }
}

extension Question.Match: JSONDecodable {
    static func fromJSON(json: AnyObject?) -> Question.Match? {
        if let json = json as? [String: AnyObject] {
            
            if let
                id = idString(json["match_id"]),
                text = json["text"] as? String
            {
                return Question.Match(id: id, text: text)
            }
        }
        
        return nil
    }
}

