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
    
    

import Foundation



enum SubmissionAnswer: Equatable {
    case na
    case unanswered
    case Matches([String: String]) // answerID: matchID
    case id(String)
    case ids([String])
    case text(String)
    case idsHash([String: String])
    
    
    var answerText: String? {
        switch self {
        case .text(let answerText):
            return answerText
        default:
            return nil
        }
    }
    
    var answerID: String? {
        switch self {
        case .id(let answerID):
            return answerID
        default:
            return nil
        }
    }
    
    var answerIDs: [String]? {
        switch self {
        case .ids(let answerIDs):
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
    
    func toggleAnswerID(_ id: String) -> SubmissionAnswer {
        switch self {
        case .ids(let answerIDs):
            if answerIDs.contains(id) {
                // deselect
                var newAnswerIDs = answerIDs
                if let index = newAnswerIDs.index(of: id) {
                    newAnswerIDs.remove(at: index)
                }
                return .ids(newAnswerIDs)
            } else {
                // select
                return .ids(answerIDs+[id])
            }
        default:
            return self
        }
    }
    
    func setMatch(_ answerID: String, matchID: String?) -> SubmissionAnswer {
        switch self {
        case .Matches(let matches):
            var newMatches = matches
            newMatches[answerID] = matchID
            return .Matches(newMatches)
        case .unanswered:
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
        
    case (.na, .na), (.unanswered, .unanswered):
        return true
        
    case let (.id(leftID), .id(rightID)):
        return leftID == rightID
        
    case let (.ids(leftIDs), .ids(rightIDs)):
        return leftIDs == rightIDs
        
    case let (.text(leftText), .text(rightText)):
        return leftText == rightText
        
    case let (.Matches(leftMatches), .Matches(rightMatches)):
        return leftMatches == rightMatches

    case let(.idsHash(leftHash), .idsHash(rightHash)):
        return leftHash == rightHash
        
    default:
        return false
    }
}


// MARK: JSON

// TODO: JSONEncodable type?
extension SubmissionAnswer {
    var apiAnswer: Any {
        switch self {
        case .text(let answer):
            return answer
        case .id(let id):
            return id.toNSNumberWrappingInt64()
        case .ids(let ids):
            return ids.map { $0.toNSNumberWrappingInt64() }
        case .Matches(let matches):
            var arr: [Any] = []
            for key in matches.keys {
                let dict = [ "answer_id": key.toNSNumberWrappingInt64(), "match_id": matches[key]!.toNSNumberWrappingInt64() ]
                arr.append(dict)
            }
            return arr
        case .idsHash(let hash):
            var newHash: [String: NSNumber] = [:]
            for key in hash.keys {
                if let value = hash[key] {
                    newHash[key] = value.toNSNumberWrappingInt64()
                }
            }
            return newHash
        default:
            return ""
        }
    }
}

