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

struct CourseSyncProgressInfoView: View {

    let viewModel: CourseSyncProgressInfoViewModel

    var body: some View {
        VStack(spacing: 8) {
            Text(viewModel.progress)
                .font(.regular14)
                .foregroundColor(.textDarkest)
                .padding(.top, 24)
            ProgressView(value: viewModel.progressPercentage)
                .tint(.backgroundInfo)
                .foregroundColor(.red)
                .padding(.bottom, 32)
        }.padding(.horizontal, 16)
    }
}

struct CourseSyncProgressInfoView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            Divider()
            CourseSyncProgressInfoView(viewModel: .init(interactor: CourseSyncProgressInfoInteractorPreview()))
            Divider()
            Spacer()
        }
    }
}
