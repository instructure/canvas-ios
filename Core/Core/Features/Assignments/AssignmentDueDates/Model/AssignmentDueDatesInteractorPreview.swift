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

#if DEBUG

import Combine
import Foundation

public class AssignmentDueDatesInteractorPreview: AssignmentDueDatesInteractor {
    // MARK: - Outputs
    public var state = CurrentValueSubject<StoreState, Never>(.loading)
    public var dueDates = CurrentValueSubject<[AssignmentDate], Never>([])

    public init(dueDates: [AssignmentDate] = []) {
        self.dueDates = CurrentValueSubject<[AssignmentDate], Never>(dueDates)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
            if dueDates.isEmpty {
                state.send(.empty)
            } else {
                state.send(.data)
            }
        }
    }
}

#endif
