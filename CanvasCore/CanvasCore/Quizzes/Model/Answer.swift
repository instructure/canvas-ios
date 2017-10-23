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


struct Answer {
    let id: String
    let content: Content
    let blankID: String?
    
    enum Content {
        case text(String)
        case html(String)
    }
}

// MARK: JSON

extension Answer: JSONDecodable {
    static func fromJSON(_ json: Any?) -> Answer? {
        if let json = json as? [String: Any] {
            if let
                id = idString(json["id"]),
                let content = Answer.Content.fromJSON(json)
            {
                let blankID = idString(json["blank_id"])
                return Answer(id: id, content: content, blankID: blankID)
            }
        }
        
        return nil
    }
}

extension Answer.Content: JSONDecodable {
    static func fromJSON(_ json: Any?) -> Answer.Content? {
        if let json = json as? [String: Any] {
            if let html = json["html"] as? String {
                if html != "" {
                    return .html(html)
                }
            }
            
            if let text = json["text"] as? String {
                return .text(text)
            }
        }
        
        return nil
    }
}
