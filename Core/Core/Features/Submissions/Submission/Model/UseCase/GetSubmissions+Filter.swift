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

        public let statuses: Set<Status>
        public let score: Set<Score>
        public let sections: Set<Section>
        public let differentiationTags: Set<DifferentiationTag>

        public init(
            statuses: Set<Status>,
            score: Set<Score> = [],
            sections: Set<String> = [],
            differentiationTags: Set<String> = []
        ) {
            self.statuses = statuses
            self.score = score
            self.sections = Set(sections.map(Section.init))
            self.differentiationTags = Set(differentiationTags.map(DifferentiationTag.init))
        }

        var predicate: NSPredicate? {
            [
                statuses.predicate,
                score.predicate,
                sections.predicate,
                differentiationTags.predicate
            ]
                .compactMap({ $0 })
                .andRelated
        }

        public var query: [URLQueryItem] {
            let checkables = [statuses.query, sections.query, differentiationTags.query].compactMap({ $0 })
            return checkables + score.query
        }

        public var nilIfEmpty: Self? {
            if statuses.isEmpty,
               score.isEmpty,
               sections.isEmpty,
               differentiationTags.isEmpty {
                return nil
            }
            return self
        }
    }
}

extension GetSubmissions.Filter: ExpressibleByArrayLiteral {

    public init(arrayLiteral elements: Status...) {
        self.init(statuses: Set(elements))
    }

    public static func status(_ statuses: Status...) -> Self {
        .init(statuses: Set(statuses))
    }

    public static func scoreMoreThan(_ score: Double) -> Self {
        .init(statuses: [], score: [Score(operation: .moreThan, score: score)])
    }

    public static func scoreLessThan(_ score: Double) -> Self {
        .init(statuses: [], score: [Score(operation: .lessThan, score: score)])
    }

    public static func section(_ sections: String...) -> Self {
        .init(statuses: [], sections: Set(sections))
    }

    public init(urlComponents url: URLComponents) {
        let statuses: Set<GetSubmissions.Filter.Status> = Set(
            url
                .queryValue(for: "statuses")
                .flatMap({ $0.removingPercentEncoding })?
                .components(separatedBy: ",")
                .compactMap {
                    GetSubmissions.Filter.Status(rawValue: $0)
                } ?? []
        )

        let sections: Set<String> = Set(
            url
                .queryValue(for: "sections")
                .flatMap({ $0.removingPercentEncoding })?
                .components(separatedBy: ",") ?? []
        )

        let scores: Set<GetSubmissions.Filter.Score> = Set(
            [
                url
                    .queryValue(for: "scoredMore")
                    .flatMap({ $0.removingPercentEncoding })
                    .flatMap(Double.init)
                    .flatMap({ GetSubmissions.Filter.Score(operation: .moreThan, score: $0) }),

                url.queryValue(for: "scoredLess")
                    .flatMap({ $0.removingPercentEncoding })
                    .flatMap(Double.init)
                    .flatMap({ GetSubmissions.Filter.Score(operation: .lessThan, score: $0) })
            ]
                .compactMap({ $0 })
        )

        let differentiationTags: Set<String> = Set(
            url
                .queryValue(for: "differentiationTags")
                .flatMap({ $0.removingPercentEncoding })?
                .components(separatedBy: ",") ?? []
        )

        self.init(statuses: statuses, score: scores, sections: sections, differentiationTags: differentiationTags)
    }
}

extension GetSubmissions.Filter {

    public enum Status: RawRepresentable, Hashable {

        public static var basicCases: [Status] {
            return [.notSubmitted, .submitted, .graded, .late, .missing]
        }

        public static func allCasesForCourse(_ courseID: String) -> [Status] {
            return basicCases + CDCustomGradeStatus.allForCourse(courseID).map { .custom($0.name) }
        }

        case notSubmitted
        case submitted
        case graded
        case late
        case missing
        case custom(String)

