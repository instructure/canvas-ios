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
        InstUI.PickerMenu(
            selectedOption: Binding(
                get: { viewModel.selectedOption },
                set: { newValue in
                    if let value = newValue { viewModel.didSelectGradeStatus.send(value) }
                }
            ),
            allOptions: viewModel.options,
            label: { cell }
        )
        .errorAlert(
            isPresented: $viewModel.isShowingSaveFailedAlert,
            presenting: viewModel.errorAlertViewModel
        )
    }

    private var cell: some View {
        HStack(spacing: InstUI.Styles.Padding.cellAccessoryPadding.rawValue) {
            Text(String(localized: "Status", bundle: .teacher))
                .font(.semibold16)
                .foregroundColor(Color.textDarkest)
                .frame(maxWidth: .infinity, alignment: .leading)
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
            } else {
                Text(viewModel.selectedOption.title)
                    .font(.regular14)
                    .foregroundColor(Color.textDark)
                Image.chevronDown
                    .scaledIcon(size: 24)
                    .foregroundColor(Color.textDark)
            }
        }
        .frame(minHeight: 52)
        .paddingStyle(.horizontal, .standard)
        .background(Color.backgroundLightest)
        .identifier("SpeedGrader.statusPicker")
    }
}

#if DEBUG

#Preview {
    let statuses = [
        GradeStatus(defaultName: "None"),
        GradeStatus(defaultName: "Graded"),
        GradeStatus(defaultName: "Excused")
    ]

    VStack(spacing: 20) {
        GradeStatusView(
            viewModel: .init(
                customGradeStatusId: nil,
                latePolicyStatus: nil,
                userId: "",
                submissionId: "",
                attempt: 0,
                interactor: GradeStatusInteractorPreview(gradeStatuses: statuses)
            )
        )
    }
}

#endif
