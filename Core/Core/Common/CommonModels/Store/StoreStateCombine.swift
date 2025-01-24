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

import Combine

public extension StoreState {

    /**
     Combines multiple `StoreState`s to a single one.

     The final state will be:
     - loading: If there's at least one state which is loading.
     - error: If there's at least one state which is error.
     - data: If states are only consists of data and empty states.
     - empty: If all states are empty.
     */
    static func combineLatest<P: Publisher<StoreState, Never>>(_ p1: P,
                                                               _ p2: P)
    -> any Publisher<StoreState, Never> {
        Publishers
            .CombineLatest(p1,
                           p2)
            .map { [$0.0, $0.1] }
            .map { statesToSingleState($0) }
            .removeDuplicates()
    }

    static func combineLatest<P: Publisher<StoreState, Never>>(_ p1: P,
                                                               _ p2: P,
                                                               _ p3: P)
    -> any Publisher<StoreState, Never> {
        Publishers
            .CombineLatest3(p1,
                            p2,
                            p3)
            .map { [$0.0, $0.1, $0.2] }
            .map { statesToSingleState($0) }
            .removeDuplicates()
    }

    private static func statesToSingleState(_ states: [StoreState]) -> StoreState {
        if states.contains(.loading) {
            return .loading
        } else if states.contains(.error) {
            return .error
        } else if states.contains(.data) {
            return .data
        } else {
            return .empty
        }
    }
}
