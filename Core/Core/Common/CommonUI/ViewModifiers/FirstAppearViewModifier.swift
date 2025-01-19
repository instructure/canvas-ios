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

import SwiftUI

extension View {
    func onFirstAppear(perform action: (() -> Void)? = nil) -> some View {
        modifier(FirstAppearViewModifier(action: action))
    }

    func onAppearOnceReferring<Value>(_ reference: Value, perform action: @escaping () -> Void) -> some View where Value: Equatable {
        modifier(ReferrableAppearOnceViewModifier(reference, action: action))
    }
}

private struct FirstAppearViewModifier: ViewModifier {
    @State private var didAppearOnce = false
    private let action: (() -> Void)?

    init(action: (() -> Void)? = nil) {
        self.action = action
    }

    func body(content: Content) -> some View {
        content.onAppear {
            guard !didAppearOnce else {
                return
            }
            didAppearOnce = true
            action?()
        }
    }
}

private struct ReferrableAppearOnceViewModifier<Value>: ViewModifier where Value: Equatable {

    let reference: Value
    @State private var called: Value?

    private let action: () -> Void

    init(_ reference: Value, action: @escaping () -> Void) {
        self.reference = reference
        self.action = action
    }

    func body(content: Content) -> some View {
        content.onAppear {
            if let called, called == reference { return }

            action()
            called = reference
        }
    }
}
