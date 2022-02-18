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

    public init(viewModel: CourseDetailsViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                headerImage(width: geometry.size.width)
                switch viewModel.state {
                case .empty:
                    errorView
                case .loading:
                    loadingView
                case .data(let tabViewModels):
                    tabList(tabViewModels)
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
                VStack {
                    Text(viewModel.homeLabel ?? "")
                    Text(viewModel.homeSubLabel ?? "")
                }
                Spacer()
                InstDisclosureIndicator()
            }
            .padding(.vertical, 13)
            .padding(.horizontal, 16)
            .fixedSize(horizontal: false, vertical: true)
            .contentShape(Rectangle())
        })
        .clipShape(Capsule())
        .padding()
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
        let height:CGFloat = 235
        return ZStack {
            Color(viewModel.courseColor ?? .ash).frame(width: width, height: height)
            if let url = viewModel.imageURL {
                RemoteImage(url, width: width, height: height)
                    .opacity(viewModel.hideColorOverlay == true ? 1 : 0.4)
            }
            VStack {
                Text(viewModel.courseName)
                Text(viewModel.termName)
            }
        }
        .frame(height: height)
        .clipped()
    }

    private func tabList(_ tabViewModels: [CourseDetailsCellViewModel]) -> some View {
        List {
            if viewModel.showHome {
                homeView
            }
            ForEach(tabViewModels, id: \.id) { tabViewModel in
                CourseDetailsCellView(viewModel: tabViewModel)
            }
        }
        .listStyle(.plain)
        .iOS15Refreshable { completion in
            viewModel.refresh(completion: completion)
        }
    }
}

#if DEBUG
/*
struct CourseDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = CourseDetailsViewModel()
        CourseDetailsView(viewModel: viewModel)
    }
}
*/
#endif
