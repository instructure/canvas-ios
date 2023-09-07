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
import Combine
import SwiftUI
import mobile_offline_downloader_ios

struct DownloadingCellView: View {

    // MARK: - Properties -

    @ObservedObject var viewModel: DownloadsModuleCellViewModel
    @State private var currentState: DownloadButton.State = .idle

    // MARK: - Views -

    var body: some View {
        VStack(alignment: .leading) {
            content
        }
        .contentShape(Rectangle())
        .background(
            RoundedRectangle(cornerRadius: 4)
                .stroke(
                    Color.gray,
                    lineWidth: 1 / UIScreen.main.scale
                )
        )
        .background(Color.backgroundLightest)
        .cornerRadius(4)
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
        .buttonStyle(PlainButtonStyle())
    }

    private var content: some View {
        HStack {
            Text(viewModel.title)
                .font(.semibold18)
                .foregroundColor(.textDarkest)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(2)
            Spacer()
            DownloadButtonRepresentable(
                progress: .constant(viewModel.progress),
                currentState: $currentState,
                mainTintColor: Brand.shared.linkColor,
                onState: { state in
                    debugLog(state)
                },
                onTap: { _ in
                    viewModel.pauseResume()
                }
            )
            .frame(width: 35, height: 35)
        }
        .padding(.all, 10)
        .onAppear {
            setCurrentState(viewModel.downloaderStatus)
        }
        .onChange(
            of: viewModel.downloaderStatus,
            perform: setCurrentState
        )
    }

    private func setCurrentState(_ newValue: OfflineDownloaderStatus) {
        switch newValue {
        case .initialized, .preparing:
            currentState = .waiting
        case .active:
            currentState = .downloading
        case .paused, .failed:
            currentState = .retry
        default:
            currentState = .retry
        }
    }
}
