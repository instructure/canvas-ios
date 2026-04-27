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

struct HOfflineDownloadStatusView: View {
    // MARK: - Private Properties

    @Environment(\.dismiss) private var dismiss
    @State private var isCancelAlertPresented = false

    // MARK: - Dependencies

    @State private var viewModel: HOfflineDownloadStatusViewModel
    private let onShowTabBar: (Bool) -> Void
    // MARK: - Init

    init(
        viewModel: HOfflineDownloadStatusViewModel,
        onShowTabBar: @escaping (Bool) -> Void
    ) {
        self._viewModel = State(wrappedValue: viewModel)
        self.onShowTabBar = onShowTabBar
    }

    var body: some View {
        ZStack {
            Color.huiColors.surface.pagePrimary.edgesIgnoringSafeArea(.all)
            scrollContent
        }
        .toolbar(.hidden)
        .onWillDisappear { onShowTabBar(true) }
        .onWillAppear { onShowTabBar(false) }
        .alert(
            Text("Cancel sync?", bundle: .horizon),
            isPresented: $isCancelAlertPresented
        ) {
            Button(String(localized: "Cancel sync", bundle: .horizon), role: .destructive) {
                viewModel.cancelSync()
                dismiss()
            }
            Button(String(localized: "Keep syncing", bundle: .horizon), role: .cancel) {}
        } message: {
            Text("It will stop offline content sync. You can do it again later.", bundle: .horizon)
        }
    }

    // MARK: - Navigation Bar

    private var navigationBar: some View {
        TitleBar(
            onBack: { _ in dismiss() },
            onClose: nil
        ) {
            Text("Manage offline content", bundle: .horizon)
                .frame(maxWidth: .infinity)
                .huiTypography(.h3)
                .accessibilityAddTraits(.isHeader)
                .foregroundStyle(Color.huiColors.text.title)
        }
        .padding(.bottom, .huiSpaces.space16)
        .padding(.horizontal, .huiSpaces.space24)
        .padding(.top, .huiSpaces.space8)
        .background(Color.huiColors.surface.pagePrimary)
        .accessibilityElement(children: .contain)
    }

    private var scrollContent: some View {
        ScrollView {
            VStack(spacing: .huiSpaces.space24) {
                if viewModel.isError {
                    errorBanner
                } else {
                    progressView
                }
                courseListSection
            }
            .padding(.top, .huiSpaces.space32)
        }
        .background(Color.huiColors.surface.pageSecondary)
        .huiCornerRadius(level: .level5, corners: [.topLeft, .topRight])
        .safeAreaInset(edge: .top, spacing: .zero) { navigationBar }
        .safeAreaInset(edge: .bottom, spacing: .zero) { bottomButton }
    }

    @ViewBuilder
    private var progressView: some View {
        VStack(spacing: .huiSpaces.space8) {
            if viewModel.syncDownloadedSize.isNotEmpty, viewModel.syncTotalSize.isNotEmpty {
                Text(String(format: "Downloading %@ of %@", viewModel.syncDownloadedSize, viewModel.syncTotalSize))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(Color.huiColors.text.dataPoint)
                    .huiTypography(.p3)
            }

            HorizonUI.ProgressBar(
                progress: viewModel.syncProgress,
                    progressColor: Color.huiColors.primitives.blue82,
                    size: .small,
                    numberPosition: .hidden,
                    backgroundColor: Color.huiColors.primitives.blue12
                )
        }
        .accessibilityElement(children: .combine)
        .padding(.horizontal, .huiSpaces.space32)
    }

