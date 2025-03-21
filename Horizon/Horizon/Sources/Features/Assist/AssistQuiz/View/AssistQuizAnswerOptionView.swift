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
import Core

struct AssistQuizAnswerOptionView: View {
    let selectedAnswer: AssistQuizModel.AnswerOption
    let isSelected: Bool
    let isCorrect: Bool?

    var body: some View {
        HStack {
            Text(selectedAnswer.answer)
                .foregroundColor(isSelected ? .textDarkest : textColor)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .paddingStyle(.leading, .standard)

            Spacer()

            if let isCorrect = isCorrect {
                statusIcon(isCorrect: isCorrect)
            }
        }
        .paddingStyle(.vertical, .standard)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.backgroundLightest, lineWidth: 1)
                .background(RoundedRectangle(cornerRadius: 16).fill(backgroundColor))
        }
    }
}

// MARK: - Components

extension AssistQuizAnswerOptionView {
    private var textColor: Color {
        if let isCorrect = isCorrect {
            return isCorrect ? .backgroundSuccess : .backgroundDanger
        }
        return .textLightest
    }

    private var backgroundColor: Color {
        if isCorrect != nil {
            return .backgroundLightest
        }
        return isSelected ? .backgroundLightest : .clear
    }

    private func statusIcon(isCorrect: Bool) -> some View {
        Image(systemName: isCorrect ? "checkmark.circle" : "xmark.circle")
            .resizable()
            .foregroundColor( isCorrect ? .backgroundSuccess : .backgroundDanger)
            .frame(width: 24, height: 24)
            .paddingStyle(.trailing, .standard)
    }

    @ViewBuilder
    private var selectionIndicator: some View {
        ZStack {
            Circle()
                .strokeBorder(isSelected ? Color.black : Color.white, lineWidth: 1)
                .frame(width: 24, height: 24)
            if isSelected {
                Circle()
                    .fill(Color.black)
                    .frame(width: 12, height: 12)
            }
        }
        .paddingStyle(.trailing, .standard)
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
