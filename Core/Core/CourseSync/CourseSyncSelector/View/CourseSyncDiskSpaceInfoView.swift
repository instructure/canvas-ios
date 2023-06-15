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

import SwiftUI

struct CourseSyncDiskSpaceInfoView: View {
    let viewModel: CourseSyncDiskSpaceInfoViewModel

    // TODO: Use real backgroundDarkest color when palette is updated.
    private let backgroundDarkest = UIColor {
        $0.isLightInterface ? .licorice : .white
    }
    private var remainingDiskSpaceColor: UIColor {
        UIColor {
            let alpha = $0.isLightInterface ? 0.24 : 0.36
            return Brand.shared.primary.withAlphaComponent(alpha)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            title
            Spacer().frame(height: 16)
            chart
            Spacer().frame(height: 8)
            legend
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 6)
            .fill(Color.backgroundLightest)
            .overlay(RoundedRectangle(cornerRadius: 6)
                .stroke(Color.borderDark, lineWidth: 1 / UIScreen.main.scale))
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(viewModel.a11yLabel)
    }

    private var title: some View {
        HStack(spacing: 0) {
            Text("Storage", bundle: .core)
                .foregroundColor(.textDarkest)
                .font(.semibold16, lineHeight: .fit)
            Spacer(minLength: 0)
            Text(viewModel.diskUsage)
                .foregroundColor(.textDark)
                .font(.regular14, lineHeight: .fit)
        }
    }

    private var chart: some View {
        GeometryReader { geometry in
            let spacing: CGFloat = 1
            let width = geometry.size.width - 2 * spacing
            HStack(spacing: spacing) {
                Rectangle()
                    .foregroundColor(Color(backgroundDarkest))
                    .frame(width: viewModel.chart.other * width)
                Rectangle()
                    .foregroundColor(Color(Brand.shared.primary))
                    .frame(width: viewModel.chart.app * width)
                Rectangle()
                    .foregroundColor(Color(remainingDiskSpaceColor))
                    .frame(width: viewModel.chart.free * width)
            }
        }
        .frame(height: 12)
        .cornerRadius(2)
    }

    private var legend: some View {
        HStack(spacing: 0) {
            legendItem(label: Text("Other Apps", bundle: .core), color: backgroundDarkest)
            Spacer(minLength: 0)
            legendItem(label: Text(viewModel.appName), color: Brand.shared.primary)
            Spacer(minLength: 0)
            legendItem(label: Text("Remaining", bundle: .core), color: remainingDiskSpaceColor)
        }
    }

    private func legendItem(label: Text, color: UIColor) -> some View {
        HStack(spacing: 6) {
            Circle()
                .frame(width: 8, height: 8)
                .foregroundColor(Color(color))
            label
                .foregroundColor(.textDark)
                .font(.regular14)
        }
    }
}

#if DEBUG

struct CourseSyncDiskSpaceInfoView_Previews: PreviewProvider {
    static var previews: some View {
        CourseSyncDiskSpaceInfoView(viewModel: .init(interactor: DiskSpaceInteractorPreview(), app: .student))
    }
}

#endif