    private var errorBanner: some View {
        HStack(spacing: .huiSpaces.space12) {
            Image.huiIcons.error
                .foregroundStyle(Color.huiColors.icon.error)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: .huiSpaces.space2) {
                Text("Sync failed", bundle: .horizon)
                    .foregroundStyle(Color.huiColors.icon.error)
                    .huiTypography(.labelMediumBold)
                Text("Some content couldn't be downloaded.", bundle: .horizon)
                    .foregroundStyle(Color.huiColors.text.dataPoint)
                    .huiTypography(.p3)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
        .padding(.huiSpaces.space16)
        .background(Color.huiColors.surface.error.opacity(0.08))
        .huiCornerRadius(level: .level3)
        .padding(.horizontal, .huiSpaces.space24)
    }

    private var courseListSection: some View {
        VStack(spacing: .zero) {
            ForEach(viewModel.courses) { course in
                VStack(spacing: .zero) {
                    courseRow(course)
                    fileRows(course)
                }
            }
        }
        .padding(.bottom, .huiSpaces.space24)
        .background(Color.huiColors.surface.pageSecondary)
    }

    private func courseRow(_ course: OfflineCourseItem) -> some View {
        HStack(spacing: .huiSpaces.space12) {
            VStack(alignment: .leading, spacing: .huiSpaces.space2) {
                Text(course.name)
                    .huiTypography(.p1)
                    .foregroundStyle(Color.huiColors.text.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                if let size = course.size {
                    Text("~\(size)")
                        .huiTypography(.p2)
                        .foregroundStyle(Color.huiColors.text.timestamp)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            downloadStateIcon(course.downloadState)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(rowAccessibilityLabel(name: course.name, size: course.size, state: course.downloadState))
        .padding(.vertical, .huiSpaces.space16)
        .padding(.horizontal, .huiSpaces.space24)
        .frame(maxWidth: .infinity)
        .background(Color.huiColors.surface.pageSecondary)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.huiColors.surface.divider)
                .frame(height: 1)
        }
    }

    private func fileRows(_ course: OfflineCourseItem) -> some View {
        ForEach(course.files.filter(\.isSelected)) { file in
            HStack(spacing: .huiSpaces.space12) {
                VStack(alignment: .leading, spacing: .huiSpaces.space2) {
                    Text(file.name)
                        .huiTypography(.p1)
                        .foregroundStyle(Color.huiColors.text.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                    Text("~\(file.size)")
                        .huiTypography(.p2)
                        .foregroundStyle(Color.huiColors.text.timestamp)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                downloadStateIcon(file.downloadState)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(rowAccessibilityLabel(name: file.name, size: file.size, state: file.downloadState))
            .padding(.vertical, .huiSpaces.space16)
            .padding(.leading, .huiSpaces.space48)
            .padding(.trailing, .huiSpaces.space24)
            .frame(maxWidth: .infinity)
            .background(Color.huiColors.surface.pageSecondary)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(Color.huiColors.surface.divider)
                    .frame(height: 1)
            }
        }
    }

    @ViewBuilder
    private func downloadStateIcon(_ state: OfflineDownloadState) -> some View {
        switch state {
        case .idle:
            EmptyView()
        case .loading, .downloading:
            HorizonUI.Spinner(size: .xSmall, showBackground: true)
                .accessibilityLabel(Text("Downloading", bundle: .horizon))
        case .downloaded:
            HorizonUI.icons.checkCircle
                .foregroundStyle(Color.huiColors.icon.default)
                .accessibilityLabel(Text("Downloaded", bundle: .horizon))
        case .failed:
            HorizonUI.icons.close
                .foregroundStyle(Color.huiColors.icon.error)
                .accessibilityLabel(Text("Failed to download", bundle: .horizon))
        }
    }

    private var bottomButton: some View {
        Group {
            if viewModel.isError {
                HorizonUI.PrimaryButton(
                    String(localized: "Retry", bundle: .horizon),
                    type: .dangerOutline,
                    fillsWidth: true,
                    trailing: Image.huiIcons.restartAlt
                ) {
                    viewModel.retrySync()
                }
            } else {
                HorizonUI.PrimaryButton(
                    String(localized: "Cancel sync", bundle: .horizon),
                    type: .grayOutline,
                    fillsWidth: true,
                    trailing: Image.huiIcons.sync
                ) {
                    isCancelAlertPresented = true
                }
            }
        }
        .padding(.huiSpaces.space24)
        .background(Color.huiColors.surface.pageSecondary)
    }

    // MARK: - Private helpers

    private func rowAccessibilityLabel(name: String, size: String?, state: OfflineDownloadState) -> String {
        var parts = [name]
        if let size { parts.append(size) }
        switch state {
        case .idle: break
        case .loading, .downloading:
            parts.append(String(localized: "Downloading", bundle: .horizon))
        case .downloaded:
            parts.append(String(localized: "Downloaded", bundle: .horizon))
        case .failed:
            parts.append(String(localized: "Failed to download", bundle: .horizon))
        }
        return parts.joined(separator: ", ")
    }
}
