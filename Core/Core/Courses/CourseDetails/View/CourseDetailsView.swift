//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

public struct CourseDetailsView: View, ScreenViewTrackable {

    @Environment(\.appEnvironment) private var env
    @Environment(\.viewController) private var controller
    @ObservedObject private var viewModel: CourseDetailsViewModel
    @ObservedObject private var headerViewModel: CourseDetailsHeaderViewModel
    @ObservedObject private var selectionViewModel: ListSelectionViewModel

    public let screenViewTrackingParameters: ScreenViewTrackingParameters

    public init(viewModel: CourseDetailsViewModel) {
        self.viewModel = viewModel
        self.headerViewModel = viewModel.headerViewModel
        self.selectionViewModel = viewModel.selectionViewModel

        screenViewTrackingParameters = ScreenViewTrackingParameters(
            eventName: "/courses/\(viewModel.courseID)"
        )
    }

    public var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                switch viewModel.state {
                case .empty(let title, let message):
                    imageHeader(geometry: geometry)
                    errorView(title: title, message: message)
                case .loading:
                    imageHeader(geometry: geometry)
                    loadingView
                case .data(let tabViewModels):
                    tabList(tabViewModels, geometry: geometry)
                }
            }
            .background(Color.backgroundLightest.edgesIgnoringSafeArea(.all))
            .navigationBarStyle(.color(viewModel.courseColor))
            .navigationTitle(viewModel.navigationBarTitle, subtitle: nil)
            .navigationBarGenericBackButton()
            .navigationBarItems(trailing: viewModel.showSettings ? settingsButton : nil)
            .onAppear {
                viewModel.viewDidAppear()
                viewModel.splitModeObserver.splitViewController = controller.value.splitViewController
            }
        }
        .onPreferenceChange(ViewBoundsKey.self, perform: headerViewModel.scrollPositionChanged)
        .onReceive(viewModel.$homeRoute, perform: setupDefaultSplitDetailView)
    }

    @ViewBuilder
    private var settingsButton: some View {
        Button {
            if let url = viewModel.settingsRoute {
                env.router.route(to: url, from: controller, options: .modal(.formSheet, isDismissable: false, embedInNav: true))
            }
        } label: {
            Image.settingsLine.foregroundColor(.textLightest)
        }
        .accessibility(label: Text("Edit course settings", bundle: .core))
    }

    @ViewBuilder
    private var homeView: some View {
        Button {
            if let url = viewModel.homeRoute {
                selectionViewModel.cellTapped(at: 0)
                env.router.route(to: url, from: controller, options: .detail)
            }
        } label: {
            HStack(spacing: 13) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(viewModel.homeLabel ?? "")
                        .font(.semibold23)

                    if let subTitle = viewModel.homeSubLabel {
                        Text(subTitle)
                            .font(.semibold14)
                    }
                }
                .foregroundColor(.textDarkest)
                Spacer()
                InstDisclosureIndicator()
            }
            .frame(minHeight: 76)
            .padding(.horizontal, 16)
            .fixedSize(horizontal: false, vertical: true)
            .contentShape(Rectangle())
        }
        .buttonStyle(ContextButton(contextColor: viewModel.courseColor, isHighlighted: selectionViewModel.selectedIndex == 0))
        .accessibility(addTraits: selectionViewModel.selectedIndex == 0 ? .isSelected : [])
        .accessibilityIdentifier("courses-details.home-cell")
    }

    @ViewBuilder
    private func errorView(title: String, message: String) -> some View {
        Spacer()
        SwiftUI.Group {
            Text(title)
                .font(.bold20)
            Text(message)
                .font(.regular16)
        }
        .multilineTextAlignment(.center)
        .foregroundColor(.textDarkest)
        .padding(.horizontal, 16)
        .padding(.vertical, 5)
        Button {
            viewModel.retryAfterError()
        } label: {
            Text("Retry", bundle: .core)
                .padding(.top, 15)
                .foregroundColor(Color(Brand.shared.linkColor))
        }
        Spacer()
    }

    @ViewBuilder
    private var loadingView: some View {
        Spacer()
        ProgressView()
            .progressViewStyle(.indeterminateCircle())
        Spacer()
    }

    private func tabList(_ tabViewModels: [CourseDetailsCellViewModel], geometry: GeometryProxy) -> some View {
        ZStack(alignment: .top) {
            imageHeader(geometry: geometry)
            ListWithoutVerticalScrollIndicator {
                VStack(spacing: 0) {
                    if viewModel.showHome {
                        homeView
                        Divider()
                    }
                    ForEach(tabViewModels, id: \.id) { tabViewModel in
                        CourseDetailsCellView(viewModel: tabViewModel)
                        Divider()
                    }
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .background(Color.backgroundLightest)
                .padding(.top, headerViewModel.shouldShowHeader(for: geometry.size.height) ? headerViewModel.height : 0)
                // Save the frame of the content so we can inspect its y position and move course image based on that
                .transformAnchorPreference(key: ViewBoundsKey.self, value: .bounds) { preferences, bounds in
                    preferences = [.init(viewId: 0, bounds: geometry[bounds])]
                }
            }
            .listStyle(.plain)
            .iOS16HideListScrollContentBackground()
            .refreshable {
                await viewModel.refresh()
            }
        }
    }

    @ViewBuilder
    private func imageHeader(geometry: GeometryProxy) -> some View {
        CourseDetailsHeaderView(viewModel: headerViewModel, width: geometry.size.width)
//        if headerViewModel.shouldShowHeader(for: geometry.size.height) {
//            CourseDetailsHeaderView(viewModel: headerViewModel, width: geometry.size.width)
//        }
    }

    private func setupDefaultSplitDetailView(_ url: URL?) {
        if let defaultViewProvider = controller.value as? DefaultViewProvider, defaultViewProvider.defaultViewRoute != url?.absoluteString {
            defaultViewProvider.defaultViewRoute = url?.absoluteString
        }
    }
}

#if DEBUG

struct CourseDetailsView_Previews: PreviewProvider {
    private static let env = AppEnvironment.shared
    private static let context = env.globalDatabase.viewContext
    private static var contentViewModel: CourseDetailsViewModel {
        let course = Course.save(.make(default_view: .assignments, term: .init(id: "1", name: "Default Term", start_at: nil, end_at: nil)), in: context)
        let tab1: Tab = Tab(context: context)
        tab1.save(.make(), in: context, context: .course("1"))
        let tab2: Tab = Tab(context: context)
        tab2.save(.make(id: "2", label: "Assignments"), in: context, context: .course("1"))

        return CourseDetailsViewModel(state: .data([
            GenericCellViewModel(tab: tab1, course: course, selectedCallback: {}),
            GenericCellViewModel(tab: tab2, course: course, selectedCallback: {}),
        ]))
    }

    static var previews: some View {
        CourseDetailsView(viewModel: contentViewModel)
            .previewLayout(.sizeThatFits)
        CourseDetailsView(viewModel: CourseDetailsViewModel(state: .loading))
            .previewLayout(.sizeThatFits)
        CourseDetailsView(viewModel: CourseDetailsViewModel(state: .empty(title: "Something went wrong", message: "There was an unexpected error. Please try again.")))
            .previewLayout(.sizeThatFits)
    }
}

#endif
