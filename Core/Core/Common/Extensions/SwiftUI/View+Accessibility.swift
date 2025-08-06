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

    // TODO: When removing iOS 17 support, we could update these methods, or even remove some,
    // because iOS 18 has `accessibilityLabel(_:, isEnabled:)` variants. Same for Value.

    /// This is a convenience overload of the `accessibilityLabel` method but this accepts an optional.
    /// If the passed `label` is nil this method does nothing.
    @ViewBuilder
    public func accessibilityLabel(_ label: String?) -> some View {
        if let label {
            self.accessibilityLabel(Text(label))
        } else {
            self
        }
    }

    /// This is a convenience overload of the `accessibilityLabel` method but this accepts an optional.
    /// If the passed `label` is nil this method does nothing.
    @ViewBuilder
    public func accessibilityLabel(_ label: Text?) -> some View {
        if let label {
            self.accessibilityLabel(label)
        } else {
            self
        }
    }

    /// This is a convenience overload of the `accessibilityValue` method but this accepts an optional.
    /// If the passed `value` is nil this method does nothing.
    @ViewBuilder
    public func accessibilityValue(optional value: String?) -> some View {
        if let value {
            self.accessibilityValue(Text(value))
        } else {
            self
        }
    }

    /// This is a convenience overload of the `accessibilityValue` method but this accepts an optional.
    /// If the passed `value` is nil this method does nothing.
    @ViewBuilder
    public func accessibilityValue(optional value: Text?) -> some View {
        if let value {
            self.accessibilityValue(value)
        } else {
            self
        }
    }
}
