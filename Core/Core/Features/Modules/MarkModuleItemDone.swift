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

public struct MarkModuleItemDone: APIUseCase {
    public typealias Model = ModuleItem

    // MARK: - Dependencies

    public let courseID: String
    public let moduleID: String
    public let moduleItemID: String
    public let done: Bool

    // MARK: - Init

    public init(
        courseID: String,
        moduleID: String,
        moduleItemID: String,
        done: Bool
    ) {
        self.courseID = courseID
        self.moduleID = moduleID
        self.moduleItemID = moduleItemID
        self.done = done
    }
    public var cacheKey: String?

    public var request: PutMarkModuleItemDone {
        PutMarkModuleItemDone(
            courseID: courseID,
            moduleID: moduleID,
            moduleItemID: moduleItemID,
            done: done
        )
    }

    public func makeRequest(environment: AppEnvironment, completionHandler: @escaping RequestCallback) {
        environment.api.makeRequest(request) { response, urlResponse, error in
            if error == nil {
                NotificationCenter.default.post(name: .moduleItemRequirementCompleted, object: nil)
            }
            completionHandler(response, urlResponse, error)
        }
    }
    public func write(
        response: APINoContent?,
        urlResponse: URLResponse?,
        to client: NSManagedObjectContext
    ) { }
}
