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
import RealmSwift

public class Assignment: Object {
    @objc public dynamic var id: String = ""
    @objc public dynamic var courseID: String = ""
    @objc public dynamic var name: String = ""
    @objc public dynamic var content: String?
    @objc public dynamic var pointsPossible: Double = 0
    @objc public dynamic var dueAt: Date?
    @objc public dynamic var htmlUrl: String = ""
    @objc private dynamic var rawGradingType: String = ""
    private var rawSubmissionTypes = List<String>()

    @objc public dynamic var submission: Submission?

    public var gradingType: APIAssignment.GradingType {
        set {
            rawGradingType = newValue.rawValue
        }
        get {
            return APIAssignment.GradingType(rawValue: rawGradingType) ?? .not_graded
        }
    }

    public var submissionTypes: [APIAssignment.SubmissionType] {
        set {
            rawSubmissionTypes = List()
            rawSubmissionTypes.append(objectsIn: newValue.map { $0.rawValue })
        }
        get {
            return rawSubmissionTypes.map { APIAssignment.SubmissionType(rawValue: $0) ?? .none }
        }
    }

    override public class func primaryKey() -> String? {
        return #keyPath(Assignment.id)
    }
}
