//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

public enum InboxCoursePickerAssembly {
    public static func makeInboxCoursePickerViewController(selected: RecipientContext?, didSelect: @escaping ((RecipientContext) -> Void), env: AppEnvironment = .shared) -> UIViewController {
        let interactor = InboxCoursePickerInteractorLive(env: env)
        let viewModel = InboxCoursePickerViewModel(interactor: interactor, selected: selected, didSelect: didSelect)
        let view = InboxCoursePickerView(viewModel: viewModel)
        return CoreHostingController(view)
    }

#if DEBUG

    public static func makePreview(env: AppEnvironment) -> InboxCoursePickerView {
        let interactor = InboxCoursePickerInteractorPreview(env: env)
        let viewModel = InboxCoursePickerViewModel(interactor: interactor, didSelect: {_ in })
        return InboxCoursePickerView(viewModel: viewModel)
    }

#endif
}
