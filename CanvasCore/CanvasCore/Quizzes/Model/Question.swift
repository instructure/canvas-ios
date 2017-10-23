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

