//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

public enum FileEditItem: String, RawElementWrapper {
    case copyright = "edit-item.usage_rights.legal_copyright"
    case justification = "edit-item.usage_rights.use_justification"
    case done = "edit-item.done-btn"
    case publish = "edit-item.publish"
    case hidden = "edit-item.hidden"
    case unlockAt = "edit-item.unlock_at"
    case delete = "edit-item.delete"
}
