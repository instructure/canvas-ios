//
//  Answer.swift
//  Quizzes
//
//  Created by Derrick Hathaway on 12/30/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
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