//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
import CoreData

public class Assignment: NSManagedObject {
    @NSManaged public var allowedExtensions: [String]
    @NSManaged public var courseID: String
    @NSManaged public var quizID: String?
    @NSManaged public var details: String?
    @NSManaged public var dueAt: Date?
    @NSManaged var gradingTypeRaw: String
    @NSManaged public var htmlURL: URL
    @NSManaged public var id: String
    @NSManaged public var name: String
    @NSManaged var pointsPossibleRaw: NSNumber?
    @NSManaged public var submission: Submission?
    @NSManaged var submissionTypesRaw: [String]
    @NSManaged public var position: Int
    @NSManaged public var lockAt: Date?
    @NSManaged public var unlockAt: Date?
    @NSManaged public var lockedForUser: Bool
    @NSManaged public var url: URL?
    @NSManaged public var fileSubmission: FileSubmission?

    public var gradingType: GradingType {
        get { return GradingType(rawValue: gradingTypeRaw) ?? .points }
        set { gradingTypeRaw = newValue.rawValue }
    }

    public var pointsPossible: Double? {
        get { return pointsPossibleRaw?.doubleValue }
        set { pointsPossibleRaw = NSNumber(value: newValue) }
    }

    public var submissionTypes: [SubmissionType] {
        get { return submissionTypesRaw.compactMap { SubmissionType(rawValue: $0) } }
        set { submissionTypesRaw = newValue.map { $0.rawValue } }
    }
}

extension Assignment: Scoped {

    public enum ScopeKeys {
        case details(String)
        case courseList(String)
    }

    public static func scope(forName name: ScopeKeys) -> Scope {
        switch name {
        case let .details(id):
            return .where(#keyPath(Assignment.id), equals: id)
        case let .courseList(id):
            return Scope.where(#keyPath(Assignment.courseID), equals: id, orderBy: #keyPath(Assignment.position), ascending: true)
        }
    }
}

extension Assignment {
    func update(fromApiModel item: APIAssignment, in client: PersistenceClient, updateSubmission: Bool) throws {
        id = item.id.value
        name = item.name
        courseID = item.course_id.value
        quizID = item.quiz_id?.value
        details = item.description
        pointsPossible = item.points_possible
        dueAt = item.due_at
        htmlURL = item.html_url
        gradingType = item.grading_type
        submissionTypes = item.submission_types
        allowedExtensions = item.allowed_extensions ?? []
        position = item.position
        unlockAt = item.unlock_at
        lockAt = item.lock_at
        lockedForUser = item.locked_for_user ?? false
        url = item.url
        if updateSubmission {
            if let submissionItem = item.submission {
                let sub = submission ?? client.insert()
                try sub.update(fromApiModel: submissionItem, in: client)
                submission = sub
            } else if let submission = submission {
                try client.delete(submission)
                self.submission = nil
            }
        }
    }

    public var canMakeSubmissions: Bool {
        return submissionTypes.count > 0 &&
            !submissionTypes.contains(.none) &&
            (fileSubmission == nil || fileSubmission?.submitted == true || fileSubmission?.failed == true)
    }

    public var allowedUTIs: [UTI] {
        var utis: [UTI] = []

        if submissionTypes.contains(.online_upload) {
            if allowedExtensions.isEmpty {
                utis += [.any]
            } else {
                utis += allowedExtensions.compactMap(UTI.init)
            }
        }

        if submissionTypes.contains(.media_recording) {
            utis += [.video, .audio]
        }

        if submissionTypes.contains(.online_text_entry) {
            utis += [.text]
        }

        if submissionTypes.contains(.online_url) {
            utis += [.url]
        }

        return utis
    }
}
