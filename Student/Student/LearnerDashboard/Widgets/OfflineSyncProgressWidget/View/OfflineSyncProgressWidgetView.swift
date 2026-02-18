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

struct OfflineSyncProgressWidgetView: View {
    @State var model: OfflineSyncProgressWidgetViewModel
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        if model.state != .empty {
            DashboardWidgetCard(backgroundColor: model.backgroundColor) {
                HStack(alignment: .top, spacing: 8) {
                    if model.state == .error {
                        Image.warningLine
                            .scaledIcon(size: 20)
                            .accessibilityHidden(true)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        title
                        subtitle

                        if model.state == .data {
                            progress
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityElement(children: .combine)

                    Button(action: model.dismiss) {
                        Image.xLine
                            .scaledIcon(size: 24)
                    }
                    .accessibilityLabel(.init(localized: "Dismiss", bundle: .student))
                }
                .paddingStyle(set: .standardCell)
                .foregroundStyle(.textLightest)
            }
        }
    }

    @ViewBuilder
    private var progress: some View {
        ProgressView(value: model.progress)
            .paddingStyle(.vertical, .textVertical)
            .padding(.trailing, 48)
            .progressViewStyle(.determinateBorderedBar(color: .textLightest))
    }

    @ViewBuilder
    private var title: some View {
        if let title = model.title {
            Text(title)
                .font(.semibold16, lineHeight: .fit)
        }
    }

    @ViewBuilder
    private var subtitle: some View {
        if let subtitleText = model.subtitleText {
            Text(subtitleText)
                .font(.regular14, lineHeight: .fit)
        }
    }
}

#if DEBUG

#Preview("Syncing") {
    OfflineSyncProgressWidgetView(
        model: OfflineSyncProgressWidgetViewModel(
            config: .init(id: .offlineSyncProgress, order: 1, isVisible: true),
            dashboardViewModel: DashboardOfflineSyncProgressCardViewModel(
                progressObserverInteractor: DashboardOfflineSyncInteractorPreview(),
                progressWriterInteractor: DashboardOfflineSyncProgressWriterInteractorPreview(),
                offlineModeInteractor: OfflineModeInteractorMock(),
                router: AppEnvironment.shared.router
            )
        )
    )
    .padding()
}

#endif
