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

// MARK: Measuring Size

private struct MeasuredSizeKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

extension View {

    func measuringSize(_ onMeasure: @escaping (CGSize) -> Void) -> some View {
        background {
            GeometryReader { g in
                Color.clear.preference(key: MeasuredSizeKey.self, value: g.size)
            }
            .onPreferenceChange(MeasuredSizeKey.self, perform: onMeasure)
        }
    }

    @ViewBuilder
    func measuringSizeOnce(_ value: Binding<CGSize>) -> some View {
        if value.wrappedValue.isZero {
            measuringSize { newSize in
                value.wrappedValue = newSize
            }
        } else {
            self
        }
    }

    @ViewBuilder
    func measuringSizeOnce(_ value: Binding<CGSize?>) -> some View {
        if value.wrappedValue == nil {
            measuringSize { newSize in
                value.wrappedValue = newSize
            }
        } else {
            self
        }
    }

    func measuringSize(_ value: Binding<CGSize>) -> some View {
        measuringSize { newSize in
            value.wrappedValue = newSize
        }
    }
}

extension CGSize {
    var isZero: Bool { width == 0 && height == 0 }
}

// MARK: -

struct DeferredValue<Value: Equatable>: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.value == rhs.value
    }

    private class Box<V> {
        var value: V
        init(value: V) {
            self.value = value
        }
    }

    private let box: Box<Value>
    var value: Value
    var deferred: Value {
        get { box.value }
        set { box.value = newValue }
    }

    init(value: Value) {
        self.box = Box(value: value)
        self.value = value
    }

    mutating func update() {
        value = box.value
    }
}

/*
extension UIApplication {

    var mainWindow: UIWindow? {
        let allScenes = connectedScenes.compactMap({ $0 as? UIWindowScene })
        return allScenes.compactMap({ $0.keyWindow }).first
    }

    var topController: UIViewController? {
        if var topController = mainWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        }
        return nil
    }
}
*/
