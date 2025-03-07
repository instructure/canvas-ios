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

import Foundation
import SwiftUI
import Core

class SettingsGroupItemViewModel: ObservableObject {
    @Published var title: String
    @Published var valueLabel: String?
    @Published var discloserIndicator: Image?
    @Published var disabled: Bool = false
    @Published var isHidden: Bool

    let id: SettingGroupItemId
    let availableOffline: Bool
    let onSelect: (WeakViewController) -> Void

    init(
        title: String,
        valueLabel: String? = nil,
        discloserIndicator: Image? = Image.arrowOpenRightLine,
        id: SettingGroupItemId,
        availableOffline: Bool = true,
        isHidden: Bool = false,
        onSelect: @escaping (WeakViewController) -> Void
    ) {
        self.title = title
        self.valueLabel = valueLabel
        self.discloserIndicator = discloserIndicator
        self.id = id
        self.availableOffline = availableOffline
        self.isHidden = isHidden
        self.onSelect = onSelect
    }
}

#if DEBUG

extension SettingsGroupItemViewModel {
    static func makePreview(title: String, valueLabel: String? = nil, isDisabled: Bool = false) -> SettingsGroupItemViewModel {
        let viewModel = SettingsGroupItemViewModel(
            title: title,
            valueLabel: valueLabel,
            id: .inboxSignature,
            availableOffline: true,
            isHidden: false,
            onSelect: { _ in }
        )
        viewModel.disabled = isDisabled
        return viewModel
    }
}

#endif
