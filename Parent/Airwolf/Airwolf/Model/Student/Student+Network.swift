//
//  Student+Network.swift
//  Airwolf
//
//  Created by Ben Kraus on 5/18/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import TooLegit
import ReactiveCocoa
import Marshal

extension Student {
    public static func addStudent(session: Session, parentID: String, domain: NSURL) throws -> SignalProducer<(), NSError> {
        let request = try AirwolfAPI.addStudentRequest(session, parentID: parentID, studentDomain: domain)
        return session.emptyResponseSignalProducer(request)
    }

    public static func checkDomain(session: Session, parentID: String, domain: NSURL) throws -> SignalProducer<(), NSError> {
        let request = try AirwolfAPI.checkDomainRequest(session, parentID: parentID, studentDomain: domain)
        return session.emptyResponseSignalProducer(request)
    }

    public static func getStudents(session: Session, parentID: String) throws -> SignalProducer<[JSONObject], NSError> {
        let request = try AirwolfAPI.getStudentsRequest(session, parentID: parentID)
        return session.paginatedJSONSignalProducer(request)
    }

    public static func deleteStudent(session: Session, parentID: String, studentID: String) throws -> SignalProducer<(), NSError> {
        let request = try AirwolfAPI.deleteStudentRequest(session, parentID: parentID, studentID: studentID)
        return session.emptyResponseSignalProducer(request)
    }
}