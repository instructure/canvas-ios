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
        VStack(spacing: 0) {
            header
            homeButton
            tabList
        }
        .background(Color.backgroundLightest.edgesIgnoringSafeArea(.all))
        //.navigationBarStyle(.color(viewModel.colors))
        //.navigationTitle(NSLocalizedString("Placeholder", comment: ""), subtitle: viewModel.courseName)
        .navigationBarGenericBackButton()
        .onAppear {
            viewModel.viewDidAppear()
        }
    }

    @ViewBuilder
    private var header: some View {
        Text("Course name, term")
    }

    @ViewBuilder
    private var homeButton: some View {
        Button(action: {}, label: {Text("Home")})
    }

    @ViewBuilder
    private var tabList: some View {
        List {
            ForEach(viewModel.tabs.all, id: \.id) { tab in
                courseDetailCellView(tab)
            }
        }
        .listStyle(.plain)
       /* .iOS15Refreshable { completion in
            viewModel.refresh(completion: completion)
        }*/
    }

    private func courseDetailCellView(_ tab: Tab) -> some View {
        Button(action: {
            if let url = tab.htmlURL {
                env.router.route(to: url, from: controller)
            }
        }, label: {
            HStack(spacing: 13) {
              /*  Image(tab.icon)
                    .frame(width: 20, height: 20)
                    //.foregroundColor(Color(viewModel.courseColor ?? .ash))
                    .padding(.top, 2)
                    .frame(maxHeight: .infinity, alignment: .top)*/
                Text(tab.label)
                Spacer()
                InstDisclosureIndicator()
            }
            .padding(.vertical, 13)
            .padding(.horizontal, 16)
            .fixedSize(horizontal: false, vertical: true)
            .contentShape(Rectangle())
        })
            .buttonStyle(PlainButtonStyle())
            .accessibility(identifier: "assignment-list.assignment-list-row.cell-\(tab.id)")
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

