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

import Core
import Combine
import UIKit

enum AssignmentRemindersAssembly {

    static func makeRemindersSectionController(interactor: AssignmentRemindersInteractor) -> UIViewController {
        let viewModel = AssignmentRemindersViewModel(interactor: interactor,
                                                     router: AppEnvironment.shared.router)
        let reminderSection = CoreHostingController(AssignmentRemindersView(viewModel: viewModel))

        // When the SwiftUI view size changes we need to update the hosting view's intrinsic size
        // so the stack view can resize itself and its children
        reminderSection.sizingOptions = [.intrinsicContentSize]

        return reminderSection
    }

    static func makeDatePickerView(
        selectedTimeInterval: some Subject<DateComponents, Never>)
    -> UIViewController {
        let viewModel = AssignmentReminderDatePickerViewModel(selectedTimeInterval: selectedTimeInterval)
        let view = AssignmentReminderDatePickerView(viewModel: { viewModel })
        let host = CoreHostingController(view)
        return host
    }
}
