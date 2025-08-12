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

import SwiftUI
import HorizonUI

struct LearnView: View {
    @Bindable var viewModel: LearnViewModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: .zero) {
                Text(verbatim: "Program Name Here")
                    .foregroundStyle(Color.huiColors.text.title)
                    .huiTypography(.h3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .padding(.bottom, .huiSpaces.space24)
                progressBar
                    .padding(.bottom, .huiSpaces.space8)
                Text(verbatim: "Learner provider-generated program description At vero eos et accusamus et iusto odio dignissimos ducimus qui blanditis praesentium voluptatum deleniti")
                    .foregroundStyle(Color.huiColors.text.body)
                    .huiTypography(.p1)
                    .padding(.bottom, .huiSpaces.space16)
                pills
                    .padding(.bottom, .huiSpaces.space32)

                ListProgramCards(
                    programs: viewModel.programs,
                    isLinear: true,
                    isLoading: viewModel.isLoadingEnrollButton) { program in
                        viewModel.navigateToProgramDetails(programID: program.id)
                    } onTapEnroll: { program in
                        viewModel.enrollInProgram(programID: program.id)
                    }
            }
            .padding([.horizontal, .bottom], .huiSpaces.space24)
        }
        .toolbar(.hidden)
        .safeAreaInset(edge: .top, spacing: .zero) {
            HStack {
                InstitutionLogo()
                Spacer()
            }
            .padding(.horizontal, .huiSpaces.space24)
            .padding(.top, .huiSpaces.space10)
            .padding(.bottom, .huiSpaces.space4)
            .background(Color.huiColors.surface.pagePrimary)
        }
        .background(Color.huiColors.surface.pagePrimary)
    }

    private var progressBar: some View {
        VStack(spacing: .huiSpaces.space8) {
            Text(verbatim: "Not started")
                .foregroundStyle(Color.huiColors.text.title)
                .huiTypography(.p2)
                .frame(maxWidth: .infinity, alignment: .leading)
            HorizonUI.ProgressBar(
                progress: 0,
                size: .small,
                numberPosition: .hidden,
                backgroundColor: Color.huiColors.surface.pageSecondary
            )
        }
    }

    private var pills: some View {
        HorizonUI.HFlow {
            defaultPill(title: "Program format")
            defaultPill(title: "6 hours 20 minutes")
            HorizonUI.Pill(
                title: "20/10/2025 - 20/10/2027",
                style: .solid(
                    .init(
                        backgroundColor: Color.huiColors.surface.pageSecondary,
                        textColor: Color.huiColors.text.title,
                        iconColor: Color.huiColors.icon.default
                    )
                ),
                isSmall: true,
                icon: .huiIcons.calendarToday
            )
        }
    }

    private func defaultPill(title: String) -> some View {
        HorizonUI.Pill(
            title: title,
            style: .solid(
                .init(
                    backgroundColor: Color.huiColors.surface.pageSecondary,
                    textColor: Color.huiColors.text.title
                )
            ),
            isSmall: true
        )
    }
}

#Preview {
    LearnView(viewModel: .init(interactor: GetLearnCoursesInteractorLive()))
}
