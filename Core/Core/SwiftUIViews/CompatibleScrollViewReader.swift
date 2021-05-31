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

/**
 The purpose os this View is to be able to use ScrollViewReader on iOS 13 without any `if #available` statements. Acts as a ScrollViewReader on iOS 14, does nothing below that since there's no support from Apple.
 */
public struct CompatibleScrollViewReader<Content: View>: View {
    private let content: (CompatibleScrollViewProxy) -> Content

    public init(content: @escaping (CompatibleScrollViewProxy) -> Content) {
        self.content = content
    }

    @ViewBuilder
    public var body: some View {
        if #available(iOS 14, *) {
            ScrollViewReader(content: content)
        } else {
            content(IOS13ScrollViewReaderProxy())
        }
    }
}

public protocol CompatibleScrollViewProxy {
    func scrollTo<ID: Hashable>(_ id: ID, anchor: UnitPoint?)
}

/** Since there's no such thing on iOS 13 as a manually scrollable swiftui scrollview we just provide a mock implementation that does nothing. */
private struct IOS13ScrollViewReaderProxy: CompatibleScrollViewProxy {
    func scrollTo<ID: Hashable>(_ id: ID, anchor: UnitPoint?) {}
}

@available(iOSApplicationExtension 14.0, *)
extension ScrollViewProxy: CompatibleScrollViewProxy {}
