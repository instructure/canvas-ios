//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

public struct QuizSubmissionListItemView: View {
    private var model: QuizSubmissionListItemViewModel
    private var cellDidTap: () -> Void

    public init(model: QuizSubmissionListItemViewModel, cellDidTap: @escaping () -> Void) {
        self.model = model
        self.cellDidTap = cellDidTap
    }

    public var body: some View {
        Button {
            cellDidTap()
        } label: {
            cellContent
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(model.a11yLabel)
    }

    private var cellContent: some View {
        HStack(alignment: .center, spacing: 14) {
            Avatar(name: model.name, url: model.profileImageURL)
                .frame(width: 36, height: 36)
                .padding(.top, 5)
            VStack(alignment: .leading, spacing: 1) {
                Text(model.displayName)
                    .font(.semibold16)
                    .foregroundColor(.textDarkest)
                    .lineLimit(1)
                Text(model.status)
                    .foregroundColor(model.statusColor)
                    .font(.regular14)
            }
            Spacer(minLength: 0)
            if let score = model.score {
                Text(score)
                    .foregroundColor(.textDark)
                    .font(.regular12)
            }
        }
        .padding(.top, 12)
        .padding(.bottom, 12)
        .padding(.leading, 16)
        .padding(.trailing, 16)
        .background(Color.backgroundLightest)
        .contentShape(Rectangle())
    }
}

#if DEBUG

struct QuizSubmissionListItemView_Previews: PreviewProvider {
    static let env = PreviewEnvironment()

    static var previews: some View {
        QuizSubmissionListItemView(model: .init(item: .make()), cellDidTap: {})
            .previewLayout(.sizeThatFits)
    }
}

#endif
