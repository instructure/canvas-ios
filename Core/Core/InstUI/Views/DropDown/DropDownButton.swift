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

public struct DropDownButtonState: Equatable {
    var isDetailsShown: Bool = false
    var frame: CGRect = .zero
}

public struct DropDownButton<Label>: View where Label: View {
    @Binding var state: DropDownButtonState
    @ViewBuilder let label: () -> Label

    public var body: some View {
        Button(
            action: { withAnimation { state.isDetailsShown.toggle() } },
            label: label
        )
        .buttonStyle(.plain)
        .background {
            GeometryReader(content: { geometry in
                Color
                    .clear
                    .dropDownButtonFrame(geometry.frame(in: .global))
            })
        }
        .onPreferenceChange(DropDownButtonFramePrefKey.self, perform: { value in
            state.frame = value
        })
    }
}

extension DropDownButton where Label == Text {
    init<S: StringProtocol>(_ text: S, state: Binding<DropDownButtonState>) {
        self.init(state: state) {
            Text(text)
        }
    }
}

extension DropDownButtonState {

    struct Dimensions {
        var topSpacerHeight: CGFloat
        var listMaxSize: CGSize
        var leftSpacerWidth: CGFloat
    }

    func dimensions(given screenFrame: CGRect, prefSize: CGSize?) -> Dimensions {
        let topSpace = frame.minY - screenFrame.minY
        let bottomSpace = screenFrame.maxY - frame.maxY

        var dims = Dimensions(topSpacerHeight: 0,
                              listMaxSize: .zero,
                              leftSpacerWidth: 0)

        if topSpace > bottomSpace {
            let maxHeight = topSpace - 20
            let proposedHeight = prefSize
                .flatMap({ min(maxHeight, $0.height) }) ?? maxHeight

            dims.listMaxSize.height = proposedHeight
            dims.topSpacerHeight = topSpace - dims.listMaxSize.height - 5

        } else {
            dims.topSpacerHeight = frame.maxY - screenFrame.minY + 5

            let maxHeight = bottomSpace - 20
            let proposedHeight = prefSize
                .flatMap({ min(maxHeight, $0.height) }) ?? maxHeight

            dims.listMaxSize.height = proposedHeight
        }

        let maxWidth = min(screenFrame.width - 50, 320)
        dims.listMaxSize.width = prefSize.flatMap({ min(maxWidth, $0.width) }) ?? maxWidth

        let leftSpace = frame.minX
        let rightSpace = screenFrame.width - frame.maxX

        if leftSpace > rightSpace {
            let widthAdjustment = max(dims.listMaxSize.width - (leftSpace + frame.width), 0)
            dims.leftSpacerWidth = max(10, frame.maxX - dims.listMaxSize.width + widthAdjustment)
        } else {
            let widthAdjustment = min(rightSpace + frame.width - dims.listMaxSize.width, 0)
            dims.leftSpacerWidth = min(frame.minX + widthAdjustment, screenFrame.width - 10)
        }

        return dims
    }
}

// MARK: - Preferences

struct DropDownButtonFramePrefKey: PreferenceKey {
    static var defaultValue: CGRect { .zero }
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) { }
}

extension View {
    func dropDownButtonFrame(_ rect: CGRect) -> some View {
        preference(key: DropDownButtonFramePrefKey.self, value: rect)
    }
}

struct DropDownDetailsSizePrefKey: PreferenceKey {
    static var defaultValue: CGSize? { nil }
    static func reduce(value: inout CGSize?, nextValue: () -> CGSize?) {
        value = value ?? nextValue()
    }
}

extension View {

    func preferredDropDownDetailsSize(_ size: CGSize?) -> some View {
        preference(key: DropDownDetailsSizePrefKey.self, value: size)
    }

    func preferredAsDropDownDetails() -> some View {
        background(content: {
            GeometryReader(content: { geometry in
                Color
                    .clear
                    .preferredDropDownDetailsSize(geometry.size)
            })
        })
    }
}

struct ScreenFramePrefKey: PreferenceKey {
    static var defaultValue: CGRect { .zero }
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) { }
}

extension View {
    func screenFrame(_ rect: CGRect) -> some View {
        preference(key: ScreenFramePrefKey.self, value: rect)
    }
}

// MARK: - Helpers

extension Binding {

    func toggle<W: Equatable>(with value: Value) where Value == W? {
        if wrappedValue == value {
            wrappedValue = nil
        } else {
            wrappedValue = value
        }
    }
}

extension Array where Element: Equatable {

    mutating func toggleInsert(with value: Element) {
        if contains(value) {
            removeAll(where: { $0 == value })
        } else {
            append(value)
        }
    }
}
