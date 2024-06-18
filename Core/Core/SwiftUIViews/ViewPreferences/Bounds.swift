//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

// MARK: - Saving View Anchor To Retrieve Bounds

public struct ViewBoundsPreferenceData {
    public let viewId: Int
    public let bounds: Anchor<CGRect>
}

/**
 This key allows one to save an anchor to the view's frame by an ID to the preference store so the actual frame can be retrieved later with a `GeometryProxy`.
 */
public struct ViewBoundsPreferenceKey: PreferenceKey {
    public typealias Value = [ViewBoundsPreferenceData]

    public static var defaultValue: [ViewBoundsPreferenceData] = []

    public static func reduce(value: inout [ViewBoundsPreferenceData], nextValue: () -> [ViewBoundsPreferenceData]) {
        value.append(contentsOf: nextValue())
    }
}

// MARK: - Saving View Bounds Directly

public struct ViewBounds: Equatable {
    public let viewId: Int
    public let bounds: CGRect
}

/**
 This key allows one to save a view's frame by an ID to the preference store.
 */
public struct ViewBoundsKey: PreferenceKey {
    public typealias Value = [ViewBounds]

    public static var defaultValue: [ViewBounds] = []

    public static func reduce(value: inout [ViewBounds], nextValue: () -> [ViewBounds]) {
        value.append(contentsOf: nextValue())
    }
}

/**
 This key allows one to save a view's frame by an ID to the preference store.
 */
public struct ViewFrameByID: PreferenceKey {
    public typealias Value = [String: CGRect]

    public static var defaultValue: [String: CGRect] = [:]

    public static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { _, newValue in newValue })
    }
}

// MARK: - Saving a Single View's Size

/**
 This key allows one to save a view's size to the preference store.
 */
public struct ViewSizeKey: PreferenceKey {
    public typealias Value = CGFloat

    public static var defaultValue: CGFloat = 0

    public static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}
