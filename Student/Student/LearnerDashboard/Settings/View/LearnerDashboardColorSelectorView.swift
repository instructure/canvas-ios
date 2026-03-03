//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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
import HorizonUI

struct LearnerDashboardColorSelectorView: View {
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    @Binding var selectedColor: Color

    var body: some View {
        DisclosureGroup {
            // Need to implement our own HFlow, this uses fixed spacing, we need flexible
            HorizonUI.HFlow {
                ForEach(Self.colors, id: \.self) { colorData in
                    Button {
                        selectedColor = colorData.color
                    } label: {
                        Circle()
                            .fill(colorData.color)
                            .stroke(.borderLight, style: .init(lineWidth: 0.5))
                            .overlay {
                                if colorData.color == selectedColor {
                                    Image.checkLine
                                        .foregroundStyle(.textLightest)
                                }
                            }
                            .frame(width: 40, height: 40)
                            .accessibilityLabel(colorData.description)
                    }
                }
            }
            .padding(.bottom, 16)
        } label: {
            HStack(spacing: 8) {
                Text("Dashboard main color", bundle: .student)
                    .foregroundStyle(.textDarkest)
                    .font(.semibold16, lineHeight: .fit)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Circle()
                    .fill(selectedColor)
                    .frame(width: 15, height: 15)

            }
            .paddingStyle(.top, .cellTop)
            .paddingStyle(.bottom, .cellBottom)
        }
        .disclosureGroupStyle(PlainDisclosureGroupStyle())
    }
}

struct PlainDisclosureGroupStyle: DisclosureGroupStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(spacing: 0) {
            Button {
                withAnimation {
                    configuration.isExpanded.toggle()
                }
            } label: {
                HStack {
                    configuration.label

                    Image.chevronDown
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 16)
                        .foregroundStyle(.textDark)
                        .rotationEffect(configuration.isExpanded ? .degrees(180) : .degrees(0))
                }
            }

            if configuration.isExpanded {
                configuration.content
                    .transition(.opacity)
            }
        }
    }
}

#Preview {
    @Previewable @State var selectedColor: Color = .course1

    VStack {
        LearnerDashboardColorSelectorView(selectedColor: $selectedColor)
            .padding(.horizontal)

        Spacer()
    }
    .background(.backgroundLight)
}
