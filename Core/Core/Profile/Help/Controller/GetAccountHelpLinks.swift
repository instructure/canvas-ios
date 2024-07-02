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

public class GetAccountHelpLinks: CollectionUseCase {
    public typealias Model = HelpLink

    public let cacheKey: String? = "accounts/self/help_links"

    public let request = GetAccountHelpLinksRequest()

    let enrollment: HelpLinkEnrollment

    public init(for enrollment: HelpLinkEnrollment) {
        self.enrollment = enrollment
    }

    public var scope: Scope {
        return Scope(predicate: NSCompoundPredicate(orPredicateWithSubpredicates: [
            NSPredicate(format: "%K contains %@", #keyPath(HelpLink.availableToRaw), enrollment.rawValue),
            NSPredicate(format: "%K contains %@", #keyPath(HelpLink.availableToRaw), "user")
        ]), orderBy: #keyPath(HelpLink.position))
    }

    public func write(response: APIHelpLinks?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let links = response else { return }

        let predicate = NSPredicate(format: "%K == %@", #keyPath(HelpLink.id), "help")
        let help: HelpLink = client.fetch(predicate).first ?? client.insert()
        help.availableTo = [ .unenrolled, .user ]
        help.id = "help"
        help.position = -1
        help.subtext = links.help_link_icon
        help.text = links.help_link_name
        help.url = URL(string: "#help")!

        var position = 0
        for link in links.custom_help_links.isEmpty ? links.default_help_links : links.custom_help_links {
            let predicate = NSPredicate(format: "%K == %@", #keyPath(HelpLink.id), link.id ?? "")
            let model: HelpLink = client.fetch(predicate).first ?? client.insert()
            model.availableTo = link.available_to
            model.id = link.id
            model.position = position
            model.subtext = link.subtext
            model.text = link.text
            model.url = link.url
            position += 1
        }
    }
}
