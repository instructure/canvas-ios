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
import Core

struct LearnerDashboardColorSelectorView: View {
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    @Binding var selectedColor: Color

    let whiteColor = Color.backgroundLightest.variantForLightMode
    let colors: [ColorData]

    var body: some View {
        DisclosureGroup {
            // Need to implement our own HFlow, this uses fixed spacing, we need flexible
            HorizonUI.HFlow {
                ForEach(colors) { colorData in
                    Button {
                        selectedColor = colorData.color
                    } label: {
                        let isSelected = colorData.color == selectedColor

                        Circle()
                            .fill(colorData.color)
                            .stroke(.borderLight, style: .init(lineWidth: 0.5))
                            .overlay {
                                if isSelected {
                                    Image.checkLine
                                        .resizable()
                                        .scaledFrame(size: 24)
                                        .foregroundStyle(
                                            selectedColor == whiteColor
                                            ? .textLightest.variantForDarkMode
                                            : .textLightest.variantForLightMode
                                        )
                                }
                            }
                            .scaledFrame(size: 40)
                            .shadow(color: .black.opacity(0.08), radius: 2, y: 2)
                            .shadow(color: .black.opacity(0.16), radius: 2, y: 1)
                            .accessibilityLabel(colorData.description)
                            .accessibilityAddTraits(isSelected ? .isSelected : [])
                    }
                }
            }
            .padding(.bottom, 16)
        } label: {
            HStack(spacing: 8) {
                Text("Dashboard Main Color", bundle: .student)
                    .foregroundStyle(.textDarkest)
                    .font(.semibold16, lineHeight: .fit)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)

                Circle()
                    .fill(selectedColor)
                    .scaledFrame(size: 15)
            }
            .paddingStyle(.top, .cellTop)
            .paddingStyle(.bottom, .cellBottom)
        }
        .disclosureGroupStyle(PlainDisclosureGroupStyle())
    }

    init(selectedColor: Binding<Color>) {
        self._selectedColor = selectedColor

        let courseColors = CourseColorsInteractorLive.colors.map {
            ColorData(color: $0.key.asColor, description: $0.value)
        }
        let additionalColors = [
            ColorData(
                color: .backgroundLightest.variantForLightMode,
                description: String(localized: "White", bundle: .core, comment: "This is a name of a color.")
            ),
            ColorData(
                color: .backgroundLightest.variantForDarkMode,
                description: String(localized: "Black", bundle: .core, comment: "This is a name of a color.")
            )
        ]

        colors =  courseColors + additionalColors
    }

    struct ColorData: Identifiable {
        let color: Color
        let description: String

        var id: String { description }
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
