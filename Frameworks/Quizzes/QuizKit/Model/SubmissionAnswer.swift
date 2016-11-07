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
import SoLazy


enum SubmissionAnswer: Equatable {
    case NA
    case Unanswered
    case Matches([String: String]) // answerID: matchID
    case ID(String)
    case IDs([String])
    case Text(String)
    
    
    var answerText: String? {
        switch self {
        case .Text(let answerText):
            return answerText
        default:
            return nil
        }
    }
    
    var answerID: String? {
        switch self {
        case .ID(let answerID):
            return answerID
        default:
            return nil
        }
    }
    
    var answerIDs: [String]? {
        switch self {
        case .IDs(let answerIDs):
            return answerIDs
        default:
            return nil
        }
    }
    
    var matches: [String: String]? {
        switch self {
        case .Matches(let matches):
            return matches
        default:
            return nil
        }
    }
    
    func toggleAnswerID(id: String) -> SubmissionAnswer {
        switch self {
        case .IDs(let answerIDs):
            if answerIDs.contains(id) {
                // deselect
                var newAnswerIDs = answerIDs
                if let index = newAnswerIDs.indexOf(id) {
                    newAnswerIDs.removeAtIndex(index)
                }
                return .IDs(newAnswerIDs)
            } else {
                // select
                return .IDs(answerIDs+[id])
            }
        default:
            return self
        }
    }
    
    func setMatch(answerID: String, matchID: String?) -> SubmissionAnswer {
        switch self {
        case .Matches(let matches):
            var newMatches = matches
            newMatches[answerID] = matchID
            return .Matches(newMatches)
        case .Unanswered:
            if let matchID = matchID {
                return .Matches([answerID: matchID])
            } else {
                return self
            }
        default:
            return self
        }
    }
}

func ==(lhs: SubmissionAnswer, rhs: SubmissionAnswer) -> Bool {
    switch (lhs, rhs) {
        
    case (.NA, .NA), (.Unanswered, .Unanswered):
        return true
        
    case let (.ID(leftID), .ID(rightID)):
        return leftID == rightID
        
    case let (.IDs(leftIDs), .IDs(rightIDs)):
        return leftIDs == rightIDs
        
    case let (.Text(leftText), .Text(rightText)):
        return leftText == rightText
        
    case let (.Matches(leftMatches), .Matches(rightMatches)):
        return leftMatches == rightMatches
        
    default:
        return false
    }
}


// MARK: JSON

// TODO: JSONEncodable type?
extension SubmissionAnswer {
    var apiAnswer: AnyObject {
        switch self {
        case .Text(let answer):
            return answer
        case .ID(let id):
            return id.toNSNumberWrappingInt64()
        case .IDs(let ids):
            return ids.map { $0.toNSNumberWrappingInt64() }
        case .Matches(let matches):
            var arr: [AnyObject] = []
            for key in matches.keys {
                let dict = [ "answer_id": key.toNSNumberWrappingInt64(), "match_id": matches[key]!.toNSNumberWrappingInt64() ]
                arr.append(dict)
            }
            return arr
        default:
            return ""
        }
    }
}

