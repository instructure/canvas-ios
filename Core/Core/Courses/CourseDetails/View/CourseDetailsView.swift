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

public struct CourseDetailsView: View {

    @Environment(\.appEnvironment) private var env
    @Environment(\.viewController) private var controller
    @ObservedObject private var viewModel: CourseDetailsViewModel
    @State private var headerImageVerticalOffset: CGFloat = 0
    private let headerHeight: CGFloat = 235

    public init(viewModel: CourseDetailsViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                switch viewModel.state {
                case .empty:
                    headerImage(width: geometry.size.width)
                    errorView
                case .loading:
                    headerImage(width: geometry.size.width)
                    loadingView
                case .data(let tabViewModels):
                    tabList(tabViewModels, geometry: geometry)
                }
            }
            .background(Color.backgroundLightest.edgesIgnoringSafeArea(.all))
            .navigationBarStyle(.color(viewModel.courseColor))
            .navigationTitle(viewModel.courseName, subtitle: nil)
            .navigationBarGenericBackButton()
            .navigationBarItems(trailing: viewModel.showSettings ? settingsButton : nil)
            .onAppear {
                viewModel.viewDidAppear()
            }
        }
        .onPreferenceChange(ViewBoundsKey.self, perform: { value in
            guard let frame = value.first?.bounds else { return }
            headerImageVerticalOffset = min(0, frame.minY / 2)
        })
    }

    @ViewBuilder
    private var settingsButton: some View {
        Button(action: {
            if let url = viewModel.settingsRoute {
                env.router.route(to: url, from: controller, options: .modal(.formSheet, isDismissable: false, embedInNav: true))
            }
        }, label: {
            Image.settingsLine.foregroundColor(.textLightest)
        })
        .accessibility(label: Text("Edit Course settings", bundle: .core))
    }

    @ViewBuilder
    private var homeView: some View {
        Button(action: {
            if let url = viewModel.homeRoute {
                env.router.route(to: url, from: controller)
            }
        }, label: {
            HStack(spacing: 13) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(viewModel.homeLabel ?? "")
                        .font(.semibold23)

                    if let subTitle = viewModel.homeSubLabel {
                        Text(subTitle)
                            .font(.semibold14)
                    }
                }
                .foregroundColor(.licorice)
                Spacer()
                InstDisclosureIndicator()
            }
            .frame(height: 76)
            .padding(.horizontal, 16)
            .fixedSize(horizontal: false, vertical: true)
            .contentShape(Rectangle())
        })
    }

    @ViewBuilder
    private var errorView: some View {
        // TODO
        Text("Something went wrong")
    }

    @ViewBuilder
    private var loadingView: some View {
        Divider()
        Spacer()
        CircleProgress()
        Spacer()
    }

    private func headerImage(width: CGFloat) -> some View {
        // Starts from 0 and reaches 1 when the image is fully pushed out of screen
        let offsetRatio = abs(headerImageVerticalOffset) / (headerHeight / 2)
        let imageOpacity = viewModel.hideColorOverlay ? 1 : (1 - offsetRatio) * 0.4

        return ZStack {
            Color(viewModel.courseColor ?? .ash).frame(width: width, height: headerHeight)
            if let url = viewModel.imageURL {
                RemoteImage(url, width: width, height: headerHeight)
                    .opacity(imageOpacity)
            }
            VStack(spacing: 3) {
                Text(viewModel.courseName)
                    .font(.regular24)
                    .accessibility(identifier: "course-details.title-lbl")
                Text(viewModel.termName)
                    .font(.regular14)
                    .accessibility(identifier: "course-details.subtitle-lbl")
            }
            .padding()
            .multilineTextAlignment(.center)
            .foregroundColor(.textLightest)
            .opacity(1 - offsetRatio)
        }
        .frame(height: headerHeight)
        .clipped()
        .offset(x: 0, y: headerImageVerticalOffset)
    }

    private func tabList(_ tabViewModels: [CourseDetailsCellViewModel], geometry: GeometryProxy) -> some View {
        ZStack(alignment: .top) {
            headerImage(width: geometry.size.width)
            ScrollView {
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
                .background(Color.backgroundLightest)
                .padding(.top, headerHeight)
                // Save the frame of the content so we can inspect its y position and move course image based on that
                .transformAnchorPreference(key: ViewBoundsKey.self, value: .bounds) { preferences, bounds in
                    preferences = [.init(viewId: 0, bounds: geometry[bounds])]
                }
            }
            .iOS15Refreshable { completion in
                viewModel.refresh(completion: completion)
            }
        }
    }
}

struct CourseDetailsView_Previews: PreviewProvider {
    private static let env = AppEnvironment.shared
    private static let context = env.globalDatabase.viewContext

    static var previews: some View {
        let course = Course.save(.make(default_view: .assignments, term: .init(id: "1", name: "Default Term", start_at: nil, end_at: nil)), in: context)
        let tab1: Tab = Tab(context: context)
        tab1.save(.make(), in: context, context: .course("1"))
        let tab2: Tab = Tab(context: context)
        tab2.save(.make(id: "2", label: "Assignments"), in: context, context: .course("1"))

        let viewModel = CourseDetailsViewModel(state: .data([
            CourseDetailsCellViewModel(tab: tab1, course: course, attendanceToolID: "1"),
            CourseDetailsCellViewModel(tab: tab2, course: course, attendanceToolID: "2"),
        ]))
        return CourseDetailsView(viewModel: viewModel)
            .previewLayout(.sizeThatFits)
    }
}
