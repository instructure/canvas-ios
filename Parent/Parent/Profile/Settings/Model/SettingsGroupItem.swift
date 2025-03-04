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

import Core
import SwiftUI

public class SettingsGroupItem {
    let id: SettingGroupItemId
    let title: String
    let valueLabel: String?
    let isSupportedOffline: Bool
    let discloserIndicator: Image?
    let onSelect: (WeakViewController) -> Void

    public init(
        id: SettingGroupItemId,
        title: String,
        valueLabel: String?,
        isSupportedOffline: Bool,
        discloserIndicator: Image? = Image.arrowOpenRightLine,
        onSelect: @escaping (WeakViewController) -> Void
    ) {
        self.id = id
        self.title = title
        self.valueLabel = valueLabel
        self.isSupportedOffline = isSupportedOffline
        self.discloserIndicator = discloserIndicator
        self.onSelect = onSelect
    }
}

public enum SettingGroupItemId {
    case appearance, about, inboxSignature
}
