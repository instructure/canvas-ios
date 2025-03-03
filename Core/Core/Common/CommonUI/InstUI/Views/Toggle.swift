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

    public struct Toggle<Label>: View where Label: View {
        @Environment(\.isEnabled) private var isEnabled: Bool
        @Binding private var isOn: Bool
        private var label: () -> Label

        public init(
            isOn: Binding<Bool>,
            @ViewBuilder label: @escaping () -> Label
        ) {
            self._isOn = isOn
            self.label = label
        }

        public var body: some View {
            HStack(spacing: 0) {
                label()
                    .frame(maxWidth: .infinity, alignment: .leading)
                toggle
            }
            .accessibilityElement(children: .combine)
            .accessibilityAddTraitsIsToggle()
            .accessibilityValue(accessibilityValue)
            .addHapticFeedback(isOn: isOn)
        }

        private var toggle: some View {
            backgroundColor
                .frame(width: 44, height: 28)
                .clipShape(RoundedRectangle(cornerRadius: 100))
                .overlay(alignment: isOn ? .trailing : .leading) {
                    knob
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation {
                        isOn.toggle()
                    }
                }
                .gesture(DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if abs(value.translation.width) < 20 { return }

                        withAnimation {
                            switch value.translation.width {
                            case ...0: isOn = false
                            case 0...: isOn = true
                            default: break
                            }
                        }
                    }
                )
                .padding(.leading, 8)
        }

        private var knob: some View {
            ZStack {
                Circle()
                    .fill(knobBackground)
                    .frame(width: 25, height: 25)
                    .shadow(color: .black.opacity(0.06), radius: 1, x: 0, y: 3)
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 3)

                (isOn ? Image.checkSolid : Image.xLine)
                    .size(14)
                    .foregroundColor(knobForeground)
                    .animation(.none, value: isOn)
            }
            .padding(.horizontal, 1.4)
            .compatibleGeometryGroup()
        }

        private var backgroundColor: Color {
            guard isEnabled else {
                return .backgroundMedium
            }
            return isOn ? .accentColor : .backgroundDark
        }

        private var knobBackground: Color {
            .backgroundLightest
        }

        private var knobForeground: Color {
            guard isEnabled else {
                return .backgroundDark
            }
            return isOn ? .accentColor : .textDarkest
        }

        private var accessibilityValue: String {
            if isOn {
                String(
                    localized: "toggle_on",
                    defaultValue: "on",
                    bundle: .core,
                    comment: "The ON state of a toggle."
                )
            } else {
                String(
                    localized: "toggle_off",
                    defaultValue: "off",
                    bundle: .core,
                    comment: "The OFF state of a toggle."
                )
            }
        }
    }
}

private extension View {

    @available(iOSApplicationExtension,
               obsoleted: 17.0,
               message: "Use `accessibilityAddTraits(.isToggle)` directly.")
    @ViewBuilder
    func accessibilityAddTraitsIsToggle() -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            self.accessibilityAddTraits(.isToggle)
        } else {
            self
        }
    }

    @available(iOSApplicationExtension,
               obsoleted: 17.0,
               message: "Use `sensoryFeedback(.selection, trigger: isOn)` directly.")
    @ViewBuilder
    func addHapticFeedback(isOn: Bool) -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            self.sensoryFeedback(.impact, trigger: isOn)
        } else {
            self
        }
    }
}

@available(iOS 17.0, *)
#Preview(traits: .sizeThatFitsLayout) {
    @Previewable @State var isOn1 = true
    @Previewable @State var isOn2 = false

    @ViewBuilder
    func factory(title: String) -> some View {
        let label = Text(verbatim: "Toggle Label")
        VStack(spacing: 20) {
            Text(title)
            InstUI.Divider()
            Text(verbatim: "Active")
            InstUI.Toggle(isOn: $isOn1) { label }
            InstUI.Toggle(isOn: $isOn2) { label }
            InstUI.Divider()
            Text(verbatim: "Disabled")
            InstUI.Toggle(isOn: .constant(true)) { label }.disabled(true)
            InstUI.Toggle(isOn: .constant(false)) { label }.disabled(true)
            InstUI.Divider()
            Text(verbatim: "Long Text")
            InstUI.Toggle(isOn: .constant(true)) {
                Text(InstUI.PreviewData.loremIpsumMedium)
            }.disabled(true)
        }
        .padding()
    }

    return HStack(spacing: 20) {
        factory(title: "Light Mode")
        factory(title: "Dark Mode")
            .background(Color.backgroundLightest)
            .environment(\.colorScheme, .dark)
    }
    .frame(maxWidth: .infinity)
    .font(.regular12)
    .accentColor(.course1)
}
