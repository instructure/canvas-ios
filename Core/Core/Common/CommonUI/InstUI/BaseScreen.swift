//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

public extension InstUI {

    enum ScreenState: Equatable, Hashable {
        case loading
        case error
        case empty
        case data(loadingOverlay: Bool)

        public static let data = Self.data(loadingOverlay: false)
    }

    /**
     This structure encapsulates properties that alter the behavior of the screen.
     Properties were collected in a mind that those won't change and are static to a specific screen.
     */
    struct BaseScreenConfig: Equatable {
        public let refreshable: Bool
        public let showsScrollIndicators: Bool
        public let scrollAxes: Axis.Set
        public let errorPandaConfig: InteractivePanda.Config
        public let emptyPandaConfig: InteractivePanda.Config
        public let loaderBackgroundColor: Color

        /**
         - parameters:
         - refreshable: Controls whether pull-to-refresh is available in the data state. Error and empty states are always refreshable.
         - showsIndicators: Whether to show scroll indicators in the data state.
         - scrollAxes: The scrollable axes in the data state.
         */
        public init(
            refreshable: Bool = true,
            showsScrollIndicators: Bool = true,
            scrollAxes: Axis.Set = .vertical,
            errorPandaConfig: InteractivePanda.Config = .error(),
            emptyPandaConfig: InteractivePanda.Config = .empty(),
            loaderBackgroundColor: Color = .backgroundLightest

        ) {
            self.refreshable = refreshable
            self.showsScrollIndicators = showsScrollIndicators
            self.scrollAxes = scrollAxes
            self.errorPandaConfig = errorPandaConfig
            self.emptyPandaConfig = emptyPandaConfig
            self.loaderBackgroundColor = loaderBackgroundColor
        }
    }

    struct BaseScreen<Content>: View where Content: View {
        public typealias RefreshCompletion = () -> Void
        public static var EmptyRefreshAction: (RefreshCompletion) -> Void {
            { $0() }
        }

        @Environment(\.dynamicTypeSize) private var dynamicTypeSize
        private let state: ScreenState
        private let config: BaseScreenConfig
        private let refreshAction: (@escaping RefreshCompletion) -> Void
        private let content: (GeometryProxy) -> Content

        /**
         - parameters:
         - refreshAction: A block that gets called when the user performs a pull-to-refresh action. The parameter of this block is a completion callback that needs to be called one time on the main thread to finish the refresh animation.
         - content: The view to be rendered in the data state. The block receives a GeometryProxy for convenience that fills the available space. The content is embedded into a scroll view and has a .backgroundLightest background color.
         */
        public init(
            state: ScreenState,
            config: BaseScreenConfig = .init(),
            refreshAction: @escaping (@escaping RefreshCompletion) -> Void = EmptyRefreshAction,
            content: @escaping (GeometryProxy) -> Content
        ) {
            self.state = state
            self.config = config
            self.refreshAction = refreshAction
            self.content = content
        }

        public var body: some View {
            ZStack {
                switch state {
                case .loading:
                    loadingIndicator(showOverlay: false)
                case .error:
                    panda(config: config.errorPandaConfig)
                case .empty:
                    panda(config: config.emptyPandaConfig)
                case .data(let loadingOverlay):
                    if loadingOverlay {
                        data.disabled(true)
                        loadingIndicator(showOverlay: true)
                    } else {
                        data
                    }
                }
            }
            .animation(.default, value: state)
        }

        private func loadingIndicator(showOverlay: Bool) -> some View {
            ProgressView()
                .progressViewStyle(.indeterminateCircle(color: Color(Brand.shared.primary)))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(showOverlay
                    ? Color.backgroundGrouped.opacity(0.5)
                    : config.loaderBackgroundColor
                )
        }

