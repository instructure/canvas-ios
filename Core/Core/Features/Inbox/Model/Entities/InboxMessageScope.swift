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
        case .inbox: return String(localized: "Inbox", bundle: .core)
        case .unread: return String(localized: "Unread", bundle: .core)
        case .starred: return String(localized: "Starred", bundle: .core)
        case .sent: return String(localized: "Sent", bundle: .core)
        case .archived: return String(localized: "Archived", bundle: .core)
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
