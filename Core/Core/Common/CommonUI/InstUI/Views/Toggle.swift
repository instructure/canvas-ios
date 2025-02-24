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
        private let tint: Color

        public init(
            isOn: Binding<Bool>,
            tint: Color = Color(uiColor: Brand.shared.primary),
            @ViewBuilder label: @escaping () -> Label
        ) {
            self._isOn = isOn
            self.tint = tint
            self.label = label
        }

        public var body: some View {
            HStack {
                label()
                    .frame(maxWidth: .infinity, alignment: .leading)
                toggle
            }
            .accessibilityElement(children: .combine)
            .accessibilityAddTraitsIsToggle()
            .accessibilityValue(isOn ? Text("on", bundle: .core) : Text("off", bundle: .core))
        }

        private var toggle: some View {
            backgroundColor
                .frame(width: 44, height: 28)
                .clipShape(RoundedRectangle(cornerRadius: 100))
                .contentShape(Rectangle())
                .overlay(alignment: isOn ? .trailing : .leading) {
                    knob
                }
                .onTapGesture {
                    withAnimation {
                        isOn.toggle()
                    }
                }
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
            return isOn ? tint : .backgroundDark
        }

        private var knobBackground: Color {
            .backgroundLightest
        }

        private var knobForeground: Color {
            guard isEnabled else {
                return .backgroundDark
            }
            return isOn ? tint : .textDarkest
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
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @State var isOn1 = true
    @Previewable @State var isOn2 = false

    HStack(spacing: 20) {
        let label = Text(verbatim: "Toggle Label")

        VStack(spacing: 20) {
            Text(verbatim: "Light Mode")
            InstUI.Divider()
            Text(verbatim: "Active")
            InstUI.Toggle(isOn: $isOn1) { label }
            InstUI.Toggle(isOn: $isOn2) { label }
            InstUI.Divider()
            Text(verbatim: "Disabled")
            InstUI.Toggle(isOn: .constant(true))  { label }.disabled(true)
            InstUI.Toggle(isOn: .constant(false))  { label }.disabled(true)
        }
        .padding()
        VStack(spacing: 20) {
            Text(verbatim: "Dark Mode")
            InstUI.Divider()
            Text(verbatim: "Active")
            InstUI.Toggle(isOn: $isOn1) { label }
            InstUI.Toggle(isOn: $isOn2) { label }
            InstUI.Divider()
            Text(verbatim: "Disabled")
            InstUI.Toggle(isOn: .constant(true)) { label }.disabled(true)
            InstUI.Toggle(isOn: .constant(false)) { label }.disabled(true)
        }
        .padding()
        .background(Color.backgroundLightest)
        .environment(\.colorScheme, .dark)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .font(.regular12)
}