        public init?(rawValue: String) {

            if let mode = Self.basicCases.first(where: { $0.rawValue == rawValue }) {
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

        var predicate: NSPredicate {
            let notExcused = NSPredicate(format: "%K != true", #keyPath(Submission.excused))
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
                    #keyPath(Submission.excused),
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

    var predicate: NSPredicate? { sorted(by: \.rawValue).map(\.predicate).orRelated }

    public var isBasicCasesIncluded: Bool {
        return Element.basicCases.allSatisfy { contains($0) }
    }

    public func isAllCasesForCourseIncluded(_ courseID: String) -> Bool {
        guard isBasicCasesIncluded else { return false }
        return CDCustomGradeStatus
            .allForCourse(courseID)
            .map(\.name)
            .allSatisfy({ contains(.custom($0)) })
    }

    public var query: URLQueryItem? {
        return map(\.rawValue)
            .joined(separator: ",")
            .nilIfEmpty
            .flatMap({ $0.urlQuerySafePercentEncoded })
            .flatMap({ URLQueryItem(name: "statuses", value: $0) })
    }
}

extension Set where Element == GetSubmissions.Filter.Status {
    public static func allCasesForCourse(_ courseID: String) -> Self {
        Set(GetSubmissions.Filter.Status.allCasesForCourse(courseID))
    }
}

// MARK: - Score

extension GetSubmissions.Filter {

    public struct Score: Hashable {
        public enum Operation: Int {
            case moreThan
            case lessThan
        }

        public let operation: Operation
        public let score: Double

        public init(operation: Operation, score: Double) {
            self.operation = operation
            self.score = score
        }

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

        var queryItem: URLQueryItem? {
            guard let scoreValue = String(score).urlQuerySafePercentEncoded else { return nil }

            return switch operation {
            case .moreThan:
                URLQueryItem(name: "scoredMore", value: scoreValue)
            case .lessThan:
                URLQueryItem(name: "scoredLess", value: scoreValue)
            }
        }
    }
}

extension Collection where Element == GetSubmissions.Filter.Score {
    var predicate: NSPredicate? { sorted(by: \.operation.rawValue).map(\.predicate).andRelated }

    public var moreThanFilter: GetSubmissions.Filter.Score? {
        first(where: { $0.operation == .moreThan })
    }

    public var lessThanFilter: GetSubmissions.Filter.Score? {
        first(where: { $0.operation == .lessThan })
    }

    public var query: [URLQueryItem] {
        return compactMap { $0.queryItem }
    }
}

// MARK: - Sections

extension GetSubmissions.Filter {
    public struct Section: Hashable {
        public let sectionID: String
    }
}

extension Collection where Element == GetSubmissions.Filter.Section {
    var predicate: NSPredicate? {
        if isEmpty { return nil }
        return NSPredicate(
            format: "ANY %K IN %@",
            #keyPath(Submission.enrollments.courseSectionID),
            sorted(by: \.sectionID).map(\.sectionID)
        )
    }

    public var query: URLQueryItem? {
        map(\.sectionID)
            .joined(separator: ",")
            .nilIfEmpty
            .flatMap({ $0.urlQuerySafePercentEncoded })
            .flatMap({ URLQueryItem(name: "sections", value: $0) })
    }
}

// MARK: - Differentiation Tags

extension GetSubmissions.Filter {
    public struct DifferentiationTag: Hashable {
        public static let UsersWithoutTagsID = "_UsersWithoutTagsID"
        public let tagID: String
    }
}

extension Collection where Element == GetSubmissions.Filter.DifferentiationTag {
    var predicate: NSPredicate? {
        if isEmpty { return nil }

        // Check if we have the special "users without tags" filter
        let usersWithoutTagsFilter = first { $0.tagID == Element.UsersWithoutTagsID }
        let regularTagFilters = filter { $0.tagID != Element.UsersWithoutTagsID }

        var predicates: [NSPredicate] = []

        // Handle regular differentiation tag filters
        if regularTagFilters.isNotEmpty {
            let regularTagsPredicate = NSPredicate(
                format: "ANY %K.%K IN %@",
                #keyPath(Submission.user.userGroups),
                #keyPath(CDUserGroup.id),
                regularTagFilters.map(\.tagID)
            )
            predicates.append(regularTagsPredicate)
        }

        // Handle "users without tags" filter
        if usersWithoutTagsFilter != nil {
            let usersWithoutTagsPredicate = NSPredicate(
                format: "NOT (ANY %K.%K == YES)",
                #keyPath(Submission.user.userGroups),
                #keyPath(CDUserGroup.isDifferentiationTag)
            )
            predicates.append(usersWithoutTagsPredicate)
        }

        // Combine predicates with OR (union of results)
        return predicates.count == 1 ? predicates.first : NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
    }

    public var query: URLQueryItem? {
        return map(\.tagID)
            .joined(separator: ",")
            .nilIfEmpty
            .flatMap({ $0.urlQuerySafePercentEncoded })
            .flatMap({ URLQueryItem(name: "differentiationTags", value: $0) })
    }
}

// MARK: - Utils

private extension CDCustomGradeStatus {

    static func allForCourse(_ courseID: String) -> [CDCustomGradeStatus] {
        return AppEnvironment
            .shared
            .database
            .viewContext
            .fetch(
                NSPredicate(key: #keyPath(CDCustomGradeStatus.courseID), equals: courseID),
                sortDescriptors: [
                    NSSortDescriptor(key: #keyPath(CDCustomGradeStatus.name), naturally: true)
                ]
            )
    }
}

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
