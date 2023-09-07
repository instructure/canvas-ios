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

struct DownloadCoursesSectionView: View {

    // MARK: - Injected -

    @Environment(\.viewController) var controller

    // MARK: - Properties -

    @ObservedObject var viewModel: DownloadsViewModel
    @State private var selection: DownloadCourseViewModel?

    // MARK: - Views -

    var body: some View {
        ForEach(viewModel.courseViewModels, id: \.self) { courseViewModel in
            DownloadCourseCellView(courseViewModel: courseViewModel)
                .background(
                    NavigationLink(
                        destination: DownloadsCourseDetailView(
                            courseViewModel: courseViewModel,
                            categories: viewModel.categories(courseId: courseViewModel.courseId),
                            onDeletedAll: {
                                viewModel.delete(courseViewModel: courseViewModel)
                            }
                        ),
                        tag: courseViewModel,
                        selection: $selection
                    ) { SwiftUI.EmptyView() }.hidden()
                )
                .listRowInsets(EdgeInsets())
                .buttonStyle(PlainButtonStyle())
                .onTapGesture {
                    selection = courseViewModel
                }
        }
        .onDelete(perform: onDelete)
    }

    private func onDelete(indexSet: IndexSet) {
        let cancelAction = AlertAction(NSLocalizedString("Cancel", comment: ""), style: .cancel) { _ in
            viewModel.state = .updated
        }
        let deleteAction = AlertAction(NSLocalizedString("Delete", comment: ""), style: .destructive) { _ in
            viewModel.swipeDelete(indexSet: indexSet)
        }
        controller.value.showAlert(
            title: NSLocalizedString("Are you sure you want to remove downloaded course?", comment: ""),
            actions: [cancelAction, deleteAction],
            style: UIDevice.current.userInterfaceIdiom == .pad ? .alert : .actionSheet
        )
    }

}
