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
import mobile_offline_downloader_ios

struct DownloadsContentView: View, Navigatable {

    // MARK: - Injected -

    @Environment(\.viewController) var controller
    @Environment(\.presentationMode) private var presentationMode

    // MARK: - Properties -

    @StateObject var viewModel: DownloadsContentViewModel
    @State private var selection: String?

    private let title: String

    init(
        content: [OfflineDownloaderEntry],
        courseDataModel: CourseStorageDataModel,
        title: String,
        onDeleted: ((OfflineDownloaderEntry) -> Void)? = nil,
        onDeletedAll: (() -> Void)? = nil
    ) {
        let viewModel = DownloadsContentViewModel(
            content: content,
            courseDataModel: courseDataModel,
            onDeleted: onDeleted,
            onDeletedAll: onDeletedAll
        )
        self._viewModel = .init(wrappedValue: viewModel)
        self.title = title
    }

    // MARK: - Views -

    var body: some View {
        ZStack {
            Color.backgroundLight
                .ignoresSafeArea()
            content
                .if(UIDevice.current.userInterfaceIdiom == .pad) { view in
                    view.introspect(.viewController, on: .iOS(.v13, .v14, .v15, .v16, .v17)) { view in
                        DispatchQueue.main.async {
                            view.navigationController?.navigationBar.useContextColor(viewModel.color)
                            view.navigationController?.navigationBar.prefersLargeTitles = false
                        }
                    }
                }
            if viewModel.deleting {
                LoadingDarkView()
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(title)
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
    }

    private var content: some View {
        DownloadsContentList {
            ForEach(Array(viewModel.content.enumerated()), id: \.element.dataModel.id) { indexRow, entry in
                VStack(spacing: 0) {
                    DownloadsContentCellView(
                        viewModel: DownloadsModuleCellViewModel(entry: entry),
                        color: Color(viewModel.color),
                        onTap: {
                            destination(entry: entry)
                        },
                        onDelete: {
                            onDelete(index: indexRow)
                        }
                    )
                    Divider()
                }
            }
        }
    }

    private func onDelete(index: Int) {
        let cancelAction = AlertAction(NSLocalizedString("Cancel", comment: ""), style: .cancel) { _ in }
        let deleteAction = AlertAction(NSLocalizedString("Delete", comment: ""), style: .destructive) { _ in
            viewModel.delete(index: index)
            if viewModel.content.isEmpty {
                presentationMode.wrappedValue.dismiss()
            }
        }
        navigationController?.showAlert(
            title: NSLocalizedString("Are you sure you want to remove content?", comment: ""),
            actions: [cancelAction, deleteAction],
            style: UIDevice.current.userInterfaceIdiom == .pad ? .alert : .actionSheet
        )
    }

    private var deleteAllButton: some View {
        Button("Delete all") {
            let cancelAction = AlertAction(NSLocalizedString("Cancel", comment: ""), style: .cancel) { _ in }
            let deleteAction = AlertAction(NSLocalizedString("Delete", comment: ""), style: .destructive) { _ in
                viewModel.deleteAll()
                presentationMode.wrappedValue.dismiss()
            }
            navigationController?.showAlert(
                title: NSLocalizedString("Are you sure you want to remove content?", comment: ""),
                actions: [cancelAction, deleteAction],
                style: UIDevice.current.userInterfaceIdiom == .pad ? .alert : .actionSheet
            )
        }
        .foregroundColor(.white)
    }

    private func destination(entry: OfflineDownloaderEntry) {
        navigationController?.pushViewController(
            CoreHostingController(
                ContentViewerView(
                    entry: entry,
                    courseDataModel: viewModel.courseDataModel,
                    onDeleted: viewModel.delete
                )
            ),
            animated: true
        )
    }
}
