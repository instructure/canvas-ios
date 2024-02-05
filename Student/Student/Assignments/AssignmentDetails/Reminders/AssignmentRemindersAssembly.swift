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

enum AssignmentRemindersAssembly {

    static func makeDatePickerView(
        assignmentDate: Date,
        selectedTimeInterval: some Subject<DateComponents, Never>)
    -> UIViewController {
        let viewModel = AssignmentReminderDatePickerViewModel(router: AppEnvironment.shared.router,
                                                              selectedTimeInterval: selectedTimeInterval)
        let view = AssignmentReminderDatePickerView(viewModel: { viewModel })
        let host = CoreHostingController(view)
        return host
    }

    static func makeIntervalFormatter() -> DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        return formatter
    }
}
