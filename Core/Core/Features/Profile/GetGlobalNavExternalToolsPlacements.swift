//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

public class GetGlobalNavExternalToolsPlacements: CollectionUseCase {
    public typealias Model = ExternalToolLaunchPlacement

    public let cacheKey: String? = "accounts/self/lti_apps/launch_definitions?placements[]=global_navigation"
    public let request = GetGlobalNavExternalToolsRequest()
    public let scope: Scope

    public init(enrollment: HelpLinkEnrollment) {
        scope = Scope(predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(
                format: "%K == %@",
                #keyPath(ExternalToolLaunchPlacement.locationRaw),
                ExternalToolLaunchPlacementLocation.global_navigation.rawValue
            ),
            NSCompoundPredicate(
                orPredicateWithSubpredicates: enrollment.allowedGlobalLTIDomains.map { $0.matchPredicate }
            )
        ]), orderBy: #keyPath(ExternalToolLaunchPlacement.title), naturally: true)
    }

    public func write(response: [APIExternalToolLaunch]?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let tools = response else { return }

        for tool in tools {
            for (locationRaw, placement) in tool.placements {
                let predicate = NSPredicate(
                    format: "%K == %@ AND %K == %@",
                    #keyPath(ExternalToolLaunchPlacement.definitionID),
                    tool.definition_id.value,
                    #keyPath(ExternalToolLaunchPlacement.locationRaw),
                    locationRaw
                )
                let model: ExternalToolLaunchPlacement = client.fetch(predicate).first ?? client.insert()
                model.definitionID = tool.definition_id.value
                model.domain = tool.domain
                model.locationRaw = locationRaw
                model.title = placement.title
                model.url = placement.url
            }
        }
    }
}

public extension HelpLinkEnrollment {

    var allowedGlobalLTIDomains: [LTIDomains] {
        switch self {
        case .observer:
            return [.masteryConnect]
        case .teacher, .student, .admin:
            return [.studio, .gauge, .masteryConnect, .eportfolio]
        default:
            return [.studio, .gauge]
        }
    }
}

private extension LTIDomains {

    var matchPredicate: NSPredicate {
        let format: String
        switch self {
        case .eportfolio:
            // This is to include sub-domains that has region-specific prefix.
            // Like `iad.` in this domain `iad.portfolio.instructure.com` which
            // represents `US-East` region.
            format = "%K CONTAINS[c] %@"
        case .studio, .gauge, .masteryConnect:
            format = "%K == %@"
        }

        return NSPredicate(format: format, #keyPath(ExternalToolLaunchPlacement.domain), rawValue)
    }
}
