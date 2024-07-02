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
            NSCompoundPredicate(orPredicateWithSubpredicates:
                enrollment.allowedGlobalLTIDomains.map {
                    NSPredicate(format: "%K == %@", #keyPath(ExternalToolLaunchPlacement.domain), $0)
                }
            )
        ]), orderBy: #keyPath(ExternalToolLaunchPlacement.title), naturally: true)
    }

    public func write(response: [APIExternalToolLaunch]?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let tools = response else { return }

        for tool in tools { for (locationRaw, placement) in tool.placements {
            let predicate = NSPredicate(format: "%K == %@ AND %K == %@",
                #keyPath(ExternalToolLaunchPlacement.definitionID), tool.definition_id.value,
                #keyPath(ExternalToolLaunchPlacement.locationRaw), locationRaw
            )
            let model: ExternalToolLaunchPlacement = client.fetch(predicate).first ?? client.insert()
            model.definitionID = tool.definition_id.value
            model.domain = tool.domain
            model.locationRaw = locationRaw
            model.title = placement.title
            model.url = placement.url
        } }
    }
}

public extension HelpLinkEnrollment {

    var allowedGlobalLTIDomains: [String] {
        var domains: [LTIDomains] = []

        switch self {
        case .observer:
            domains = [.masteryConnect]
        case .teacher, .student, .admin:
            domains = [.studio, .gauge, .masteryConnect]
        default:
            domains = [.studio, .gauge]
        }

        return domains.map(\.rawValue)
    }
}
