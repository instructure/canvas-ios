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

struct DownloaderContentView: View {

    @ObservedObject var viewModel: DownloaderViewModel
    var onDelete: ((IndexSet) -> Void)

    var body: some View {
        List {
            Header(title: "Downloading")
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
            DownloadingCellView(viewModel: viewModel)
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
    }
}
