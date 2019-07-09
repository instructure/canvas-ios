//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
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
