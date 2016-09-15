//
//  TodoAPI.swift
//  Todo
//
//  Created by Brandon Pluim on 4/18/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import TooLegit
import SoLazy

public class TodoAPI {
    public class func getTodos(session: Session) throws -> NSURLRequest {
        let path = "/api/v1/users/self/todo"
        return try session.GET(path)
    }

    public class func ignoreTodo(session: Session, todo: Todo) throws -> NSURLRequest {
        let request = NSMutableURLRequest(URL: NSURL(string: todo.ignoreURL)!)
        request.HTTPMethod = "DELETE"
        if let token = session.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
}