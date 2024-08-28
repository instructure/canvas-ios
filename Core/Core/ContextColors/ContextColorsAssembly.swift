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

import Foundation

public class ContextColorsAssembly {
    private static var interactor: ContextColorsInteractor?

    public static func makeInteractor() -> ContextColorsInteractor {
        guard let interactor else {
            let interactor = ContextColorsInteractorLive(
                k5State: AppEnvironment.shared.k5
            )
            self.interactor = interactor
            return interactor
        }

        return interactor
    }

    public static func makeViewModel(
        canvasContextID: String
    ) -> ContextColorViewModel {
        ContextColorViewModel(
            interactor: makeInteractor(),
            canvasContextID: canvasContextID
        )
    }

    public static func reset() {
        interactor = nil
    }
}
