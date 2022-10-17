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

public struct InboxView<ViewModel: InboxViewModel>: View {
    @ObservedObject private var model: ViewModel
    @Environment(\.viewController) private var controller

    public init(model: ViewModel) {
        self.model = model
    }

    public var body: some View {
        VStack(spacing: 0) {
            TopBarView(viewModel: model.topBarMenuViewModel, horizontalInset: 16, itemSpacing: 25)
            Divider()
            if case .loading = model.state {
                loadingIndicator
            } else {
                GeometryReader { geometry in
                    List {
                        switch model.state {
                        case .data: messagesList
                        case .empty: panda(geometry: geometry, data: model.emptyState)
                        case .error: panda(geometry: geometry, data: model.errorState)
                        case .loading: SwiftUI.EmptyView()
                        }
                    }.iOS15Refreshable { completion in
                        model.refresh.send(completion)
                    }
                    .listStyle(PlainListStyle())
                }
            }
        }
        .background(Color.backgroundLightest)
        .navigationBarItems(leading: menuButton)
    }

    private var messagesList: some View {
        ForEach(model.messages) { message in
            VStack(spacing: 0) {
                InboxMessageView(model: message)
                Divider()
            }
            .listRowInsets(EdgeInsets())
            .iOS15ListRowSeparator(.hidden)
            .iOS15SwipeActions(allowsFullSwipe: false) {
                Button {
                }
                label: {
                    Text("Delete", bundle: .core)
                }
                .iOS15Tint(.crimson)
            }
        }
    }

    private var loadingIndicator: some View {
        ProgressView()
            .progressViewStyle(.indeterminateCircle())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accentColor(Color(Brand.shared.primary))
            .listRowInsets(EdgeInsets())
            .iOS15ListRowSeparator(.hidden)
    }

    private func panda(geometry: GeometryProxy,
                       data: (scene: PandaScene,
                              title: String,
                              text: String))
    -> some View {
        InteractivePanda(scene: data.scene,
                         title: Text(data.title),
                         subtitle: Text(data.text))
            .frame(width: geometry.size.width,
                   height: geometry.size.height,
                   alignment: .center)
            .listRowInsets(EdgeInsets())
            .iOS15ListRowSeparator(.hidden)
    }

    private var menuButton: some View {
        Button {
            model.menuTapped.send(controller)
        } label: {
            Image.hamburgerSolid
                .foregroundColor(Color(Brand.shared.navTextColor.ensureContrast(against: Brand.shared.navBackground)))
        }
        .frame(width: 44, height: 44).padding(.leading, -6)
        .identifier("inbox.profileButton")
        .accessibility(label: Text("Profile Menu", bundle: .core))
    }
}

#if DEBUG

struct InboxView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            InboxView(model: InboxViewModelPreview(messages: .mock(count: 5)))
                .preferredColorScheme($0)
                .previewLayout(.sizeThatFits)
        }
    }
}

#endif
