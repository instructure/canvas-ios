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
    @ObservedObject var viewModel: CourseSyncProgressInfoViewModel

    var body: some View {
        VStack(spacing: viewModel.syncFailure ? 4 : 8) {
            if viewModel.syncFailure {
                Text(viewModel.syncFailureTitle)
                    .font(.semibold16)
                    .foregroundColor(.textDarkest)
                    .padding(.top, 24)
                Text(viewModel.syncFailureSubtitle)
                    .font(.regular14)
                    .foregroundColor(.textDarkest)
                    .padding(.top, 24)
            } else {
                Text(viewModel.progress)
                    .font(.regular14)
                    .foregroundColor(.textDarkest)
                    .padding(.top, 24)

                if viewModel.progressPercentage > 0 {
                    ProgressView(value: viewModel.progressPercentage)
                        .progressViewStyle(
                            .determinateBar(
                                foregroundColor: .backgroundInfo,
                                backgroundColor: .backgroundInfo.opacity(0.24)
                            )
                        )
                        .padding(.bottom, 32)
                } else {
                    ProgressView()
                        .progressViewStyle(
                            .indeterminateBar(
                                foregroundColor: .backgroundInfo,
                                backgroundColor: .backgroundInfo.opacity(0.24)
                            )
                        )
                        .padding(.bottom, 32)
                }
            }
        }.padding(.horizontal, 16)
    }
}

#if DEBUG

struct CourseSyncProgressInfoView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            Divider()
            CourseSyncProgressInfoView(viewModel: .init(interactor: CourseSyncProgressInteractorPreview()))
            Divider()
            Spacer()
        }
    }
}

#endif
