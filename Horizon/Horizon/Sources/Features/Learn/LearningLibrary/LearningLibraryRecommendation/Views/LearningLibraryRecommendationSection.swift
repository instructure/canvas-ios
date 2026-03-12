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

import Core
import HorizonUI
import SwiftUI

struct LearningLibraryRecommendationSection: View {
    let items: [LearningLibraryCardModel]
    @State var viewModel: LearningLibraryRecommendationListViewModel
    @Environment(\.viewController) private var viewController

    var body: some View {
        VStack(spacing: .zero) {
            ScrollView(.horizontal) {
                LazyHStack(spacing: .huiSpaces.space24) {
                    ForEach(items) { item in
                        LearningLibraryCardView(
                            model: item,
                            isBookmarkLoading: viewModel.isBookmarkLoading(forItemWithId: item.id),
                            onBookmarkTap: {
                                viewModel.addBookmark(model: item)
                            },
                            enrollTap: {
                                viewModel.showEnrollConfirmation(model: item, viewController: viewController)
                            },
                            onTapItem: {
                                viewModel.navigateToLearningLibraryItemDetails(item, from: viewController)
                            }
                        )
                        .plainListRowStyle()
                        .padding(.top, .huiSpaces.space8)
                        .containerRelativeFrame(.horizontal)
                    }
                }
                .scrollTargetLayout()
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $viewModel.scrollPosition)
            .animation(.smooth, value: viewModel.scrollPosition)
            .contentMargins(.horizontal, .huiSpaces.space24, for: .scrollContent)
            .plainListRowStyle()

            if viewModel.shouldShowButtons {
                HStack(spacing: HorizonUI.spaces.space16) {
                    previousButton
                    nextButton
                }
                .plainListRowStyle()
                .padding(.bottom, .huiSpaces.space4)
            }
        }

    }

    private var previousButton: some View {
        stepButton(
            image: Image.huiIcons.chevronLeft,
            disabled: viewModel.isAtStart
        ) {
            withAnimation(.smooth(duration: 0.3)) {
                viewModel.goToPreviousCard()
            }
        }
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel(String(localized: "Go to previous item"))
    }

    private var nextButton: some View {
        stepButton(
            image: Image.huiIcons.chevronRight,
            disabled: viewModel.isAtEnd
        ) {
            withAnimation(.smooth(duration: 0.3)) {
                viewModel.goToNextCard()
            }
        }
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel(String(localized: "Go to next item"))
    }

    private func stepButton(image: Image, disabled: Bool, action: @escaping () -> Void) -> some View {
        HorizonUI.IconButton(
            image,
            type: .whiteGrayOutline,
            action: action
        )
        .disabled(disabled)
        .opacity(disabled ? 0.5 : 1)
    }
}

#if DEBUG
#Preview {
    ScrollView {
        LearningLibraryRecommendationSection(
            items: (0..<10).map { id in
                .init(
                    id: id.description,
                    name: "Adipiscing Elit Learning Object Name Here",
                    imageURL: URL(string: "https://img.freepik.com/free-photo/abstract-flowing-neon-wave-background_53876-101942.jpg"),
                    itemType: .assignment,
                    estimatedTime: "XX mins",
                    isRecommended: true,
                    isCompleted: true,
                    isBookmarked: true,
                    numberOfUnits: 100
                )
            }, viewModel: LearningLibraryRecommendationListViewModel(
                interactor: LearningLibraryInteractorPreview(),
                router: AppEnvironment.shared.router,
                didSendEvent: .init()
            )
        )
    }
    .background(Color.huiColors.surface.pagePrimary)
}
#endif
