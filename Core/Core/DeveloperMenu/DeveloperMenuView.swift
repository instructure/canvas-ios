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

public struct DeveloperMenuView: View {
    @Environment(\.appEnvironment) var env
    @Environment(\.appEnvironment.router) var router
    @Environment(\.viewController) var controller

    @StateObject private var snackBarViewModel = SnackBarViewModel()

    @State private var items: [DeveloperMenuItem] = []

    public init() {}

    public var body: some View {
        List {
            ForEach(items, id: \.id) { item in
                Button {
                    item.action()
                } label: {
                    HStack {
                        Text(item.title)
                        Spacer()
                        InstDisclosureIndicator()
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .listStyle(.plain)
        .background(Color.backgroundLightest)
        .navigationTitle("🛠 Developer Menu")
        .navBarItems(trailing: {
            Button(action: {
                router.dismiss(controller)
            }, label: {
                Text("Done", bundle: .core).fontWeight(.regular)
            })
        })
        .snackBar(viewModel: snackBarViewModel)
        .onAppear {
            setupItems()
        }
    }

    private func setupItems() {
        unowned let router = router
        unowned let controller = controller
        unowned let env = env
        unowned let snackBarViewModel = snackBarViewModel

        items.append(contentsOf: [
            DeveloperMenuItem("View Experimental Features") {
                router.route(to: "/dev-menu/experimental-features", from: controller)
            },
            DeveloperMenuItem("Website Preview") {
                router.route(to: "/dev-menu/website-preview", from: controller, options: .modal(.fullScreen, embedInNav: true, addDoneButton: true))
            },
            DeveloperMenuItem("Panda Gallery") {
                router.route(to: "/dev-menu/pandas", from: controller)
            },
            DeveloperMenuItem("SnackBar Test") {
                router.route(to: "/dev-menu/snackbar", from: controller, options: .modal(.fullScreen, embedInNav: true, addDoneButton: true))
            },
            DeveloperMenuItem("View Push Notifications") {
                router.route(to: "/push-notifications", from: controller)
            },
            DeveloperMenuItem("View Logs") {
                router.route(to: "/logs", from: controller)
            },
            DeveloperMenuItem("HeapID: \(env.heapID ?? "N/A")\n---\nTap to Copy") {
                UIPasteboard.general.string = env.heapID
                snackBarViewModel.showSnack("HeapID copied to clipboard.\n\(env.heapID ?? "N/A")")
            },
        ])

        #if DEBUG
        items.append(
            DeveloperMenuItem("Access Token: \(env.currentSession?.accessToken ?? "N/A")\n---\nTap to Copy") {
                UIPasteboard.general.string = env.currentSession?.accessToken
                snackBarViewModel.showSnack("Access Token copied to clipboard.\n\(env.currentSession?.accessToken ?? "N/A")")
            }
        )
        #endif
    }

    private struct DeveloperMenuItem: Identifiable {
        public let id: String
        public let title: String
        public let action: () -> Void

        public init(_ title: String, action: @escaping () -> Void) {
            id = title
            self.title = title
            self.action = action
        }
    }
}
