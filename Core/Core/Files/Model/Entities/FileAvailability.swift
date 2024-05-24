//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

public enum FileAvailability: Int, CaseIterable, Identifiable, Equatable {
    case published = 0
    case unpublished = 1
    case hidden = 2
    case scheduledAvailability = 3

    public var id: FileAvailability { self }

    public var isLastCase: Bool {
        Self.allCases.last == self
    }

    public init?(moduleItem: APIModuleItem) {
        guard moduleItem.content.isFile else { return nil }

        if moduleItem.published == false {
            self = .unpublished
        } else if moduleItem.content_details?.hidden == true {
            self = .hidden
        } else if moduleItem.content_details?.unlock_at != nil || moduleItem.content_details?.lock_at != nil {
            self = .scheduledAvailability
        } else {
            self = .published
        }
    }
}
