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

/// onSwipe a way for using swipe actions on scrollView
public extension View {
    func onSwipe(
        leading: [SwipeModel] = [],
        trailing: [SwipeModel] = []
    ) -> some View {
        return self.modifier(SlidableModifier(leading: leading, trailing: trailing))
    }
}

public struct SlidableModifier: ViewModifier, Animatable {

    public enum SlideAxis {
        case leftToRight
        case rightToLeft
    }

    private var contentOffset: CGSize {
        switch self.slideAxis {
        case .leftToRight:
            return .init(width: self.currentSlotsWidth, height: 0)
        case .rightToLeft:
            return .init(width: -self.currentSlotsWidth, height: 0)
        }
    }

    private var slotOffset: CGSize {
        switch self.slideAxis {
        case .leftToRight:
            return .init(width: self.currentSlotsWidth - self.totalSlotWidth, height: 0)
        case .rightToLeft:
            return .init(width: self.totalSlotWidth - self.currentSlotsWidth, height: 0)
        }
    }

    private var zStackAlignment: Alignment {
        switch self.slideAxis {
        case .leftToRight:
            return .leading
        case .rightToLeft:
            return .trailing
        }
    }

    /// Animated slot widths of total
    @State var currentSlotsWidth: CGFloat = 0

    /// To restrict the bounds of slots
    private func optWidth(value: CGFloat) -> CGFloat {
        return min(abs(value), totalSlotWidth)
    }

    public var animatableData: Double {
        get { Double(self.currentSlotsWidth) }
        set { self.currentSlotsWidth = CGFloat(newValue) }
    }

    private var totalSlotWidth: CGFloat {
        return slots.map { $0.style.slotWidth }.reduce(0, +)
    }

    private var slots: [SwipeModel] {
        slideAxis == .leftToRight ? leadingSlots : trailingSlots
    }

    @State private var slideAxis: SlideAxis = SlideAxis.leftToRight
    private var leadingSlots: [SwipeModel]
    private var trailingSlots: [SwipeModel]

    public init(
        leading: [SwipeModel],
        trailing: [SwipeModel]
    ) {
        self.leadingSlots = leading
        self.trailingSlots = trailing
    }

    private func flushState() {
        withAnimation {
            self.currentSlotsWidth = 0
        }
    }

    public func body(content: Content) -> some View {

        ZStack(alignment: self.zStackAlignment) {

            content
                .offset(self.contentOffset)

            if !currentSlotsWidth.isZero {
                Rectangle()
                    .foregroundColor(.white)
                    .opacity(0.001)
                    .onTapGesture(perform: flushState)
            }

            slotContainer
                .offset(self.slotOffset)
                .frame(width: self.totalSlotWidth)

        }
        .gesture(gesture)
    }

    // MARK: Slot Container
    private var slotContainer: some View {
        HStack(spacing: 0) {

            ForEach(self.slots) { slot in
                VStack(spacing: 4) {
                    Spacer()
                    slot.image()
                        .foregroundStyle(slot.style.foregroundColor)

                    Spacer()
                }
                .frame(width: slot.style.slotWidth)
                .background(slot.style.background)
                .onTapGesture {
                    slot.action()
                    self.flushState()
                }
            }
        }
    }

    // MARK: - Drag Gesture
    private var gesture: some Gesture {
        DragGesture()
            .onChanged { value in
                let amount = value.translation.width

                if amount < 0 {
                    self.slideAxis = .rightToLeft
                } else {
                    self.slideAxis = .leftToRight
                }

                self.currentSlotsWidth = self.optWidth(value: amount)
            }
            .onEnded { _ in
                withAnimation {
                    if self.currentSlotsWidth < (self.totalSlotWidth / 2) {
                        self.currentSlotsWidth = 0
                    } else {
                        self.currentSlotsWidth = self.totalSlotWidth
                    }
                }
            }
    }
}

public struct SwipeModel: Identifiable {
    /// Id
    public let id: String
    /// The image will be displayed.
    public let image: () -> Image
    /// Tap Action
    public let action: () -> Void
    /// Style
    public let style: SwipeStyle

    public init(
        id: String,
        image: @escaping () -> Image,
        action: @escaping () -> Void,
        style: SwipeStyle
    ) {
        self.id = id
        self.image = image
        self.action = action
        self.style = style
    }
}

public struct SwipeStyle {
    /// Background color of slot.
    public let background: Color

    /// Foreground color color of slot.
    public let foregroundColor: Color

    /// Individual slot width
    public let slotWidth: CGFloat

    public init(
        background: Color,
        foregroundColor: Color = Color.textLightest,
        slotWidth: CGFloat = 60
    ) {
        self.background = background
        self.foregroundColor = foregroundColor
        self.slotWidth = slotWidth
    }
}
