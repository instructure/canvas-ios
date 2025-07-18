//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

struct GradeSlider: View {
    var value: Binding<Double>
    var maxValue: Double
    var showTooltip: Bool
    var tooltipText: Text
    var score: Double
    var possible: Double
    var onEditingChanged: (Bool) -> Void = { _ in }
    let viewModel: GradeSliderViewModel

    var body: some View {
        GeometryReader { geometry in
            Slider(value: value, in: 0...maxValue, onEditingChanged: onEditingChanged)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { changeValue in
                            value.wrappedValue = viewModel.gradeValue(for: changeValue.location.x, in: geometry.size.width, maxValue: maxValue)
                            onEditingChanged(true)
                        }.onEnded { _ in
                            onEditingChanged(false)
                        }
                )
                .accessibility(label: Text("Grade Slider", bundle: .teacher))
                .accessibility(value: tooltipText)
                .overlay(tooltip, alignment: .bottom)
        }
    }

    @ViewBuilder
    private var tooltip: some View {
        if showTooltip {
            GeometryReader { geometry in
                let x = CGFloat(score / max(possible, 0.01))
                    * (geometry.size.width - 26) + 13 // center on slider thumb 26 wide
                tooltipText
                    .foregroundColor(.textLightest)
                    .padding(8)
                    .background(TooltipBackground().fill(Color.backgroundDarkest))
                    .position()
                    .offset(x: x, y: -26)
            }
        }
    }
}

struct TooltipBackground: Shape {
    func path(in rect: CGRect) -> Path { Path { path in
        let r: CGFloat = 5
        let arrowHeight: CGFloat = 5
        let arrowWidth: CGFloat = 10
        path.move(to: CGPoint(x: r, y: 0)) // top left, almost
        path.addLine(to: CGPoint(x: rect.maxX - r, y: 0))
        path.addArc(tangent1End: CGPoint(x: rect.maxX, y: 0), tangent2End: CGPoint(x: rect.maxX, y: r), radius: r)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - r))
        path.addArc(tangent1End: CGPoint(x: rect.maxX, y: rect.maxY), tangent2End: CGPoint(x: rect.maxX - r, y: rect.maxY), radius: r)
        path.addLine(to: CGPoint(x: rect.midX + arrowWidth / 2, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY + arrowHeight))
        path.addLine(to: CGPoint(x: rect.midX - arrowWidth / 2, y: rect.maxY))
        path.addLine(to: CGPoint(x: r, y: rect.maxY))
        path.addArc(tangent1End: CGPoint(x: 0, y: rect.maxY), tangent2End: CGPoint(x: 0, y: rect.maxY - r), radius: r)
        path.addLine(to: CGPoint(x: 0, y: r))
        path.addArc(tangent1End: CGPoint(x: 0, y: 0), tangent2End: CGPoint(x: r, y: 0), radius: r)
        }
    }
}
