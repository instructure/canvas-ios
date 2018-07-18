//
// Copyright (C) 2016-present Instructure, Inc.
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
    
    

import UIKit


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
        case MultipleDropdowns = "multiple_dropdowns_question" // supported
        case Matching = "matching_question" // supported
        case Numerical = "numerical_question" // supported
        case Calculated = "calculated_question"
        case Essay = "essay_question" // supported
        case FileUpload = "file_upload_question" // supported
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
    static func fromJSON(_ json: Any?) -> Question? {
        if let json = json as? [String: Any] {
            let answers: [Answer] = decodeArray(json["answers"] as? [Any] ?? [])
            
            if let
                id = idString(json["id"]),
                let position = json["position"] as? Int,
                let name = json["question_name"] as? String,
                let text = json["question_text"] as? String,
                let questionType = json["question_type"] as? String,
                let kind = Question.Kind(rawValue: questionType)
            {
                var matches: [Match]? = nil
                if let matchesJSON = json["matches"] as? [Any] {
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
    static func fromJSON(_ json: Any?) -> Question.Kind? {
        if let string = json as? String {
            return Question.Kind(rawValue: string)
        }
        
        return nil
    }
}

extension Question.Match: JSONDecodable {
    static func fromJSON(_ json: Any?) -> Question.Match? {
        if let json = json as? [String: Any] {
            
            if let
                id = idString(json["match_id"]),
                let text = json["text"] as? String
            {
                return Question.Match(id: id, text: text)
            }
        }
        
        return nil
    }
}

