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

import SwiftUI

struct WidgetReloadHandler: Equatable {
    let id: UUID
    let handler: (@escaping () -> Void) -> Void

    static func == (lhs: WidgetReloadHandler, rhs: WidgetReloadHandler) -> Bool {
        lhs.id == rhs.id
    }
}

struct WidgetReloadHandlersKey: PreferenceKey {
    static var defaultValue: [WidgetReloadHandler] = []

    static func reduce(value: inout [WidgetReloadHandler], nextValue: () -> [WidgetReloadHandler]) {
        value.append(contentsOf: nextValue())
    }
}

extension View {
    func onWidgetReload(_ handler: @escaping (@escaping () -> Void) -> Void) -> some View {
        preference(key: WidgetReloadHandlersKey.self, value: [WidgetReloadHandler(id: UUID(), handler: handler)])
    }

    func captureWidgetReloadHandlers(_ binding: Binding<[WidgetReloadHandler]>) -> some View {
        onPreferenceChange(WidgetReloadHandlersKey.self) { handlers in
            binding.wrappedValue = handlers
        }
    }
}
