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
    
    

import Foundation


struct SubmissionQuestion {
    init(question: Question, flagged: Bool, answer: SubmissionAnswer) {
        self.question = question
        self.flagged = flagged
        self.answer = answer
    }
    
    let question: Question
    let flagged: Bool
    let answer: SubmissionAnswer
    
    
    func selectAnswer(_ answer: SubmissionAnswer) -> SubmissionQuestion {
        return SubmissionQuestion(question: question, flagged: flagged, answer: answer)
    }
    
    func toggleFlag() -> SubmissionQuestion {
        return SubmissionQuestion(question: question, flagged: !flagged, answer: answer)
    }
    
    func shuffleAnswers() -> SubmissionQuestion {
        let newQuestion = Question(id: question.id, position: question.position, name: question.name, text: question.text, kind: question.kind, answers: question.answers.shuffle(), matches: question.matches)
        return SubmissionQuestion(question: newQuestion, flagged: flagged, answer: answer)
    }
}

// MARK: JSON

extension SubmissionQuestion: JSONDecodable {
    static func fromJSON(_ json: Any?) -> SubmissionQuestion? {
        if let json = json as? [String: Any] {
            let flagged = json["flagged"] as? Bool ?? false
            
            if let question = Question.fromJSON(json), let answerJSON: Any = json["answer"] {
                var answer: SubmissionAnswer = .unanswered
                switch question.kind {
                    case .TextOnly:
                        answer = .na
                    case .TrueFalse, .MultipleChoice, .FileUpload:
                        if let id = idString(answerJSON) {
                            answer = .id(id)
                        }
                    case .MultipleAnswers:
                        if let ids = answerJSON as? [Any] {
                            let newIDs: [String] = decodeArray(ids)
                            answer = .ids(newIDs)
                    }
                    case .Essay, .ShortAnswer:
                        if let text = answerJSON as? String {
                            answer = .text(text)
                        }
                    case .Numerical:
                        if let numberStr = answerJSON as? String {
                            answer = .text(numberStr)
                        } else if let number = answerJSON as? Double {
                            answer = .text(String(format: "%f", number))
                        }
                    case .Matching:
                        if let answers = answerJSON as? [Any] {
                            var answerMatchMap: [String: String] = [:]
                            for obj in answers {
                                if let dict = obj as? [String:Any] {
                                    if let answerID = idString(dict["answer_id"]), let matchID = idString(dict["match_id"]) {
                                        answerMatchMap[answerID] = matchID
                                    }
                                }
                            }
                            if answerMatchMap.keys.count > 0 {
                                answer = .Matches(answerMatchMap)
                            }
                        }
                    case .MultipleDropdowns:
                        if let answers = answerJSON as? [String: Any] {
                            var answerMap: [String: String] = [:]
                            for obj in answers {
                                if idString(obj.value) != nil {
                                    answerMap[obj.key] = idString(obj.value)
                                }
                            }
                            if answerMap.keys.count > 0 {
                                answer = .idsHash(answerMap)
                            }
                        }
                    default:
                        answer = .unanswered
                }
                
                return SubmissionQuestion(question: question, flagged: flagged, answer: answer)
            }
        }
        
        return nil
    }
}

