//
//  Result.swift
//  GradesWidget
//
//  Created by Nathan Armstrong on 1/9/18.
//  Copyright © 2018 Instructure. All rights reserved.
//

import Foundation

enum NetworkError: Error {
    case invalidRequest
    case invalidResponse
}

enum Result<Value> {
    case completed(Value)
    case failed(Error)
}
