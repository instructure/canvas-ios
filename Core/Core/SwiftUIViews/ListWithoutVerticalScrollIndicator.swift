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
import Combine

public struct ListWithoutVerticalScrollIndicator<Content: View>: View {
    private let scrollIndicatorWidth: CGFloat = 6
    private let content: () -> Content

    public init(content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        List {
            content()
                .padding(.horizontal, scrollIndicatorWidth)
        }
        .padding(.horizontal, -scrollIndicatorWidth)
        .safeAreaInset(edge: .bottom) {
            Color.clear
                .frame(height: 60)
        }
    }
}

final class NoConnectionViewModel: ObservableObject, Reachabilitable {

    @Injected(\.reachability) var reachability: ReachabilityProvider
    var cancellables: [AnyCancellable] = []

    @Published var isConnected: Bool = false

    init() {
        isConnected = reachability.isConnected
        connection { [weak self] isConnected in
            self?.isConnected = isConnected
        }
    }
}

public struct ListNoConnectionBarPadding<Content: View>: View {

    @StateObject private var viewModel: NoConnectionViewModel = .init()
    private let content: () -> Content

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        List {
            content()
        }
        .padding(.bottom, viewModel.isConnected ? 0 : 20)
    }
}

public struct ScrollViewNoConnectionBarPadding<Content: View>: View {

    @StateObject private var viewModel: NoConnectionViewModel = .init()
    private let content: () -> Content

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        ScrollView {
            content()
        }
        .padding(.bottom, viewModel.isConnected ? 0 : 20)
    }
}
