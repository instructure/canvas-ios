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

struct AssistQuizFeedbackView: View {

    @State private var selectedItem: AssistQuizFeedbackType?
    private let items = AssistQuizFeedbackType.allCases

    var body: some View {
        HStack {
            Text("How was this question?", bundle: .horizon)
                .foregroundStyle(Color.textLightest)
                .font(.regular16)

            Spacer()
            ForEach(items, id: \.self) { item in
                Button(action: {
                    selectedItem = item
                }) {
                    feedbackImage(type: item, isSelected: item == selectedItem)
                }
            }
        }
    }
}

// MARK: - Components

extension AssistQuizFeedbackView {
    private func feedbackImage(type: AssistQuizFeedbackType, isSelected: Bool) -> some View {
        Image(systemName: isSelected ? type.selectedImage : type.unselectedImage )
            .foregroundColor(.white)
            .padding()
            .background(Circle().fill(Color.white.opacity(0.2)))
    }
}

#if DEBUG
#Preview {
    AssistQuizFeedbackView()
}
#endif
