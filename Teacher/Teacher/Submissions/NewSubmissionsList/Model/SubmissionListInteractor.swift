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

public protocol SubmissionListInteractor {

    var submissions: CurrentValueSubject<[Submission], Never> { get }
    var assignment: CurrentValueSubject<Assignment?, Never> { get }
    var course: CurrentValueSubject<Course?, Never> { get }

    var context: Context { get }
    var assignmentID: String { get }

    func refresh() -> AnyPublisher<Void, Never>
    func applyFilter(_ filter: [GetSubmissions.Filter])
}
