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

public enum AssignmentDueDatesAssembly {

    public static func makeViewController(env: AppEnvironment,
                                          courseID: String,
                                          assignmentID: String) -> UIViewController {
        let interactor = AssignmentDueDatesInteractorLive(env: env, courseID: courseID, assignmentID: assignmentID)
        let viewModel = AssignmentDueDatesViewModel(interactor: interactor)
        let view = AssignmentDueDatesView(model: viewModel)
        return CoreHostingController(view)
    }

#if DEBUG

    public static func makePreview(dueDates: [AssignmentDate])
    -> AssignmentDueDatesView {
        let interactor = AssignmentDueDatesInteractorPreview(dueDates: dueDates)
        let viewModel = AssignmentDueDatesViewModel(interactor: interactor)
        return AssignmentDueDatesView(model: viewModel)
    }

#endif
}
