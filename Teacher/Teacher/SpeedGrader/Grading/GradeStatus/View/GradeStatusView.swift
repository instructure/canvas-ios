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
            selectedOption: $viewModel.selectedOption,
            allOptions: viewModel.options,
            label: { cell }
        )
    }

    private var cell: some View {
        HStack {
            Text(String(localized: "Status", bundle: .teacher))
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(Color(red: 0.22, green: 0.27, blue: 0.31))
            Spacer(minLength: 0)
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            } else {
                Text(viewModel.selectedOption?.title ?? "None")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(Color(red: 0.53, green: 0.57, blue: 0.62))
                Image(systemName: "chevron.down")
                    .foregroundColor(Color(red: 0.53, green: 0.57, blue: 0.62))
            }
        }
        .paddingStyle(set: .standardCell)
        .background(Color.backgroundLightest)
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
        GradeStatusView(viewModel: .init(gradeStatuses: statuses, selectedId: nil))
        GradeStatusView(viewModel: .init(gradeStatuses: statuses, selectedId: statuses[1].id))
    }
}

#endif
