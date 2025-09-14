//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

import Foundation
import CoreData

// MARK: - Status

extension GetSubmissions {

    public struct Filter {

        public let statuses: [Status]
        public let score: [Score]
        let sections: [Section]
        let differentiationTags: [DifferentiationTag]
        let users: [User]

        public init(
            statuses: [Status],
            score: [Score] = [],
            sections: [String] = [],
            differentiationTags: [String] = [],
            users: [String] = []
        ) {
            self.statuses = statuses
            self.score = score
            self.sections = sections.map(Section.init)
            self.differentiationTags = differentiationTags.map(DifferentiationTag.init)
            self.users = users.map(User.init)
        }

        var predicate: NSPredicate? {
            [
                statuses.predicate,
                score.predicate,
                sections.predicate,
                differentiationTags.predicate,
                users.predicate
            ]
                .compactMap({ $0 })
                .andRelated
        }
    }
}

extension GetSubmissions.Filter: ExpressibleByArrayLiteral {

    public init(arrayLiteral elements: Status...) {
        self.init(statuses: elements)
    }

    public static func status(_ statuses: Status...) -> Self {
        .init(statuses: statuses)
    }

    public static func scoreMoreThan(_ score: Double) -> Self {
        .init(statuses: [], score: [Score(operation: .moreThan, score: score)])
    }

    public static func scoreLessThan(_ score: Double) -> Self {
        .init(statuses: [], score: [Score(operation: .lessThan, score: score)])
    }

    public static func section(_ sections: String...) -> Self {
        .init(statuses: [], sections: sections)
    }

    public static func user(_ users: String...) -> Self {
        .init(statuses: [], users: users)
    }
}

extension GetSubmissions.Filter {

    public enum Status: RawRepresentable, Equatable {

        public static var sharedCases: [Status] {
            return [.notSubmitted, .submitted, .graded, .late, .missing]
        }

