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
import RealmSwift
import SwiftUIIntrospect

struct DownloadsCourseDetailView: View, Navigatable {

    // MARK: - Injected -

    @Environment(\.presentationMode) private var presentationMode

    // MARK: - Properties -

    @StateObject var viewModel: DownloadsCourseDetailViewModel
    @State var isActiveLink: Bool = false

    private let headerViewModel: DownloadsCourseDetailsHeaderViewModel
    @State private var selection: DownloadsCourseCategoryViewModel?

    init(
        courseViewModel: DownloadCourseViewModel,
        categories: [DownloadsCourseCategoryViewModel],
        onDeletedAll: (() -> Void)? = nil
    ) {
        let model = DownloadsCourseDetailViewModel(
            courseViewModel: courseViewModel,
            categories: categories,
            onDeletedAll: onDeletedAll
        )
        self._viewModel = .init(wrappedValue: model)
        self.headerViewModel = DownloadsCourseDetailsHeaderViewModel(
            courseViewModel: courseViewModel
        )
    }

    // MARK: - Views -

    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            padBody
        } else {
            phoneBody
        }
    }

    private var padBody: some View {
        NavigationView {
            content
        }
        .navigationBarBackButtonHidden(true)
        .accentColor(.white)
        .foregroundStyle(.white)
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    selection = nil
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    HStack {
                        Image(systemName: "chevron.backward")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.leading, -8)
                    }
                }
            }
        }
        .onAppear {
            if selection == nil {
                selection = viewModel.categories.first
            }
        }
        .introspect(
            .navigationView(style: .columns),
            on: .iOS(.v13, .v14, .v15, .v16, .v17)
        ) { splitViewController in
            DispatchQueue.main.async {
                splitViewController.preferredDisplayMode = .oneBesideSecondary
                splitViewController.preferredSplitBehavior = .displace
            }
         }
        .introspect(
            .navigationView(style: .stack),
            on: .iOS(.v13, .v14, .v15, .v16, .v17)
        ) { navigationController in
            DispatchQueue.main.async {
                navigationController.navigationBar.prefersLargeTitles = false
                navigationController.navigationBar.useContextColor(viewModel.courseViewModel.color)
            }
        }
    }

    private var phoneBody: some View {
        content
    }

    private var content: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                switch viewModel.state {
                case .loaded, .updated:
                    content(geometry: geometry)
                case .loading, .none:
                    LoadingView()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(viewModel.title)
                        .foregroundColor(.white)
                        .font(.semibold16)
                }
            }
        }
        .onPreferenceChange(ViewBoundsKey.self, perform: headerViewModel.scrollPositionChanged)
        .onAppear {
            navigationController?.navigationBar.useContextColor(viewModel.courseViewModel.color)
        }
        .if(UIDevice.current.userInterfaceIdiom == .pad) { view in
            view.introspect(
                .viewController,
                on: .iOS(.v13, .v14, .v15, .v16, .v17)
            ) { viewController in
                DispatchQueue.main.async {
                    viewController.navigationController?.navigationBar.prefersLargeTitles = false
                    viewController.navigationController?.navigationBar.useContextColor(viewModel.courseViewModel.color)
                }
            }
        }

    }

    @ViewBuilder
    private func content(geometry: GeometryProxy) -> some View {
        ZStack(alignment: .top) {
            Color.backgroundLightest
            imageHeader(geometry: geometry)
            List {
                VStack(spacing: 0) {
                    ForEach(viewModel.categories, id: \.self) { categoryViewModel in
                        DownloadsCourseDetailsCellView(categoryViewModel: categoryViewModel)
                            .background(
                                NavigationLink(
                                    destination: destination(sectionViewModel: categoryViewModel),
                                    tag: categoryViewModel,
                                    selection: $selection
                                ) { SwiftUI.EmptyView() }.hidden()
                            )
                            .onTapGesture {
                                selection = categoryViewModel
                            }
                    }
                }
                .listSystemBackgroundColor()
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .padding(.top, headerViewModel.shouldShowHeader(for: geometry.size.height) ? headerViewModel.height : 0)
                .transformAnchorPreference(key: ViewBoundsKey.self, value: .bounds) { preferences, bounds in
                    preferences = [.init(viewId: 0, bounds: geometry[bounds])]
                }
            }
            .iOS16HideListScrollContentBackground()
            .listStyle(.plain)
        }
    }

    @ViewBuilder
    private func imageHeader(geometry: GeometryProxy) -> some View {
        if headerViewModel.shouldShowHeader(for: geometry.size.height) {
            DownloadsCourseDetailsHeaderView(viewModel: headerViewModel, width: geometry.size.width)
        }
    }

    @ViewBuilder
    private func destination(
        sectionViewModel: DownloadsCourseCategoryViewModel
    ) -> some View {
        if sectionViewModel.contentType == .modules {
            DownloadsModulesView(
                entries: sectionViewModel.content,
                courseDataModel: viewModel.courseViewModel.courseDataModel,
                title: sectionViewModel.title,
                onDeleted: { entry in
                    viewModel.delete(entry: entry, from: sectionViewModel)
                    isEmpty()
                },
                onDeletedAll: {
                    viewModel.delete(sectionViewModel: sectionViewModel)
                    isEmpty()
                }
            )
        } else {
            DownloadsContentView(
                content: sectionViewModel.content,
                courseDataModel: viewModel.courseViewModel.courseDataModel,
                title: sectionViewModel.title,
                onDeleted: { entry in
                    viewModel.delete(entry: entry, from: sectionViewModel)
                    isEmpty()
                },
                onDeletedAll: {
                    viewModel.delete(sectionViewModel: sectionViewModel)
                    isEmpty()
                }
            )
        }
    }

    private func isEmpty() {
        if viewModel.categories.isEmpty {
            presentationMode.wrappedValue.dismiss()
        }
    }
}
