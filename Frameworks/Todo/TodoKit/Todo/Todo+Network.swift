//
//  Todo+Network.swift
//  Todo
//
//  Created by Brandon Pluim on 4/18/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Marshal
import ReactiveCocoa
import TooLegit

extension Todo {
    static func getTodos(session: Session) throws -> SignalProducer<[JSONObject], NSError> {
        let request = try TodoAPI.getTodos(session)
        return session.paginatedJSONSignalProducer(request)
    }

    func ignore(session: Session) throws -> SignalProducer<JSONObject, NSError> {
        let request = try TodoAPI.ignoreTodo(session, todo: self)
        return session.JSONSignalProducer(request)
    }
}