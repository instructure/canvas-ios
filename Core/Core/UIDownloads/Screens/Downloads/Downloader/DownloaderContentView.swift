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

struct DownloaderContentView: View {

    enum AlertType {
        case error(String)
        case retryServerError(OfflineDownloaderEntry)
    }
    @State var alertType: AlertType = .error("") {
        didSet {
            isShowAlert = true
        }
    }
    @State var isShowAlert: Bool = false

    @ObservedObject var viewModel: DownloaderViewModel
    var onDelete: ((IndexSet) -> Void)

    var body: some View {
        List {
            HStack {
                HeaderView(title: "Downloading")
                Button(
                    action: {
                        viewModel.pauseResumeAll()
                    },
                    label: {
                        Text(viewModel.isActiveEntriesEmpty ?  "Resume all" : "Pause all")
                    }
                )
                .foregroundColor(.accentColor)
                .padding(.trailing, 16)
            }
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets())
            content
        }
        .listStyle(.inset)
        .listSystemBackgroundColor()
    }

    var content: some View {
        ForEach(
            Array(viewModel.downloadingModules.enumerated()),
            id: \.offset
        ) { _, viewModel in
            DownloadingCellView(
                viewModel: viewModel,
                onRetryServerError: { entry in
                    alertType = .retryServerError(entry)
                }
            )
            .listRowInsets(EdgeInsets())
            .buttonStyle(PlainButtonStyle())
            .padding(.vertical, 5)
            .background(Color.backgroundLightest)
        }.onDelete { indexSet in
            onDelete(indexSet)
        }
        .listRowBackground(Color.backgroundLightest)
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets())
        .onReceive(
            NotificationCenter.default.publisher(
                for: UIApplication.didBecomeActiveNotification
            )
        ) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                viewModel.downloadingModules.forEach {
                    $0.getCurrentEventObject()
                }
            }
        }
        .alert(isPresented: $isShowAlert, content: alert)
    }

    private func alert() -> Alert {
        switch alertType {
        case .error(let text):
            return Alert(
                title: Text(text),
                dismissButton: .cancel()
            )
        case .retryServerError(let entry):
            return Alert(
                title: Text("Something went wrong on the server side. Try again or contact support."),
                primaryButton: .default(Text("Retry")) {
                    viewModel.resumeIfServerError(entry: entry)
                },
                secondaryButton: .cancel())
        }
    }
}
