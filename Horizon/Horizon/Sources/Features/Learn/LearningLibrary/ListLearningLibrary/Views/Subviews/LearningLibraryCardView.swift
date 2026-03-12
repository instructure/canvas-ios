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

struct LearningLibraryCardView: View {
    // MARK: - Dependencies

    private let model: LearningLibraryCardModel
    private let isBookmarkLoading: Bool
    private let onBookmarkTap: (() -> Void)
    private let enrollTap: (() -> Void)
    private let onTapItem: (() -> Void)

    // MARK: - Init

    init(
        model: LearningLibraryCardModel,
        isBookmarkLoading: Bool = false,
        onBookmarkTap: @escaping (() -> Void),
        enrollTap: @escaping (() -> Void),
        onTapItem: @escaping (() -> Void)
    ) {
        self.model = model
        self.isBookmarkLoading = isBookmarkLoading
        self.onBookmarkTap = onBookmarkTap
        self.enrollTap = enrollTap
        self.onTapItem = onTapItem
    }

    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            Button {
                onTapItem()
            } label: {
                VStack(alignment: .leading, spacing: .zero) {
                    imageView
                    titleView
                        .padding(.top, .huiSpaces.space16)
                        .padding(.bottom, .huiSpaces.space12)

                    if let recommendationText = model.recommendationText {
                        recommendationView(text: recommendationText)
                            .padding(.bottom, .huiSpaces.space16)
                    }
                }
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(cardAccessibilityLabel)
            .accessibilityValue(cardAccessibilityValue)
            .accessibilityHint(String(localized: "Double tap to view details"))
            .accessibilityAddTraits(.isButton)

            HStack(alignment: .bottom, spacing: .huiSpaces.space8) {
                descriptionView

                bookmarkButton
                    .fixedSize()
                    .accessibilityLabel(bookmarkAccessibilityLabel)
                    .accessibilityHint(String(localized: "Double tap to toggle bookmark"))
                    .accessibilityAddTraits(.isButton)
            }
        }
        .padding(.huiSpaces.space24)
        .background(Color.huiColors.surface.pageSecondary)
        .huiCornerRadius(level: .level5)
        .huiElevation(level: .level4)
        .plainListRowStyle()
        .padding(.bottom, .huiSpaces.space24)
    }

    private var cardAccessibilityLabel: String {
        var components: [String] = [model.name]
        components.append(String(format: "Item type %@", model.itemType.name))
        return components.joined(separator: ", ")
    }

    private var cardAccessibilityValue: String {
        var components: [String] = []

        if let estimatedTime = model.estimatedTime {
            components.append(String(format: String(localized: "Estimated time %@ minutes"), estimatedTime))
        }

        if let units = model.numberOfUnits, model.itemType == .course {
            components.append(String(format: String(localized: "number of units %d"), units))
        }

        if model.isRecommended {
            components.append(String(localized: "Recommended"))
        }

        if model.isInProgress {
            components.append(String(localized: "In progress"))
        }

        if model.isCompleted {
            components.append(String(localized: "Completed"))
        }

        if !model.isEnrolled {
            components.append(String(localized: "Not enrolled"))
        }

        return components.joined(separator: ", ")
    }

    private var bookmarkAccessibilityLabel: String {
        if model.isBookmarked {
            return String(localized: "Remove bookmark")
        } else {
            return String(localized: "Add bookmark")
        }
    }

    private var imageView: some View {
        ImageLoaderView(url: model.imageURL) {
            ZStack {
                model.itemType.style.backgroundColor
                model.itemType.icon
                    .foregroundStyle(model.itemType.style.foregroundColor())
            }
        }
        .huiCornerRadius(level: .level1_5, corners: .all)
        .frame(height: 155)
        .clipped()
        .accessibilityLabel("")
        .accessibilityRemoveTraits(.isImage)
        .accessibilityHidden(true)
        .background(Color.white)
    }

    private var titleView: some View {
        Text(model.name)
            .huiTypography(.labelLargeBold)
            .foregroundStyle(Color.huiColors.text.body)
            .frame(maxWidth: .infinity, alignment: .leading)
            .multilineTextAlignment(.leading)
    }

    private func recommendationView(text: String) -> some View {
        Text(text)
            .huiTypography(.p2)
            .foregroundStyle(Color.huiColors.text.dataPoint)
            .frame(maxWidth: .infinity, alignment: .leading)
            .multilineTextAlignment(.leading)
    }

    private var descriptionView: some View {
        HorizonUI.HFlow(spacing: .huiSpaces.space8, lineSpacing: .huiSpaces.space8) {
            itemTypeView
            if let estimatedTime = model.estimatedTime {
                defaultChip(title: String(format: "%@ mins", estimatedTime), icon: Image.huiIcons.schedule)
            }
            if let units = model.numberOfUnits, model.shouldShowProgressStatus {
                defaultChip(
                    title: String(format: String(localized: "%d units"), units),
                    icon: Image.huiIcons.coursesFormatListBulleted
                )
            }
            if model.isRecommended {
                recommendedView
            }
            if model.isInProgress, model.shouldShowProgressStatus {
                HorizonUI.StatusChip(
                    title: String(localized: "In progress"),
                    style: .gray,
                    icon: Image.huiIcons.trendingUp,
                    iconHeight: 10
                )
                .accessibilityHidden(true)
            }
            if model.isCompleted, model.shouldShowProgressStatus {
                HorizonUI.StatusChip(
                    title: String(localized: "Completed"),
                    style: .green,
                    icon: Image.huiIcons.checkCircle,
                )
                .accessibilityHidden(true)
            }
            Rectangle()
                .fill(Color.clear)
                .frame(height: 1)
                .frame(maxWidth: .infinity)
                .accessibilityHidden(true)
            if model.shouldShowEnrollButton {
                enrollButton
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    private var itemTypeView: some View {
        HorizonUI.StatusChip(
            title: model.itemType.name,
            style: model.itemType.style,
            icon: model.itemType.icon
        )
        .accessibilityHidden(true)
    }

    private var recommendedView: some View {
        HorizonUI.StatusChip(
            title: String(localized: "Recommended"),
            style: .honey,
            icon: Image.huiIcons.star
        )
        .accessibilityHidden(true)
    }

    private func defaultChip(title: String, icon: Image) -> some View {
        HorizonUI.StatusChip(
            title: title,
            style: .gray,
            icon: icon
        )
        .accessibilityHidden(true)
    }

    private var bookmarkButton: some View {
        HorizonUI.IconButton(
            model.isBookmarked ? Image.huiIcons.bookmarkFill : Image.huiIcons.bookmark,
            isLoading: isBookmarkLoading,
            type: .grayOutline,
            isSmall: false
        ) {
            onBookmarkTap()
        }
    }

    private var enrollButton: some View {
        HorizonUI.PrimaryButton(
            String(localized: "Enroll"),
            type: .darkOutline,
            fillsWidth: true
        ) {
            enrollTap()
        }
        .accessibilityLabel(String(localized: "Enroll in \(model.name)"))
        .accessibilityHint(String(localized: "Double tap to enroll"))
    }
}
#Preview {
    LearningLibraryCardView(
        model: .init(
            id: "1",
            name: "Adipiscing Elit Learning Object Name Here",
            imageURL: URL(string: "https://img.freepik.com/free-photo/abstract-flowing-neon-wave-background_53876-101942.jpg"),
            itemType: .assignment,
            estimatedTime: "XX mins",
            isRecommended: true,
            isCompleted: true,
            isBookmarked: true,
            numberOfUnits: 100
        ),
        isBookmarkLoading: true,
        onBookmarkTap: { },
        enrollTap: { },
        onTapItem: {}
    )
    .padding()
}
