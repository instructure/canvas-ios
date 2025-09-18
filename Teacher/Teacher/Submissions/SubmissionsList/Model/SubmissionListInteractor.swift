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
import Core
import Combine

public typealias SubmissionStatusFilter = GetSubmissions.Filter.Status
public typealias SubmissionsFilter = GetSubmissions.Filter
public typealias SubmissionsSortMode = GetSubmissions.SortMode

public struct SubmissionListPreference {
    let filter: SubmissionsFilter?
    let sortMode: SubmissionsSortMode

    var query: [URLQueryItem] {
        (filter?.query ?? []) + [sortMode.query]
    }
}

public protocol SubmissionListInteractor {

    var submissions: AnyPublisher<[Submission], Never> { get }
    var assignment: AnyPublisher<Assignment?, Never> { get }
    var course: AnyPublisher<Course?, Never> { get }
    var courseSections: AnyPublisher<[CourseSection], Never> { get }
    var assigneeGroups: AnyPublisher<[AssigneeGroup], Never> { get }

    var context: Context { get }
    var assignmentID: String { get }

    func refresh() -> AnyPublisher<Void, Never>
    func applyPreference(_ pref: SubmissionListPreference)
}

public struct AssigneeGroup: Equatable {
    let id: String
    let name: String
    let memberIDs: [String]

    public init(group: Group, memberIDs: [String] = []) {
        self.id = group.id
        self.name = group.name
        self.memberIDs = memberIDs
    }

    #if DEBUG
    public init(id: String, name: String, memberIDs: [String] = []) {
        self.id = id
        self.name = name
        self.memberIDs = memberIDs
    }
    #endif

    public func containsUser(_ userID: String) -> Bool {
        memberIDs.contains(userID)
    }

    public var asSubmissionFetchedGroup: Submission.FetchedGroup {
        return .init(id: id, name: name)
    }
}