        public static func courseAllCases(_ courseID: String) -> [Status] {
            let viewContext = AppEnvironment.shared.database.viewContext
            let customStatuses: [CDCustomGradeStatus] = viewContext
                .fetch(NSPredicate(key: #keyPath(CDCustomGradeStatus.courseID), equals: courseID))
            return sharedCases + customStatuses.map { .custom($0.name) }
        }

        case notSubmitted
        case submitted
        case graded
        case late
        case missing
        case custom(String)

        public init?(rawValue: String) {

            if let mode = Self.sharedCases.first(where: { $0.rawValue == rawValue }) {
                self = mode
                return
            }

            if rawValue.hasPrefix("custom:") {
                self = .custom(String(rawValue.split(separator: ":")[1]))
                return
            }

            return nil
        }

        public var name: String {
            switch self {
            case .notSubmitted:
                String(localized: "Not Submitted", bundle: .core)
            case .submitted:
                String(localized: "Submitted", bundle: .core)
            case .graded:
                String(localized: "Graded", bundle: .core)
            case .late:
                String(localized: "Late", bundle: .core)
            case .missing:
                String(localized: "Missing", bundle: .core)
            case .custom(let name):
                name
            }
        }

        public var rawValue: String {
            switch self {
            case .notSubmitted:
                "not_submitted"
            case .submitted:
                "submitted"
            case .graded:
                "graded"
            case .late:
                "late"
            case .missing:
                "missing"
            case .custom(let name):
                "custom:\(name)"
            }
        }

        public var queryValue: String {
            rawValue
        }

        var predicate: NSPredicate {
            let notExcused = NSPredicate(format: "%K == nil OR %K != true", #keyPath(Submission.excusedRaw), #keyPath(Submission.excusedRaw))
            let notCustomGradeStated = NSPredicate(
                format: "%K == nil", #keyPath(Submission.customGradeStatusId)
            )

            switch self {
            case .notSubmitted:
                return NSCompoundPredicate(type: .or, subpredicates: [
                    NSCompoundPredicate(type: .and, subpredicates: [
                        NSPredicate(key: #keyPath(Submission.workflowStateRaw), equals: SubmissionWorkflowState.unsubmitted.rawValue),
                        notExcused,
                        notCustomGradeStated
                    ]),
                    NSCompoundPredicate(type: .and, subpredicates: [
                        NSPredicate(key: #keyPath(Submission.workflowStateRaw), equals: SubmissionWorkflowState.graded.rawValue),
                        NSPredicate(key: #keyPath(Submission.submittedAt), equals: nil),
                        NSPredicate(key: #keyPath(Submission.scoreRaw), equals: nil)
                    ])
                ])
            case .submitted:
                let hasValidSubmissionType = NSPredicate(format: "%K != nil", #keyPath(Submission.typeRaw))
                let isPendingReview = NSPredicate(format: "%K == 'pending_review'", #keyPath(Submission.workflowStateRaw))
                let isGradedOrSubmitted = NSPredicate(format: "%K IN { 'graded', 'submitted' }", #keyPath(Submission.workflowStateRaw))
                let hasNoScore = NSPredicate(format: "%K == nil", #keyPath(Submission.scoreRaw))
                let isLatestAttemptNotGraded = NSPredicate(format: "%K == false", #keyPath(Submission.gradeMatchesCurrentSubmission))
                let isGradeOutDated = isGradedOrSubmitted.and(hasNoScore.or(isLatestAttemptNotGraded))

                return notExcused
                    .and(notCustomGradeStated)
                    .and(hasValidSubmissionType)
                    .and(isPendingReview.or(isGradeOutDated))

            case .graded:
                return NSPredicate(format: "%K == true OR %K != nil OR (%K != nil AND %K == 'graded')",
                    #keyPath(Submission.excusedRaw),
                    #keyPath(Submission.customGradeStatusId),
                    #keyPath(Submission.scoreRaw),
                    #keyPath(Submission.workflowStateRaw)
                )
            case .late:
                return NSPredicate(key: #keyPath(Submission.late), equals: true)
            case .missing:
                return NSPredicate(key: #keyPath(Submission.missing), equals: true)
            case .custom(let name):
                return NSCompoundPredicate(type: .and, subpredicates: [
                    NSPredicate(format: "%K != nil", #keyPath(Submission.customGradeStatusId)),
                    NSPredicate(key: #keyPath(Submission.customGradeStatusName), equals: name)
                ])
            }
        }
    }
}

extension Collection where Element == GetSubmissions.Filter.Status {

    var predicate: NSPredicate? { map(\.predicate).orRelated }

    public var isSharedCasesIncluded: Bool {
        return Element.sharedCases.allSatisfy { contains($0) }
    }

    public func isCourseAllCasesIncluded(_ courseID: String) -> Bool {
        guard isSharedCasesIncluded else { return false }
        let viewContext = AppEnvironment.shared.database.viewContext
        let statuses: [CDCustomGradeStatus] = viewContext
            .fetch(NSPredicate(key: #keyPath(CDCustomGradeStatus.courseID), equals: courseID))
        return statuses.map(\.name).allSatisfy({ contains(.custom($0)) })
    }

    public var query: String {
        let value = map(\.rawValue).joined(separator: ",").nilIfEmpty ?? ""
        return value.isEmpty ? "" : "filter=\(value)"
    }
}

// MARK: - Score

extension GetSubmissions.Filter {

    public struct Score: Equatable {
        public enum Operation {
            case moreThan
            case lessThan
        }

        public let operation: Operation
        public let score: Double

        var predicate: NSPredicate {
            switch operation {
            case .moreThan:
                NSPredicate(format: "%K > %@", #keyPath(Submission.scoreRaw), NSNumber(value: score))
            case .lessThan:
                NSPredicate(format: "%K < %@", #keyPath(Submission.scoreRaw), NSNumber(value: score))
            }
        }

        public var name: String {
            switch operation {
            case .moreThan:
                String.localizedStringWithFormat(String(localized: "Scored More than %g", bundle: .core), score)
            case .lessThan:
                String.localizedStringWithFormat(String(localized: "Scored Less than %g", bundle: .core), score)
            }
        }

        public static func moreThan(_ score: Double) -> Self {
            Score(operation: .moreThan, score: score)
        }

        public static func lessThan(_ score: Double) -> Self {
            Score(operation: .lessThan, score: score)
        }
    }
}

extension Collection where Element == GetSubmissions.Filter.Score {
    var predicate: NSPredicate? { map(\.predicate).andRelated }
}

// MARK: - Users

extension GetSubmissions.Filter {
    struct User {
        let userID: String
    }
}

extension Collection where Element == GetSubmissions.Filter.User {
    var predicate: NSPredicate? {
        inPredicate(
            key: #keyPath(Submission.userID),
            propertyKeyPath: \.userID
        )
    }
}

// MARK: - Sections

extension GetSubmissions.Filter {
    struct Section {
        let sectionID: String
    }
}

extension Collection where Element == GetSubmissions.Filter.Section {
    var predicate: NSPredicate? {
        inPredicate(
            key: #keyPath(Submission.enrollments.courseSectionID),
            propertyKeyPath: \.sectionID
        )
    }
}

// MARK: - Differentiation Tags

extension GetSubmissions.Filter {
    struct DifferentiationTag {
        let tagID: String
    }
}

extension Collection where Element == GetSubmissions.Filter.DifferentiationTag {
    var predicate: NSPredicate? {
        // TODO: - OR predicates for differentiation tags selection
        nil
    }
}

// MARK: - Utils

private extension Array where Element == NSPredicate {

    var andRelated: NSPredicate? {
        if count <= 1 { return first }
        return NSCompoundPredicate(type: .and, subpredicates: self)
    }

    var orRelated: NSPredicate? {
        if count <= 1 { return first }
        return NSCompoundPredicate(type: .or, subpredicates: self)
    }
}

private extension Collection {

    func inPredicate<Value: CVarArg>(key: String, propertyKeyPath: KeyPath<Element, Value>) -> NSPredicate? {
        if isEmpty { return nil }
        if count == 1, let element = first {
            return NSPredicate(key: key, equals: element[keyPath: propertyKeyPath])
        }
        return NSPredicate(format: "ANY %K IN %@", key, map { $0[keyPath: propertyKeyPath] })
    }
}