        private func panda(config: InteractivePanda.Config)
        -> some View {
            GeometryReader { geometry in
                RefreshableScrollView(
                    content: {
                        InteractivePanda(config: config)
                            .frame(
                                minWidth: geometry.size.width,
                                minHeight: geometry.size.height,
                                alignment: .center
                            )
                    },
                    refreshAction: refreshAction)
                .background(Color.backgroundLightest)
            }
        }

        private var data: some View {
            GeometryReader { geometry in
                let content = content(geometry)

                if config.refreshable {
                    RefreshableScrollView(
                        config.scrollAxes,
                        showsIndicators: config.showsScrollIndicators,
                        content: {
                            content
                        },
                        refreshAction: refreshAction
                    )
                    .frame(width: geometry.size.width, height: geometry.size.height)
                } else {
                    ScrollView(
                        config.scrollAxes,
                        showsIndicators: config.showsScrollIndicators
                    ) {
                        content
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
            }
            // TODO: Check if it's needed here
//            .background(Color.backgroundLightest)
        }
    }
}

#if DEBUG

#Preview("Loading") {
    InstUI.BaseScreen(state: .loading) { _ in
        Text(verbatim: "Data")
    }
}

#Preview("Error") {
    InstUI.BaseScreen(state: .error) { _ in
        Text(verbatim: "Data")
    }
}

#Preview("Empty") {
    InstUI.BaseScreen(state: .empty) { _ in
        Text(verbatim: "Data")
    }
}

#Preview("Vertical Scrollable Data") {
    InstUI.BaseScreen(state: .data) { _ in
        VStack(alignment: .leading) {
            ForEach(0..<100) { index in
                HStack {
                    Text(verbatim: "Data \(index)")
                    Spacer()
                    Text(verbatim: "Action \(index)")
                }
            }
        }
        .padding()
    }
}

#Preview("Data With Loading Overlay") {
    InstUI.BaseScreen(state: .data(loadingOverlay: true)) { _ in
        VStack(alignment: .leading) {
            ForEach(0..<100) { index in
                HStack {
                    Text(verbatim: "Data \(index)")
                    Spacer()
                    Text(verbatim: "Action \(index)")
                }
            }
        }
        .padding()
    }
}

#Preview("Horizontal Scrollable Data") {
    InstUI.BaseScreen(state: .data, config: .init(scrollAxes: .horizontal)) { _ in
        HStack {
            ForEach(0..<20) { index in
                VStack {
                    Text(verbatim: "Data \(index)")
                    Spacer()
                    Text(verbatim: "Action \(index)")
                }
            }
        }
        .padding()
    }
}

#Preview("Vertical Small Data") {
    InstUI.BaseScreen(state: .data) { _ in
        VStack(alignment: .leading) {
            Text(verbatim: "Data")
        }
        .padding()
    }
}

#Preview("Vertical Small Data Not Refreshable") {
    InstUI.BaseScreen(state: .data, config: .init(refreshable: false)) { _ in
        VStack(alignment: .leading) {
            Text(verbatim: "Non Refreshable Data")
        }
        .padding()
    }
}

#Preview("Geometry Reader") {
    InstUI.BaseScreen(state: .data) { geometry in
        VStack(spacing: 0) {
            Color.red.frame(height: geometry.size.height / 3)
            Color.textLightest.variantForLightMode.frame(height: geometry.size.height / 3)
            Color.green.frame(height: geometry.size.height / 3)
        }
    }
}

private final class ChangingViewModel: ObservableObject {
    @Published var state = InstUI.ScreenState.loading
    private lazy var timer: Timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
        let allStates: [InstUI.ScreenState] = [.loading, .error, .empty, .data, .data(loadingOverlay: true)]
        self?.state = allStates.randomElement()!
    }

    init() {
        _ = timer
    }
}

private struct ChangingView: View {
    @StateObject var viewModel = ChangingViewModel()

    var body: some View {
        InstUI.BaseScreen(state: viewModel.state) { _ in
            Text(verbatim: "Data")
        }
    }
}

#Preview("Transitions") {
    ChangingView()
}

#endif
