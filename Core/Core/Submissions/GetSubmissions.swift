//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

public struct GetRecentlyGradedSubmissions: CollectionUseCase {
    public typealias Model = SubmissionList

    public let cacheKey: String? = "recently-graded-submissions"
    public let request: GetRecentlyGradedSubmissionsRequest
    public let scope: Scope

    public init (userID: String) {
        request = GetRecentlyGradedSubmissionsRequest(userID: userID)
        scope = Scope.where(#keyPath(SubmissionList.id), equals: "recently-graded")
    }

    public func write(response: [APISubmission]?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        let list: SubmissionList = client.fetch(scope: scope).first ?? client.insert()
        list.id = "recently-graded"
        list.submissions.append(contentsOf: Submission.save(response ?? [], in: client))
    }
}

public class CreateSubmission: APIUseCase {
    let context: Context
    let assignmentID: String
    let userID: String
    public let request: CreateSubmissionRequest
    public typealias Model = Submission

    public init(
        context: Context,
        assignmentID: String,
        userID: String,
        submissionType: SubmissionType,
        textComment: String? = nil,
        body: String? = nil,
        url: URL? = nil,
        fileIDs: [String]? = nil,
        mediaCommentID: String? = nil,
        mediaCommentType: MediaCommentType? = nil,
        annotatableAttachmentID: String? = nil
    ) {
        self.context = context
        self.assignmentID = assignmentID
        self.userID = userID

        let submission = CreateSubmissionRequest.Body.Submission(
            annotatable_attachment_id: annotatableAttachmentID,
            text_comment: textComment,
            submission_type: submissionType,
            body: body,
            url: url,
            file_ids: fileIDs,
            media_comment_id: mediaCommentID,
            media_comment_type: mediaCommentType
        )

        request = CreateSubmissionRequest(
            context: context,
            assignmentID: assignmentID,
            body: .init(submission: submission)
        )
    }

    public var cacheKey: String?

    public var scope: Scope { Scope(
        predicate: NSPredicate(
            format: "%K == %@ AND %K == %@",
            #keyPath(Submission.assignmentID), assignmentID,
            #keyPath(Submission.userID), userID
        ),
        orderBy: #keyPath(Submission.attempt),
        ascending: false
    ) }

    public func makeRequest(environment: AppEnvironment, completionHandler: @escaping (APISubmission?, URLResponse?, Error?) -> Void) {
        environment.api.makeRequest(request) { [weak self] response, urlResponse, error in
            guard let self = self else { return }
            if error == nil {
                NotificationCenter.default.post(moduleItem: .assignment(self.assignmentID), completedRequirement: .submit, courseID: self.context.id)
                NotificationCenter.default.post(name: .moduleItemRequirementCompleted, object: nil)
            }
            completionHandler(response, urlResponse, error)
        }
    }

    public func write(response: APISubmission?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let item = response else {
            return
        }
        Submission.save(item, in: client)
        if item.late != true {
            NotificationCenter.default.post(name: .celebrateSubmission, object: nil, userInfo: [
                "assignmentID": assignmentID,
            ])
        }
    }
}

public class GetSubmission: APIUseCase {
    public let context: Context
    public let assignmentID: String
    public let userID: String

    public typealias Model = Submission

    public init(context: Context, assignmentID: String, userID: String) {
        self.assignmentID = assignmentID
        self.userID = userID
        self.context = context
    }

    public var cacheKey: String? {
        return "get-\(context.id)-\(assignmentID)-\(userID)-submission"
    }

    public var request: GetSubmissionRequest {
        return GetSubmissionRequest(context: context, assignmentID: assignmentID, userID: userID)
    }

