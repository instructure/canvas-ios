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

public struct K5HomeroomMySubjectsView: View {
    public private(set) var subjectCards: [K5HomeroomSubjectCardViewModel]

    @Environment(\.horizontalPadding) private var horizontalPadding
    @Environment(\.containerSize) private var containerSize
    // allow even an iPhoneSE2 to hold 2 cards next to each other in landscape
    private var isCompact: Bool { containerSize.width < 600 }
    private let cardSpacing: CGFloat = 24

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("My Subjects", bundle: .core)
                .font(.bold20)
                .foregroundColor(.textDarkest)
                .padding(.bottom, 16)
            let cardWidth = calculateCardWidth(containerWidth: containerSize.width - 2 * horizontalPadding)
            JustifiedGrid(itemCount: subjectCards.count, itemSize: CGSize(width: cardWidth, height: K5HomeroomSubjectCardView.Height), spacing: cardSpacing, width: containerSize.width) { cardIndex in
                K5HomeroomSubjectCardView(viewModel: subjectCards[cardIndex], width: cardWidth)
            }.padding(.bottom, cardSpacing)
        }
    }

    public init(subjectCards: [K5HomeroomSubjectCardViewModel]) {
        self.subjectCards = subjectCards
    }

    private func calculateCardWidth(containerWidth: CGFloat) -> CGFloat {
        let cardsPerRow: CGFloat = isCompact ? 1 : 2
        let cardWidth: CGFloat = {
            if isCompact {
                return containerWidth
            } else {
                let spacerCount = cardsPerRow - 1
                let spacerWidths = spacerCount * cardSpacing
                let usableWidth = containerWidth - spacerWidths
                return usableWidth / cardsPerRow
            }
        }()

        return cardWidth
    }
}

#if DEBUG

struct K5HomeroomMySubjectsView_Previews: PreviewProvider {
    static let cards = [
        K5HomeroomSubjectCardViewModel(courseId: "1", imageURL: nil, name: "Math", color: .textInfo, infoLines: []),
        K5HomeroomSubjectCardViewModel(courseId: "2", imageURL: nil, name: "Social Studies", color: .textWarning, infoLines: []),
        K5HomeroomSubjectCardViewModel(courseId: "3", imageURL: nil, name: "Music", color: nil, infoLines: [])
    ]

    static var previews: some View {
        K5HomeroomMySubjectsView(subjectCards: cards)
            .previewDevice(PreviewDevice(stringLiteral: "iPad (8th generation)"))
            .environment(\.containerSize, CGSize(width: 800, height: 0))
        K5HomeroomMySubjectsView(subjectCards: cards)
            .previewDevice(PreviewDevice(stringLiteral: "iPhone SE (2nd generation)"))
            .environment(\.containerSize, CGSize(width: 370, height: 0))
    }
}

#endif
