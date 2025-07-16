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

import Core
import SwiftUI
import Combine

struct GradeStatusView: View {
    @StateObject var viewModel: GradeStatusViewModel
    @State private var showMenu = false

    var body: some View {
        VStack(spacing: 0) {
            statusPickerCell
                .identifier("SpeedGrader.statusPicker")
                .zIndex(1)

            if viewModel.isShowingDaysLateSection {
                GradeStatusDaysLateView(viewModel: viewModel)
                    .transition(.asymmetric(
                        insertion: .push(from: .top),
                        removal: .push(from: .bottom)
                    ))
                    .zIndex(0)
                    .identifier("SpeedGrader.DaysLateButton")
            }
        }
        .animation(.smooth, value: viewModel.isShowingDaysLateSection)
    }

    private var statusPickerCell: some View {
        HStack(spacing: InstUI.Styles.Padding.cellAccessoryPadding.rawValue) {
            Text(String(localized: "Status", bundle: .teacher))
                .font(.semibold16, lineHeight: .fit)
                .foregroundColor(Color.textDarkest)
                .frame(maxWidth: .infinity, alignment: .leading)
            // The loading and the data state have different heights, so we use a ZStack to
            // keep both of them on screen ensuring the cell's constant height.
            ZStack(alignment: .trailing) {
                ProgressView()
                    .tint(nil)
                    .opacity(viewModel.isLoading ? 1 : 0)
                statusDropDown
                    .opacity(viewModel.isLoading ? 0 : 1)
            }
            .animation(.none, value: viewModel.isLoading)
        }
        .paddingStyle(set: .standardCell)
        .background(Color.backgroundLightest)
        .accessibilityElement(children: .combine)
        // PickerMenu already has "Pop up button" trait.
        .accessibilityRemoveTraits(.isButton)
    }

    private var statusDropDown: some View {
        InstUI.PickerMenu(
            selectedOption: Binding(
                get: { viewModel.selectedOption },
                set: { newValue in
                    if let value = newValue { viewModel.didSelectGradeStatus.send(value) }
                }
            ),
            allOptions: viewModel.options,
            identifierGroup: "SpeedGrader.GradeStatusMenuItem",
            label: {
                Text(viewModel.shouldHideSelectedOptionTitle ? "" : viewModel.selectedOption.title)
                    .font(.regular14, lineHeight: .fit)
                Image.chevronDown
                    .scaledIcon(size: 24)
            }
        )
        .errorAlert(
            isPresented: $viewModel.isShowingSaveFailedAlert,
            presenting: viewModel.errorAlertViewModel
        )
        .animation(.none, value: viewModel.selectedOption.title)
    }
}

#if DEBUG

#Preview {
    let statuses: [GradeStatus] = [
        .none,
        .excused,
        .late
    ]

    VStack(spacing: 20) {
        GradeStatusView(
            viewModel: .init(
                userId: "",
                submissionId: "",
                attempt: 0,
                interactor: GradeStatusInteractorPreview(gradeStatuses: statuses)
            )
        )
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

#endif
