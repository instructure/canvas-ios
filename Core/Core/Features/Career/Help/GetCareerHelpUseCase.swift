//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

import CoreData
import Foundation

public final class GetCareerHelpUseCase: APIUseCase {
    // MARK: - Typealias

    public typealias Model = CDCareerHelp
    public typealias Request = GetCareerHelpRequest

    // MARK: - Properties

    public var cacheKey: String? { "Career-Help" }
    public var request: GetCareerHelpRequest { .init() }
    public var scope: Scope { .all }

    // MARK: - Init

    public init() {  }

    public func write(
        response: [GetCareerHelpResponse]?,
        urlResponse: URLResponse?,
        to client: NSManagedObjectContext
    ) {
        guard let response else {
            return
        }
        let enabledIds = ["report_a_problem", "training_services_portal"]
        response.forEach { help in
            let isBugReport = help.id == "report_a_problem"
            if isBugReport || help.type == "custom" || enabledIds.contains(help.id.defaultToEmpty) {
                CDCareerHelp.save(apiEntity: help, isBugReport: isBugReport, in: client)
            }
        }
    }
}
