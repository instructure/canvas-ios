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

final class AccountAssembly {
    static func makeView() -> AccountView {
        AccountView(
            viewModel: AccountViewModel(
                getUserInteractor: GetUserInteractorLive(),
                sessionInteractor: SessionInteractor()
            )
        )
    }

    #if DEBUG
    static func makePreview() -> AccountView {
        let getUserInteractorPreview = GetUserInteractorPreview()
        let viewModel = AccountViewModel(
            getUserInteractor: getUserInteractorPreview,
            sessionInteractor: SessionInteractor()
        )
        return AccountView(viewModel: viewModel)
    }
    #endif
}
