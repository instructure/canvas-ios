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

struct OfflineStorageView: View {
    let viewModel: CourseSyncDiskSpaceInfoViewModel

    var body: some View {
        storageSection
    }

    private var storageSection: some View {
        storageCard
            .padding(.horizontal, .huiSpaces.space24)
            .background(Color.huiColors.surface.pageSecondary)
            .huiCornerRadius(level: .level5, corners: .top)
    }

    private var storageCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Storage", bundle: .horizon)
                    .huiTypography(.h4)
                    .foregroundStyle(HorizonUI.colors.text.title)
                Spacer()
                Text(viewModel.diskUsage)
                    .huiTypography(.p3)
                    .foregroundStyle(HorizonUI.colors.text.dataPoint)
            }
            storageBar
            storageLegend
        }
        .padding(16)
        .background(HorizonUI.colors.surface.cardPrimary)
        .overlay(
            RoundedRectangle(cornerRadius: HorizonUI.CornerRadius.level3.attributes.radius)
                .strokeBorder(HorizonUI.colors.primitives.grey14, lineWidth: 1)
        )
        .huiCornerRadius(level: .level3)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(viewModel.a11yLabel)
    }

    // MARK: - Storage Bar

    private var storageBar: some View {
        GeometryReader { geometry in
            let spacing: CGFloat = 1
            let width = geometry.size.width - 2 * spacing
            HStack(spacing: spacing) {
                HorizonUI.colors.primitives.blue82
                    .frame(width: viewModel.chart.other * width)
                HorizonUI.colors.primitives.blue45
                    .frame(width: viewModel.chart.app * width)
                HorizonUI.colors.primitives.blue12
                    .frame(width: viewModel.chart.free * width)
            }
        }
        .frame(height: 8)
        .clipShape(Capsule())
    }

    // MARK: - Storage Legend

    private var storageLegend: some View {
        HStack(spacing: 10) {
            legendItem(
                color: HorizonUI.colors.primitives.blue82,
                label: String(localized: "Other apps", bundle: .horizon)
            )
            legendItem(
                color: HorizonUI.colors.primitives.blue45,
                label: String(localized: "Canvas Career", bundle: .horizon)
            )
            legendItem(
                color: HorizonUI.colors.primitives.blue12,
                label: String(localized: "Remaining", bundle: .horizon)
            )
        }
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .huiTypography(.p3)
                .foregroundStyle(HorizonUI.colors.text.dataPoint)
        }
    }
}

#if DEBUG
#Preview {
    OfflineStorageView(
        viewModel: CourseSyncDiskSpaceInfoViewModel(
            interactor: DiskSpaceInteractorPreview(),
            app: .student
        )
    )
}
#endif
