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

extension HorizonUI.ButtonStyles {
    fileprivate struct Typography: ButtonStyle {
        @Environment(\.isEnabled) private var isEnabled
        private let typography: HorizonUI.Typography.Name

        init(_ typography: HorizonUI.Typography.Name) {
            self.typography = typography
        }

        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .huiTypography(typography)
                .opacity(isEnabled ? (configuration.isPressed ? 0.8 : 1.0) : 0.5)
        }
    }
}

extension HorizonUI {
    public struct HUIAnnotationBar: ViewModifier {

        enum ButtonType: CaseIterable, Equatable, Identifiable {
            case confusing
            case important
            case addNote

            var id: Self { self }

            var label: String {
                switch self {
                case .confusing:
                    return String(localized: "Confusing", locale: .current)
                case .important:
                    return String(localized: "Important", locale: .current)
                case .addNote:
                    return String(localized: "Add a Note", locale: .current)
                }
            }
        }

        var isPresented: Binding<Bool>

        public init(isPresented: Binding<Bool>) {
            self.isPresented = isPresented
        }

        public func body(content: Content) -> some View {
            content
                .popover(
                    isPresented: isPresented,
                    arrowEdge: .bottom
                ) {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(Array(ButtonType.allCases.enumerated()), id: \.element.id) { index, type in

                                HStack {
                                    Button(
                                        type.label
                                    ) {}
                                    .lineLimit(1)
                                    .frame(maxHeight: .infinity)
                                    .padding(.horizontal, 8)
                                    .buttonStyle(HorizonUI.ButtonStyles.Typography(.p2))

                                    if index != ButtonType.allCases.count - 1 {
                                        Divider()
                                            .frame(maxHeight: .infinity)
                                            .background(Color(hexString: "#3D3D3D80"))
                                    }
                                }

                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .frame(maxHeight: .infinity)
                    .presentationBackground(Color(hexString: "#F2F2F2"))
                    .presentationCompactAdaptation(.popover)
                }
                .frame(maxHeight: 40)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

extension View {
    public func huiAnnotationBar(isPresented: Binding<Bool>) -> some View {
        self.modifier(HorizonUI.HUIAnnotationBar(isPresented: isPresented))
    }
}

#Preview {
    @State
    @Previewable
    var isPresented: Bool = false

    VStack {
        Text("This is some text. You may select some of this text")
            .frame(maxHeight: .infinity)
            .textSelection(.enabled)
            .huiAnnotationBar(isPresented: $isPresented)
    }
}
