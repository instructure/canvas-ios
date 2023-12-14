//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

public enum InboxMessageScope: String, CaseIterable, Hashable {
    case inbox, unread, starred, sent, archived

    public var localizedName: String {
        switch self {
        case .inbox: return NSLocalizedString("Inbox", comment: "")
        case .unread: return NSLocalizedString("Unread", comment: "")
        case .starred: return NSLocalizedString("Starred", comment: "")
        case .sent: return NSLocalizedString("Sent", comment: "")
        case .archived: return NSLocalizedString("Archived", comment: "")
        }
    }

    public var apiScope: GetConversationsRequest.Scope? {
        switch self {
        case .inbox: return nil
        case .unread: return .unread
        case .starred: return .starred
        case .sent: return .sent
        case .archived: return .archived
        }
    }
}
