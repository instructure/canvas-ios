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
import SwiftUI

struct CourseCardView: View {
    @Environment(\.viewController) private var controller
    @ScaledMetric private var uiScale: CGFloat = 1

    private let viewModel: CourseCardViewModel
    @StateObject private var offlineModeViewModel = OfflineModeViewModel(interactor: OfflineModeAssembly.make())

    @State private var isShowingOptionsDialog = false

    private var isAvailable: Bool {
        let isAppOnline = !offlineModeViewModel.isOffline
        let isCourseAvailableOffline = viewModel.isAvailableOffline
        return isAppOnline || isCourseAvailableOffline
    }

    init(viewModel: CourseCardViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        cardButton
            .overlay(alignment: .topLeading) {
                kebabButton
                    .padding(8)
                    .contentShape(Rectangle())
                    .offset(x: 2, y: 2)
            }
            .animation(.dashboardWidget, value: viewModel)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(viewModel.a11yLabel)
            .identifier("Dashboard.CourseCard.cardButton")
    }

    // MARK: - Card

    private var cardButton: some View {
        DashboardThumbnailCard(
            thumbnail: {
                thumbnail
            },
            labels: {
                titleLabel
            },
            isAvailable: Binding(get: { isAvailable }, set: { _ in }),
            action: {
                viewModel.didTapCard(from: controller)
            }
        )
    }

    @ViewBuilder
    private var thumbnail: some View {
        let scaledSize = 72 * uiScale.iconScale

        ZStack(alignment: .topLeading) {
            Color(viewModel.courseColor)
                .frame(width: scaledSize, height: scaledSize)
            // disable animated GIFs to avoid creating multiple WebViews
            RemoteImage(viewModel.imageUrl, size: scaledSize, shouldHandleAnimatedGif: false)
                .opacity(viewModel.showColorOverlay ? 0.16 : 1)
                .clipped()
        }
        .overlay(alignment: .bottomLeading) {
            if viewModel.showGrades {
                gradePill
                    .offset(x: 8, y: -8)
            }
        }
    }

    private var titleLabel: some View {
        Text(viewModel.title)
            .font(.semibold16, lineHeight: .fit)
            .foregroundStyle(.textDarkest)
            .multilineTextAlignment(.leading)
    }

    // MARK: - Kebab button

    @ViewBuilder
    private var kebabButton: some View {
        if offlineModeViewModel.isOfflineFeatureEnabled {
            optionsButton
        } else {
            customizeButton
        }
    }

    private var optionsButton: some View {
        PrimaryButton(isAvailable: !$offlineModeViewModel.isOffline) {
            isShowingOptionsDialog.toggle()
        } label: {
            kebabIcon
        }
        .confirmationDialog(Text(verbatim: ""), isPresented: $isShowingOptionsDialog) {
            Button(String(localized: "Manage Offline Content", bundle: .student)) {
                didTapManageOfflineContent()
            }
            .identifier("Dashboard.CourseCard.manageOfflineButton")

            Button(String(localized: "Customize Course", bundle: .student)) {
                didTapCustomize()
            }
            .identifier("Dashboard.CourseCard.customizeButton")
        }
        .accessibilityElement(children: .ignore)
        .accessibilityAction(named: String(localized: "Customize Course", bundle: .student)) {
            didTapCustomize()
        }
        .accessibilityAction(named: String(localized: "Manage Offline Content", bundle: .student)) {
            didTapManageOfflineContent()
        }
        .identifier("Dashboard.CourseCard.optionsButton")
    }

    private func didTapManageOfflineContent() {
        if offlineModeViewModel.isOffline {
            return UIAlertController.showItemNotAvailableInOfflineAlert()
        }

        viewModel.didTapManageOfflineContent(from: controller)
    }

    private func didTapCustomize() {
        if offlineModeViewModel.isOffline {
            return UIAlertController.showItemNotAvailableInOfflineAlert()
        }

        viewModel.didTapCustomize(from: controller)
    }

    private var customizeButton: some View {
        PrimaryButton(isAvailable: !$offlineModeViewModel.isOffline) {
            didTapCustomize()
        } label: {
            kebabIcon
        }
        .accessibilityLabel(String(localized: "Customize Course", bundle: .student))
        .identifier("Dashboard.CourseCard.customizeButton")
    }

    private var kebabIcon: some View {
        ZStack {
            Circle()
                .fill(.backgroundLightest)
                .scaledFrame(size: 24)

            Image.moreSolid
                .scaledIcon(size: 16)
                .foregroundStyle(viewModel.courseColor)
        }
    }

    // MARK: - Grade pill

    @ViewBuilder
    private var gradePill: some View {
        ZStack {
            if let grade = viewModel.grade {
                RoundedRectangle(cornerRadius: 24)
                    .fill(.backgroundLightest)
                    .scaledFrame(height: 24, useIconScale: true)
                Text(grade)
                    .font(.semibold14, lineHeight: .fit)
                    .padding(.horizontal, 4)
            } else {
                Circle()
                    .fill(.backgroundLightest)
                    .scaledFrame(size: 24)

                Image.lockSolid
                    .scaledIcon(size: 16)
            }
        }
        .foregroundStyle(viewModel.courseColor)
        .fixedSize(horizontal: true, vertical: false)
        .identifier("Dashboard.CourseCard.gradePill")
    }
}

// MARK: - Preview

#if DEBUG

extension CourseCardView {
    static let previewData: [CoursesAndGroupsWidgetCourseItem] = [
        .make(id: "1", title: "Introduction to Computer Science", colorString: "#008EE2", grade: "A+"),
        .make(id: "2", title: .loremIpsumLong, colorString: "#E91E63"),
        .make(id: "3", title: "Advanced Mathematics", colorString: "#E91E63")
    ]
}

#Preview {
    PreviewContainer(spacing: 4, horizontalPadding: 16) {
        CourseCardView(viewModel: CourseCardViewModel(
            model: CourseCardView.previewData[0],
            showGrades: true,
            showColorOverlay: true,
            router: PreviewEnvironment().router
        ))

        CourseCardView(viewModel: CourseCardViewModel(
            model: CourseCardView.previewData[1],
            showGrades: true,
            showColorOverlay: true,
            router: PreviewEnvironment().router
        ))

        CourseCardView(viewModel: CourseCardViewModel(
            model: CourseCardView.previewData[2],
            showGrades: false,
            showColorOverlay: true,
            router: PreviewEnvironment().router
        ))
    }
    .background(.backgroundLight)
}

#endif
