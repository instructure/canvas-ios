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

import SwiftUI

public enum PlannerAssembly {

    public static func makeToDoDetailsScreen(plannable: Plannable) -> UIViewController {
        let viewModel = ToDoDetailsScreenViewModel(plannable: plannable)
        let view = ToDoDetailsScreen(viewModel: viewModel)
        return CoreHostingController(view)
    }

    public static func makeEventDetailsViewController(eventId: String) -> UIViewController {
        let interactor = CalendarEventDetailsInteractorLive(calendarEventId: eventId)
        let viewModel = CalendarEventDetailsViewModel(interactor: interactor)
        let view = CalendarEventDetailsScreen(viewModel: viewModel)
        let host = CoreHostingController(view)
        return host
    }

    public static func makeFilterViewController(observedUserId: String?, didDismissPicker: @escaping () -> Void) -> UIViewController {
        let interactor = CalendarFilterInteractorLive(observedUserId: observedUserId)
        let viewModel = CalendarFilterViewModel(interactor: interactor, didDismissPicker: didDismissPicker)
        let view = CalendarFilterScreen(viewModel: viewModel)
        let host = CoreHostingController(view)
        return host
    }

#if DEBUG

    public static func makeEventDetailsPreview() -> some View {
        let interactor = CalendarEventDetailsInteractorPreview()
        let viewModel = CalendarEventDetailsViewModel(interactor: interactor)
        return CalendarEventDetailsScreen(viewModel: viewModel)
    }

    public static func makeFilterScreenPreview() -> some View {
        let interactor = CalendarFilterInteractorPreview(observedUserId: nil, env: .shared)
        let viewModel = CalendarFilterViewModel(interactor: interactor, didDismissPicker: {})
        return CalendarFilterScreen(viewModel: viewModel)
    }

#endif
}
