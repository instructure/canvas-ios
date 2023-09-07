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

struct DownloaderView: View, Navigatable {

    // MARK: - Injected -

    @Environment(\.viewController) var controller: WeakViewController
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    // MARK: - Properties -

    @StateObject var viewModel: DownloaderViewModel
    @State var isDisplayingAlert: Bool = false
    var didDeleteAll: (() -> Void)?

    init(
        downloadingModules: [DownloadsModuleCellViewModel],
        didDeleteAll: (() -> Void)? = nil
    ) {
        let viewModel: DownloaderViewModel = .init(downloadingModules: downloadingModules)
        self._viewModel = .init(wrappedValue: viewModel)
        self.didDeleteAll = didDeleteAll
    }

    // MARK: - Views -

    var body: some View {
        ZStack {
            Color.backgroundLight
                .ignoresSafeArea()
            content
            if viewModel.deleting {
                LoadingDarkView()
            }
        }
    }

    private var content: some View {
        VStack {
            DownloaderContentView(viewModel: viewModel) { indexSet in
                viewModel.delete(indexSet: indexSet)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Downloading")
                    .foregroundColor(.white)
                    .font(.semibold16)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                deleteAllButton
            }
        }
        .onChange(of: viewModel.error) { newValue in
            if newValue.isEmpty { return }
            navigationController?.showAlert(
                title: NSLocalizedString(newValue, comment: ""),
                actions: [AlertAction(NSLocalizedString("Cancel", comment: ""), style: .cancel) { _ in }],
                style: UIDevice.current.userInterfaceIdiom == .pad ? .alert : .actionSheet
            )
            viewModel.error = ""
        }
        .onChange(of: viewModel.isConnected) { isConnected in
            if !isConnected {
                presentationMode.wrappedValue.dismiss()
            }
        }
        .onChange(of: viewModel.isEmpty) { isEmpty in
            if isEmpty {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }

    private var deleteAllButton: some View {
        Button("Delete all") {
            let cancelAction = AlertAction(NSLocalizedString("Cancel", comment: ""), style: .cancel) { _ in }
            let deleteAction = AlertAction(NSLocalizedString("Delete", comment: ""), style: .destructive) { _ in
                viewModel.deleteAll()
                guard viewModel.error.isEmpty else { return }
                didDeleteAll?()
            }
            navigationController?.showAlert(
                title: NSLocalizedString("Are you sure you want to remove all downloading content?", comment: ""),
                actions: [cancelAction, deleteAction],
                style: UIDevice.current.userInterfaceIdiom == .pad ? .alert : .actionSheet
            )
        }
        .foregroundColor(.white)
    }
}
