//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

import Observation

@Observable
final class EnrollConfirmationViewModel {
    let id = UUID().uuidString
    var isLoading: Bool
    var isPresented: Bool
    let onTap: () -> Void

    init(isLoading: Bool = false, isPresented: Bool = false, onTap: @escaping () -> Void = {}) {
        self.isLoading = isLoading
        self.isPresented = isPresented
        self.onTap = onTap
    }
}

extension EnrollConfirmationViewModel: Equatable {
    static func == (lhs: EnrollConfirmationViewModel, rhs: EnrollConfirmationViewModel) -> Bool {
        lhs.id == rhs.id && lhs.isPresented == rhs.isPresented && lhs.isLoading == rhs.isLoading
    }
}

struct EnrollConfirmationPreferenceKey: PreferenceKey {
    static var defaultValue: EnrollConfirmationViewModel?

    static func reduce(value: inout EnrollConfirmationViewModel?, nextValue: () -> EnrollConfirmationViewModel?) {
        value = nextValue()
    }
}
