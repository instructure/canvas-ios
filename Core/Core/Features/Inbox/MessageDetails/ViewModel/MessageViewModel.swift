//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

import SwiftUI

public class MessageViewModel: Identifiable {

    public let id: String
    public let body: String
    public let author: String
    public let date: String
    public let avatarName: String
    public let avatarURL: URL?
    public let attachments: [File]
    public let mediaComment: MediaComment?
    public let showAttachments: Bool
    public let conversationMessage: ConversationMessage?

    private let router: Router
    public var controller: WeakViewController?

    public init(
        id: String,
        body: String,
        author: String,
        date: String,
        avatarName: String
    ) {
        self.id = id
        self.body = body
        self.author = author
        self.date = date
        self.avatarName = avatarName

        self.avatarURL = nil
        self.attachments = []
        self.mediaComment = nil
        self.showAttachments = false
        self.conversationMessage = nil

        self.router = AppEnvironment.shared.router
    }

    public init(item: ConversationMessage, myID: String, userMap: [String: ConversationParticipant], router: Router) {
        self.id = item.id
        self.body = item.body
        self.router = router

        let from = userMap[ item.authorID ]?.displayName ?? ""
        let to = item.localizedAudience(myID: myID, userMap: userMap)
        self.author = from + " " + to

        self.date = item.createdAt?.relativeDateTimeString ?? ""
        self.avatarURL = userMap[ item.authorID ]?.avatarURL
        self.avatarName = userMap[ item.authorID ]?.name ?? ""

        self.attachments = item.attachments
        self.mediaComment = item.mediaComment
        self.showAttachments = !attachments.isEmpty || mediaComment != nil

        self.conversationMessage = item
    }

    public func handleURL(_ url: URL) -> OpenURLAction.Result {
        if let top = controller {
            router.route(to: url, from: top, options: .modal(isDismissable: true, embedInNav: true, addDoneButton: true))
        }
        return .handled
    }

    public func handleFileNavigation(url: URL?, controller: WeakViewController) {
        guard let url else { return }
        router.route(
            to: url.appendingQueryItems(
                .init(name: "canEdit", value: "false")
            ),
            from: controller,
            options: .modal(embedInNav: true, addDoneButton: true)
        )
    }
}

extension String {
    public func toAttributedStringWithLinks(type: NSTextCheckingResult.CheckingType = .allTypes) -> AttributedString {

        var attributedString = AttributedString(self)

        guard let detector = try? NSDataDetector(types: type.rawValue) else {
            return attributedString
        }

        let matches = detector.matches(in: self, options: [], range: NSRange(location: 0, length: count))

        for match in matches {
            let range = match.range
            let startIndex = attributedString.index(attributedString.startIndex, offsetByCharacters: range.lowerBound)
            let endIndex = attributedString.index(startIndex, offsetByCharacters: range.length)
            // Set the url for links
            if match.resultType == .link, let url = match.url {
                attributedString[startIndex..<endIndex].link = url
            }
        }
        return attributedString
    }
}
