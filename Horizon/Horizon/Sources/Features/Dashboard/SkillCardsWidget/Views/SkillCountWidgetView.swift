//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

struct SkillCountWidgetView: View {
    let viewModel: SkillListWidgetViewModel
    var body: some View {
        VStack {
            switch viewModel.state {
            case .loading:
                SkillCountView(count: 1)
            case .data, .empty:
                SkillCountView(count: viewModel.countSkills)
            case .error:
                EmptyView()
            }
        }
        .isSkeletonLoadActive(viewModel.state == .loading)
        .fixedSize(horizontal: viewModel.countSkills != 0, vertical: false)
    }
}

private struct SkillCountView: View {
    let count: Int
    var body: some View {
        VStack(alignment: .leading, spacing: .huiSpaces.space8) {
            header
            descriptionView
        }
        .padding(.huiSpaces.space24)
        .background(Color.huiColors.surface.pageSecondary)
        .huiCornerRadius(level: .level5)
        .huiElevation(level: .level4)
    }

    private var header: some View {
        HStack {
            Text("Skills", bundle: .horizon)
                .foregroundStyle(Color.huiColors.text.dataPoint)
                .huiTypography(.labelMediumBold)
                .frame(alignment: .leading)
                .skeletonLoadable()
                .accessibilityAddTraits(.isHeader)
            Spacer()

            Image.huiIcons.hub
                .resizable()
                .frame(width: 16, height: 16)
                .foregroundStyle(Color.huiColors.icon.default)
                .padding(.huiSpaces.space8)
                .background {
                    Circle()
                        .fill(Color.huiColors.primitives.green12)
                }
                .accessibilityHidden(true)
                .skeletonLoadable()
        }
    }

    @ViewBuilder
    private var descriptionView: some View {
        if count == 0 {
            Text("This widget will update once data becomes available.", bundle: .horizon)
                .huiTypography(.p2)
                .foregroundStyle(Color.huiColors.text.timestamp)
                .skeletonLoadable()
                .multilineTextAlignment(.leading)
                .frame(alignment: .trailing)
        } else {
            countSkillsView
        }
    }

    private var countSkillsView: some View {
        HStack(spacing: .huiSpaces.space8) {
            Text(count.description)
                .huiTypography(.labelSemibold)
                .foregroundStyle(Color.huiColors.text.body)
                .skeletonLoadable()
            Text("earned", bundle: .horizon)
                .huiTypography(.labelMediumBold)
                .foregroundStyle(Color.huiColors.text.body)
                .skeletonLoadable()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(String.localizedStringWithFormat(String(localized: "%@ Skills earned", bundle: .horizon), count.description)))
    }
}

#if DEBUG
#Preview {
    HStack {
        SkillCountWidgetView(viewModel: .init(interactor: SkillCardsInteractorPreview()))
        SkillCountWidgetView(viewModel: .init(interactor: SkillCardsInteractorPreview()))
    }
}
#endif
