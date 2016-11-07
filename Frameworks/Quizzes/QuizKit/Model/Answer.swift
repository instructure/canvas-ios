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

struct Answer {
    let id: String
    let content: Content
    
    enum Content {
        case Text(String)
        case HTML(String)
    }
}

// MARK: JSON

extension Answer: JSONDecodable {
    static func fromJSON(json: AnyObject?) -> Answer? {
        if let json = json as? [String: AnyObject] {
            if let
                id = idString(json["id"]),
                content = Answer.Content.fromJSON(json)
            {
                return Answer(id: id, content: content)
            }
        }
        
        return nil
    }
}

extension Answer.Content: JSONDecodable {
    static func fromJSON(json: AnyObject?) -> Answer.Content? {
        if let json = json as? [String: AnyObject] {
            if let html = json["html"] as? String {
                if html != "" {
                    return .HTML(html)
                }
            }
            
            if let text = json["text"] as? String {
                return .Text(text)
            }
        }
        
        return nil
    }
}