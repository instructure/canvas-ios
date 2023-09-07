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

struct DownloadsModulesView: View, Navigatable {

    // MARK: - Injected -

    @Environment(\.viewController) var controller
    @Environment(\.presentationMode) private var presentationMode

    // MARK: - Properties -

    @StateObject var viewModel: DownloadsModulesViewModel
    @State private var selection: String?

    private let title: String

    @State private var isExpandedIndexes: [Int] = []

    init(
        entries: [OfflineDownloaderEntry],
        courseDataModel: CourseStorageDataModel,
        title: String,
        onDeleted: ((OfflineDownloaderEntry) -> Void)? = nil,
        onDeletedAll: (() -> Void)? = nil
    ) {
        let viewModel = DownloadsModulesViewModel(
            entries: entries,
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
                    view.introspect(.viewController, on: .iOS(.v13, .v14, .v15, .v16, .v17)) { viewController in
                        DispatchQueue.main.async {
                            viewController.navigationController?.navigationBar.useContextColor(viewModel.color)
                            viewController.navigationController?.navigationBar.prefersLargeTitles = false
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
        ScrollViewNoConnectionBarPadding {
            LazyVStack(
                alignment: .leading,
                spacing: 0
            ) {
                ForEach(Array(viewModel.content.enumerated()), id: \.element.id) { indexSection, section in
                    CustomDisclosureGroup(
                        animation: .easeInOut(duration: 0.2),
                        isExpanded: .constant(isExpandedIndexes.contains(where: {$0 == indexSection})),
                        onClick: {
                            if let index = isExpandedIndexes.firstIndex(where: {$0 == indexSection}) {
                                isExpandedIndexes.remove(at: index)
                            } else {
                                isExpandedIndexes.append(indexSection)
                            }
                        },
                        header: {
                            header(
                                title: section.title,
                                isExpanded: isExpandedIndexes.contains(where: {$0 == indexSection})
                            )
                        }
                    ) {
                        ForEach(
                            Array(section.content.enumerated()),
                            id: \.element.dataModel.id
                        ) { indexRow, entry in
                            VStack(spacing: 0) {
                                cell(indexRow: indexRow, indexSection: indexSection, entry: entry)
                                Divider()
                            }
                        }
                    }
                }
            }

        }.onAppear {
            if viewModel.content.isEmpty {
                return
            }

            isExpandedIndexes = Array((0...(viewModel.content.count - 1)))
        }
    }

    @ViewBuilder
    private func cell(indexRow: Int, indexSection: Int, entry: OfflineDownloaderEntry) -> some View {
        DownloadsContentCellView(
            viewModel: DownloadsModuleCellViewModel(entry: entry),
            color: Color(viewModel.color),
            onTap: {
                destination(entry: entry)
            },
            onDelete: {
                onDelete(section: indexSection, row: indexRow)
            }
        )
    }

    private func header(title: String, isExpanded: Bool) -> some View {
        SwiftUI.Group {
            HStack {
                if isExpanded {
                    Image.miniArrowUpSolid
                        .frame(width: 24, height: 24)
                        .foregroundColor(.textDarkest)
                } else {
                    Image.miniArrowUpSolid
                        .frame(width: 24, height: 24)
                        .rotationEffect(.degrees(180))
                        .foregroundColor(.textDarkest)
                }
                Text(title)
                    .foregroundColor(.textDarkest)
                    .font(.bold20)
                    .padding(.leading, 16)
                Spacer()
            }
            .padding(.top, 32)
            .padding(.bottom, 8)
            Divider()
        }
        .background(Color.backgroundLight)
        .listRowInsets(EdgeInsets())
    }

    private func onDelete(section: Int, row: Int) {
        let cancelAction = AlertAction(NSLocalizedString("Cancel", comment: ""), style: .cancel) { _ in }
        let deleteAction = AlertAction(NSLocalizedString("Delete", comment: ""), style: .destructive) { _ in
            viewModel.delete(section: section, row: row)
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
