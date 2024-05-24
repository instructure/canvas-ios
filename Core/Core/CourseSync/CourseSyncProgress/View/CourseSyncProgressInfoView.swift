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
        VStack(spacing: 0) {
            switch viewModel.state {
            case let .finishedWithError(title, subtitle):
                Text(title)
                    .font(.semibold16)
                    .padding(.bottom, 4)
                Text(subtitle)
                    .font(.regular14)
            case let .downloadStarting(message),
                 let .downloadInProgress(message, _),
                 let .finishedSuccessfully(message, _):
                Text(message)
                    .font(.regular14)
                    .padding(.bottom, 8)
            }

            switch viewModel.state {
            case .finishedWithError:
                SwiftUI.EmptyView()
            case .downloadStarting:
                ProgressView(value: progress)
                    .progressViewStyle(.indeterminateBar(color: progressColor))
            case let .finishedSuccessfully(_, progress),
                 let .downloadInProgress(_, progress):
                ProgressView(value: progress)
                    .progressViewStyle(.determinateBar(color: progressColor))

            }
        }
        .foregroundColor(.textDarkest)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 16)
        .padding(.bottom, 32)
        .padding(.top, 24)
    }

    private var progressColor: Color {
        if case .finishedSuccessfully = viewModel.state {
            return .textSuccess
        } else {
            return .backgroundInfo
        }
    }

    private var progress: Float? {
        switch viewModel.state {
        case let .downloadInProgress(_, progress): return progress
        case .finishedSuccessfully: return 1
        default: return nil
        }
    }
}

#if DEBUG

struct CourseSyncProgressInfoView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            Divider()
            CourseSyncProgressInfoView(viewModel: .init(interactor: CourseSyncProgressInteractorPreview(state: .downloadStarting)))
            Divider()
            CourseSyncProgressInfoView(viewModel: .init(interactor: CourseSyncProgressInteractorPreview(state: .downloadInProgress)))
            Divider()
            CourseSyncProgressInfoView(viewModel: .init(interactor: CourseSyncProgressInteractorPreview(state: .finishedSuccessfully)))
            Divider()
            CourseSyncProgressInfoView(viewModel: .init(interactor: CourseSyncProgressInteractorPreview(state: .finishedWithError)))
            Divider()
            Spacer()
        }
    }
}

#endif
