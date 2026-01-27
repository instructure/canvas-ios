//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

import Core
import SwiftUI

struct GradeSliderView: View {
    private let value: Binding<Double>
    private let pointsPossible: Double
    private let isPercent: Bool
    private let onEndEditing: (Double) -> Void

    @State private var viewModel = GradeSliderViewModel()
    @State private var showTooltip = false

    init(
        value: Binding<Double>,
        pointsPossible: Double,
        isPercent: Bool,
        onEndEditing: @escaping (Double) -> Void
    ) {
        self.value = value
        self.pointsPossible = pointsPossible
        self.isPercent = isPercent
        self.onEndEditing = onEndEditing
    }

    var body: some View {
        let score = value.wrappedValue
        let tooltipText = isPercent
            ? Text(round(score / max(pointsPossible, 0.01) * 100) / 100, number: .percent) // 42%
            : Text(viewModel.formatScore(score, maxPoints: pointsPossible)) // 42
        let a11yValue = isPercent
            ? tooltipText // 42%
            : Text(String.format(points: score)) // 42 points

        let maxScore = isPercent ? 100 : pointsPossible

        HStack(spacing: 16) {
            sliderButton(score: 0)
            ZStack {
                // disables page swipe around the slider
                Rectangle()
                    .contentShape(Rectangle())
                    .foregroundColor(.clear)
                    .gesture(DragGesture(minimumDistance: 0).onChanged { _ in })
                GradeSlider(
                    value: value,
                    tooltipText: tooltipText,
                    a11yValue: a11yValue,
                    maxValue: pointsPossible,
                    showTooltip: showTooltip,
                    viewModel: viewModel,
                    onEditingChanged: sliderChangedState
                )
            }
            sliderButton(score: maxScore)
        }
        .paddingStyle(set: .standardCell)
    }

    private func sliderButton(score: Double) -> some View {
        Button(
            action: { onEndEditing(score) },
            label: {
                let label = {
                    if isPercent {
                        return Text(verbatim: GradeFormatter.percentFormatter.string(from: NSNumber(value: score/100)) ?? "\(score)%")
                    } else {
                        return Text(score)
                    }
                }()

                label
                    .foregroundStyle(.tint)
                    .font(.semibold14)
                    .frame(height: 30)
                    .accessibilityLabel(
                        isPercent
                            ? GradeFormatter.percentFormatter.string(from: NSNumber(value: score/100)) ?? "\(score)%"
                            : String.format(points: score)
                    )
            }
        )
    }

    private func sliderChangedState(_ editing: Bool) {
        if editing == false {
            let value = value.wrappedValue
            if isPercent {
                let percentValue = round(value / max(pointsPossible, 0.01) * 100)
                onEndEditing(percentValue)
            } else { // slider uses points in all other cases where visible (points, gpa, letterGrade)
                onEndEditing(value)
            }
        }

        DispatchQueue.main.async {
            withAnimation(.default) {
                showTooltip = editing
            }
        }
    }
}
