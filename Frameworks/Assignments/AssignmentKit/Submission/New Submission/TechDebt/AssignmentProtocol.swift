//
//  AssignmentProtocol.swift
//  Assignments
//
//  Created by Nathan Armstrong on 1/23/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

public protocol AssignmentProtocol {
    var id: String { get }
    var courseID: String { get }
    var submissionTypes: SubmissionTypes { get }
    var allowedExtensions: [String]? { get }
    var groupSetID: String? { get }
}

extension Assignment: AssignmentProtocol {}
