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

import UIKit
import Core

final class NotebookAssembly {
    static func make(modal: Bool = false) -> CoreHostingController<NotebookView>? {
        let env = AppEnvironment.shared
        guard let root = env.window?.rootViewController else {
            fatalError("No root view controller")
        }
        let router = env.router
        var viewController: CoreHostingController<NotebookView>!
        let viewModel = NotebookViewModel(
            router: router,
            getCoursesUseCase: GetCoursesUseCase()
        )
        let view = NotebookView(state: viewModel)
        viewController = CoreHostingController(view)
        viewModel.viewController = viewController
        if(modal) {
            router.show(viewController ?? CoreHostingController(view), from: root, options: .modal(
                .pageSheet
            ))
            return nil
        }
        return viewController
    }
}
