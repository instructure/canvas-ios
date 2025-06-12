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
import HorizonUI

struct AssistQuizAnswerOptionView: View {
    let selectedAnswer: AssistQuizModel.AnswerOption
    let isSelected: Bool
    let isCorrect: Bool?

    var body: some View {
        HStack {
            Text(selectedAnswer.answer)
                .huiTypography(.p1)
                .foregroundColor(textColor)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .padding(.huiSpaces.space16)
            Spacer()

            if let isCorrect = isCorrect {
                statusIcon(isCorrect: isCorrect)
            } else if isSelected {
                Image.huiIcons.check
                    .foregroundStyle(Color.huiColors.icon.default)
                    .padding(.trailing, .huiSpaces.space16)
            }
        }
        .background {
            RoundedRectangle(cornerRadius: HorizonUI.CornerRadius.level1_5.attributes.radius)
                .strokeBorder(Color.huiColors.icon.surfaceColored, lineWidth: 1)
                .background(RoundedRectangle(cornerRadius: HorizonUI.CornerRadius.level1_5.attributes.radius)
                    .fill(backgroundColor))
        }
    }
}

// MARK: - Components

extension AssistQuizAnswerOptionView {
    private var textColor: Color {
        if let isCorrect {
            return isCorrect ? Color.huiColors.text.success : Color.huiColors.text.error
        } else if isSelected {
            return Color.huiColors.text.title
        }
        return Color.huiColors.text.surfaceColored
    }

    private var backgroundColor: Color {
        if isCorrect != nil {
            return Color.huiColors.surface.cardPrimary
        }
        return isSelected ? Color.huiColors.surface.cardPrimary : .clear
    }

    @ViewBuilder
    private func statusIcon(isCorrect: Bool) -> some View {
        (isCorrect ? Image.huiIcons.checkCircle : Image.huiIcons.cancel)
            .resizable()
            .foregroundColor( isCorrect ? Color.huiColors.icon.success : Color.huiColors.icon.error)
            .frame(width: 24, height: 24)
            .padding(.trailing, .huiSpaces.space16)
    }
}

#if DEBUG
#Preview {
    AssistQuizAnswerOptionView(
        selectedAnswer: .init("Is the Earth flat?"),
        isSelected: true,
        isCorrect: nil
    )
}
#endif
