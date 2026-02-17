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

import HorizonUI
import SwiftUI

struct LearningLibraryCardView: View {
    // MARK: - Private variables

    @State private var isTooltipVisible = false

    // MARK: - Dependencies

    private let model: LearningLibraryCardModel
    private let width: CGFloat
    private let isBookmarkLoading: Bool
    private let isEnrollLoading: Bool
    private let onBookmarkTap: (() -> Void)
    private let enrollTap: (() -> Void)
    private let onTapItem: (() -> Void)

    // MARK: - Init

    init(
        model: LearningLibraryCardModel,
        width: CGFloat,
        isBookmarkLoading: Bool = false,
        isEnrollLoading: Bool = false,
        onBookmarkTap: @escaping (() -> Void),
        enrollTap: @escaping (() -> Void),
        onTapItem: @escaping (() -> Void)
    ) {
        self.model = model
        self.width = width
        self.isBookmarkLoading = isBookmarkLoading
        self.isEnrollLoading = isEnrollLoading
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
                }
            }
            .buttonStyle(.plain)

            HStack(alignment: .bottom, spacing: .huiSpaces.space8) {
                descriptionView
                Spacer(minLength: .huiSpaces.space8)
                HStack(spacing: .huiSpaces.space8) {
                    if model.isCompleted {
                        completedIcon
                    }
                    bookmarkButton
                }
                .fixedSize()
            }
        }
        .padding(.huiSpaces.space24)
        .background(Color.huiColors.surface.pageSecondary)
        .huiCornerRadius(level: .level5)
        .shadow(
            color: Color.huiColors.primitives.grey125.opacity(0.18),
            radius: 4,
            x: 1,
            y: 2
        )
    }

    private var imageView: some View {
        CourseImageView(
            height: 155,
            width: width,
            url: model.imageURL,
            corners: .all,
            level: .level1_5
        )
    }

    private var titleView: some View {
        Text(model.name)
            .huiTypography(.labelLargeBold)
            .foregroundStyle(Color.huiColors.text.body)
            .frame(maxWidth: .infinity, alignment: .leading)
            .multilineTextAlignment(.leading)
    }

    private var descriptionView: some View {
        HorizonUI.HFlow(spacing: .huiSpaces.space8, lineSpacing: .huiSpaces.space12) {
            itemTypeView
            if let estimatedTime = model.estimatedTime {
                defaultChip(title: String(format: "%@ mins", estimatedTime), icon: Image.huiIcons.schedule)
            }
            if let units = model.numberOfUnits {
                defaultChip(
                    title: String(format: String(localized: "%d units"), units),
                    icon: Image.huiIcons.coursesFormatListBulleted
                )
            }
            if model.isRecommended {
                recommendedView
            }
            if model.isInProgress {
                defaultChip(
                    title: String(localized: "In progress"),
                    icon: Image.huiIcons.trendingUp
                )
            }
            if !model.isEnrolled {
                enrollButton
            }
        }
        .frame(maxWidth: width - (.huiSpaces.space24 * 2), alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)
    }

    private var itemTypeView: some View {
        HorizonUI.StatusChip(
            title: model.itemType.name,
            style: model.itemType.style,
            icon: model.itemType.icon
        )
    }

    private var recommendedView: some View {
        HorizonUI.StatusChip(
            title: String(localized: "Recommended"),
            style: .honey,
            icon: Image.huiIcons.star
        )
    }

    private func defaultChip(title: String, icon: Image) -> some View {
        HorizonUI.StatusChip(
            title: title,
            style: .gray,
            icon: icon
        )
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

    private var completedIcon: some View {
        Button {
            isTooltipVisible.toggle()
        } label: {
            Image.huiIcons.checkCircle
                .foregroundStyle(Color.huiColors.icon.default)
        }
        .huiTooltip(isPresented: $isTooltipVisible, arrowEdge: .bottom, style: .secondary) {
            Text(String(localized: "Completed"))
        }
    }

    private var enrollButton: some View {
        HorizonUI.LoadingButton(
            title: String(localized: "Enroll"),
            type: .darkOutline,
            fillsWidth: true,
            isLoading: isEnrollLoading
        ) {
            enrollTap()
        }
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
        width: 300,
        isBookmarkLoading: true,
        isEnrollLoading: true,
        onBookmarkTap: { },
        enrollTap: { },
        onTapItem: {}
    )
    .padding()
}