    public var scope: Scope {
        return Scope(
            predicate: NSPredicate(
                format: "%K == %@ AND %K == %@",
                #keyPath(Submission.assignmentID),
                assignmentID,
                #keyPath(Submission.userID),
                userID
            ),
            order: [NSSortDescriptor(key: #keyPath(Submission.attempt), ascending: false)]
        )
    }

    public func write(response: APISubmission?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let item = response else {
            return
        }
        Submission.save(item, in: client)
    }
}

public class GetSubmissionsForStudent: CollectionUseCase {
    public typealias Model = Submission

    public let cacheKey: String?
    public let request: GetSubmissionsForStudentRequest
    public var scope: Scope

    init(context: Context, studentID: String) {
        cacheKey = "\(context.pathComponent)/students/\(studentID)/submissions"
        request = GetSubmissionsForStudentRequest(context: context, studentID: studentID)
        scope = Scope(
            predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(key: #keyPath(Submission.userID), equals: studentID),
                NSPredicate(key: #keyPath(Submission.isLatest), equals: true),
            ]),
            order: [
                NSSortDescriptor(key: #keyPath(Submission.gradedAt), ascending: false, selector: #selector(NSDate.compare(_:))),
            ]
        )
    }
}

public class GetSubmissions: CollectionUseCase {
    public typealias Model = Submission

    public let context: Context
    public let assignmentID: String
    public var filter: [Filter]
    public var shuffled: Bool

    public init(context: Context, assignmentID: String, filter: [Filter] = [], shuffled: Bool = false) {
        self.assignmentID = assignmentID
        self.context = context
        self.filter = filter
        self.shuffled = shuffled
    }

    public var cacheKey: String? { "\(context.pathComponent)/assignments/\(assignmentID)/submissions" }

    public var request: GetSubmissionsRequest {
        GetSubmissionsRequest(context: context, assignmentID: assignmentID, grouped: true, include: GetSubmissionsRequest.Include.allCases)
    }

    private var commonScopePredicates: [NSPredicate] { [
        NSPredicate(key: #keyPath(Submission.assignmentID), equals: assignmentID),
        NSPredicate(key: #keyPath(Submission.isLatest), equals: true),
        NSCompoundPredicate(orPredicateWithSubpredicates: [
            NSPredicate(format: "%K.@count == 0", #keyPath(Submission.enrollments)),
            NSPredicate(format: "NONE %K IN %@", #keyPath(Submission.enrollments.stateRaw), ["inactive", "invited"]),
            NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "ANY %K IN %@", #keyPath(Submission.enrollments.stateRaw), ["active"]),
                NSPredicate(format: "ANY %K != nil", #keyPath(Submission.enrollments.courseSectionID)),
            ]),
        ]),
    ]}

    public var scope: Scope { Scope(
        predicate: NSCompoundPredicate(andPredicateWithSubpredicates: commonScopePredicates + filter.map { $0.predicate }),
        order: order)
    }

    public func scopeKeepingIDs(_ ids: [String]) -> Scope { Scope(
        predicate: NSCompoundPredicate(andPredicateWithSubpredicates: commonScopePredicates +
                                        [NSCompoundPredicate(orPredicateWithSubpredicates: [
                                            NSCompoundPredicate(andPredicateWithSubpredicates: filter.map { $0.predicate }),
                                            NSPredicate(format: "%K IN %@", #keyPath(Submission.userID), ids),
                                        ]),
                                        ]),
        order: order)
    }

    private var order: [NSSortDescriptor] {
        if shuffled {
            return [NSSortDescriptor(key: #keyPath(Submission.shuffleOrder), ascending: true)]
        }

        return [
            NSSortDescriptor(key: #keyPath(Submission.sortableName), naturally: true), // In case of a group submission this is the name of the group
            NSSortDescriptor(key: #keyPath(Submission.user.sortableName), naturally: true),
            NSSortDescriptor(key: #keyPath(Submission.userID), naturally: true),
        ]
    }

    public func reset(context: NSManagedObjectContext) {
        let oldSubmissions: [Submission] = context.fetch(NSPredicate(key: #keyPath(Submission.assignmentID), equals: assignmentID), sortDescriptors: nil)
        context.delete(oldSubmissions)
    }

    public enum Filter: RawRepresentable, Equatable {
        case late, notSubmitted, needsGrading, graded
        case scoreAbove(Double)
        case scoreBelow(Double)
        case user(String)
        case section(Set<String>)

        public init?(rawValue: String?) {
            guard let rawValue = rawValue else { return nil }
            self.init(rawValue: rawValue)
        }

        public init?(rawValue: String) {
            switch rawValue {
            case "late":
                self = .late
            case "not_submitted":
                self = .notSubmitted
            case "needs_grading":
                self = .needsGrading
            case "graded":
                self = .graded
            default:
                let parts = rawValue.split(separator: "_")
                if parts.count == 3, parts[0] == "score", parts[1] == "above", let score = Double(parts[2]) {
                    self = .scoreAbove(score)
                } else if parts.count == 3, parts[0] == "score", parts[1] == "below", let score = Double(parts[2]) {
                    self = .scoreBelow(score)
                } else if parts.count == 2, parts[0] == "user" {
                    self = .user(String(parts[1]))
                } else if parts.count >= 2, parts[0] == "section" {
                    self = .section(Set(parts.dropFirst().map { String($0) }))
                } else {
                    return nil
                }
            }
        }

        public var rawValue: String {
            switch self {
            case .late:
                return "late"
            case .notSubmitted:
                return "not_submitted"
            case .needsGrading:
                return "needs_grading"
            case .graded:
                return "graded"
            case .scoreAbove(let score):
                return "score_above_\(score)"
            case .scoreBelow(let score):
                return "score_below_\(score)"
            case .user(let userID):
                return "user_\(userID)"
            case .section(let sectionIDs):
                return "section_\(sectionIDs.sorted().joined(separator: "_"))"
            }
        }

        var predicate: NSPredicate {
            switch self {
            case .late:
                return NSPredicate(key: #keyPath(Submission.late), equals: true)
            case .notSubmitted:
                return NSPredicate(key: #keyPath(Submission.submittedAt), equals: nil)
            case .needsGrading:
                return NSPredicate(format: """
                        %K != true AND (%K != nil AND (%K == 'pending_review' OR (
                        %K IN { 'graded', 'submitted' } AND
                        (%K == nil OR %K == false)
                    )))
                    """,
                    #keyPath(Submission.excusedRaw),
                    #keyPath(Submission.typeRaw),
                    #keyPath(Submission.workflowStateRaw),
                    #keyPath(Submission.workflowStateRaw),
                    #keyPath(Submission.scoreRaw),
                    #keyPath(Submission.gradeMatchesCurrentSubmission)
                )
            case .graded:
                return NSPredicate(format: "%K == true OR (%K != nil AND %K == 'graded')",
                    #keyPath(Submission.excusedRaw),
                    #keyPath(Submission.scoreRaw),
                    #keyPath(Submission.workflowStateRaw)
                )
            case .scoreAbove(let score):
                return NSPredicate(format: "%K > %@", #keyPath(Submission.scoreRaw), NSNumber(value: score))
            case .scoreBelow(let score):
                return NSPredicate(format: "%K < %@", #keyPath(Submission.scoreRaw), NSNumber(value: score))
            case .user(let userID):
                return NSPredicate(key: #keyPath(Submission.userID), equals: userID)
            case .section(let sectionIDs):
                return NSPredicate(format: "ANY %K IN %@", #keyPath(Submission.enrollments.courseSectionID), sectionIDs)
            }
        }

        public var name: String? {
            switch self {
            case .late:
                return SubmissionStatus.late.text
            case .notSubmitted:
                return SubmissionStatus.notSubmitted.text
            case .needsGrading:
                return NSLocalizedString("Needs Grading", comment: "")
            case .graded:
                return NSLocalizedString("Graded", comment: "")
            case .scoreBelow(let score):
                return String.localizedStringWithFormat(NSLocalizedString("Scored below %g", comment: ""), score)
            case .scoreAbove(let score):
                return String.localizedStringWithFormat(NSLocalizedString("Scored above %g", comment: ""), score)
            case .user(let userID):
                let user: User? = AppEnvironment.shared.database.viewContext.first(where: #keyPath(User.id), equals: userID)
                return user?.shortName
            case .section(let sectionIDs):
                let sections: [CourseSection] = AppEnvironment.shared.database.viewContext.fetch(
                    NSPredicate(format: "%K IN %@", #keyPath(CourseSection.id), sectionIDs),
                    sortDescriptors: [NSSortDescriptor(key: #keyPath(CourseSection.name), naturally: true)]
                )
                return ListFormatter.localizedString(from: sections.map { $0.name })
            }
        }
    }
}
