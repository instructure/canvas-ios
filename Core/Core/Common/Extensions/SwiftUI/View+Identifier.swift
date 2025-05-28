//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

extension View {

    /// This is an abstraction above `accessibilityIdentifier` with multiple purposes.
    /// - It acts as a single point of definition for any other identifier modifier used for testing or analytics purposes.
    /// - It is a convenience for `accessibilityIdentifier` which accepts an optional.
    ///   If the passed `identifier` is nil this method does nothing.
    @ViewBuilder
    public func identifier(_ identifier: String?) -> some View {
        if let identifier {
            self
                .accessibilityIdentifier(identifier)
                .testID(identifier)
        } else {
            self
        }
    }

    /// This is an abstraction above `accessibilityIdentifier` with multiple purposes.
    /// - It acts as a single point of definition for any other identifier modifier used for testing or analytics purposes.
    /// - It is a convenience for `accessibilityIdentifier` which accepts an optional.
    ///   If the passed `identifier` is nil this method does nothing.
    @ViewBuilder
    public func identifier(_ group: String?, _ identifier: String?) -> some View {
        if let identifier {
            let value = [group, identifier].joined(separator: ".")
            self
                .accessibilityIdentifier(value)
                .testID(value)
        } else {
            self
        }
    }
}
