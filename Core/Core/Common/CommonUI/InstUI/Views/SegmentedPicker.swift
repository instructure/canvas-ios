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

extension InstUI {

    public struct SegmentedPicker<
        SelectionValue: Hashable & RawRepresentable<Int>,
        Content: View
    >: View {

        private var selection: Binding<SelectionValue>
        private let segmentCount: Int
        private let onTapSelectedTab: (() -> Void)?
        private let content: () -> Content

        @State private var segmentSize: CGSize = .zero

        /// Segmented Picker will not detect touches on selected tab. This is the native behavior.
        public init(
            selection: Binding<SelectionValue>,
            @ViewBuilder content: @escaping () -> Content
        ) {
            self.init(
                selection: selection,
                segmentCount: 0,
                onTapSelectedTab: nil,
                content: content
            )
        }

        /// Segmented Picker will detect touches on selected tab.
        /// The drawback is that on iOS 18 native gestures like longpressing the selected tab (which shows the tab being pressed),
        /// and dragging the selected tab to change value won't work.
        public init(
            selection: Binding<SelectionValue>,
            segmentCount: Int,
            onTapSelectedTab: (() -> Void)?,
            @ViewBuilder content: @escaping () -> Content
        ) {
            self.selection = selection
            self.segmentCount = segmentCount
            self.onTapSelectedTab = onTapSelectedTab
            self.content = content
            updateSegmentedControlAppearance()
        }

        public var body: some View {
            if let onTapSelectedTab {
                ZStack(alignment: .leading) {
                    picker
                        .onSizeChange {
                            segmentSize = CGSize(
                                width: $0.width / CGFloat(segmentCount),
                                height: $0.height
                            )
                        }

                    let dx = CGFloat(selection.wrappedValue.rawValue) * segmentSize.width
                    InstUI.TapArea()
                        .frame(width: segmentSize.width, height: segmentSize.height)
                        .offset(x: dx)
                        .onTapGesture {
                            onTapSelectedTab()
                        }
                }
            } else {
                picker
            }
        }

        private var picker: some View {
            // Simply passing a string will be treated as a localized key
            // and will create an entry in the strings dictionary.
            Picker("" as String,
                   selection: selection.animation(.smooth(duration: 0.25)),
                   content: content
            )
            .pickerStyle(.segmented)
        }

        private func updateSegmentedControlAppearance() {
            // Segmented controls have a background image by default and colors we pass are applied to that image
            // with some opacity. Getting rid of the image is not that straightforward so we play around with the
            // colors to get a decent result for light and dark mode.
            let appearance = UISegmentedControl.appearance()
            appearance.backgroundColor = UIColor { traits in
                traits.isLightInterface ? .backgroundLightest : .backgroundLight
            }
            appearance.setTitleTextAttributes(
                [
                    .font: UIFont.scaledNamedFont(.semibold13),
                    .foregroundColor: UIColor.textDarkest
                ],
                for: .normal
            )
            // updateFontAppearance() overrides the selected state so we have to restore it
            appearance.setTitleTextAttributes(
                appearance.titleTextAttributes(for: .normal),
                for: .selected
            )
            appearance.selectedSegmentTintColor = .backgroundLightest
        }
    }
}

#if DEBUG

enum Segment: Int, CaseIterable {
    case one
    case two
    case three

    var title: String {
        switch self {
        case .one: "One"
        case .two: "Two"
        case .three: "Three"
        }
    }
}

#Preview {

    @Previewable @State var selectedSegment: Segment = .one

    InstUI.SegmentedPicker(
        selection: $selectedSegment
    ) {
        Text(Segment.one.title)
            .tag(Segment.one)
        Text(Segment.two.title)
            .tag(Segment.two)
        Text(Segment.three.title)
            .tag(Segment.three)
    }

    InstUI.SegmentedPicker(
        selection: $selectedSegment,
        segmentCount: Segment.allCases.count,
        onTapSelectedTab: { print("Did tap currently selected segment") }
    ) {
        Text(Segment.one.title)
            .tag(Segment.one)
        Text(Segment.two.title)
            .tag(Segment.two)
        Text(Segment.three.title)
            .tag(Segment.three)
    }
}

#endif
