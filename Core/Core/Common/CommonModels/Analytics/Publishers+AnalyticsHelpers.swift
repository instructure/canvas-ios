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

import Combine
import CombineExt

extension Publisher {

    /// Reports an analytics event when this publisher receives an output.
    /// The value itself  won't be sent to analytics, only the parameter called `name`.
    public func logReceiveOutput(
        _ name: String,
        to analytics: Analytics = .shared,
        storeIn set: inout Set<AnyCancellable>
    ) {
        ignoreFailure()
            .sink { _ in
                analytics.logEvent(name)
            }
            .store(in: &set)
    }
    /// Reports an analytics event when this publisher receives an output.
    /// The value itself  won't be sent to analytics, only the parameter called `name`.
    /// - parameters:
    ///   - dynamicName: You can use this block to provide a name based on the output's value.
    public func logReceiveOutput(
        _ dynamicName: @escaping (Output) -> String,
        to analytics: Analytics = .shared,
        storeIn set: inout Set<AnyCancellable>
    ) {
        ignoreFailure()
            .sink { value in
                analytics.logEvent(dynamicName(value))
            }
            .store(in: &set)
    }
}
