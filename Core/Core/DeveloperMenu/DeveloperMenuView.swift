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
        ScrollView {
            VStack(spacing: 0) {
                ForEach(items) { item in
                    Button {
                        item.action()
                    } label: {
                        HStack(spacing: 0) {
                            Text(item.title)
                                .font(.semibold16)
                                .foregroundColor(.textDarkest)
                            Spacer(minLength: 8)

                            switch item.icon {
                            case .disclosure:
                                InstDisclosureIndicator()
                            case .toClipboard:
                                Image(systemName: "doc.on.clipboard")
                                    .frame(width: 20, height: 20)
                            }
                        }
                        .padding(16)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(ContextButton(contextColor: Brand.shared.primary))
                    Divider()
                }
            }
        }
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
        guard items.isEmpty else { return }
        unowned let router = router
        unowned let controller = controller
        unowned let env = env
        unowned let snackBarViewModel = snackBarViewModel
        let appDir: String = {
            FileManager
                .default
                .urls(for: .documentDirectory,
                      in: .userDomainMask)
                .first!
                .deletingLastPathComponent()
                .absoluteString
        }()
        let sharedDirectory: String? = {
            guard let appGroup = Bundle.main.appGroupID() else { return nil }
            return URL
                .Directories
                .sharedContainer(appGroup: appGroup)?
                .absoluteString
        }()

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
            DeveloperMenuItem("HeapID\n\(env.heapID ?? "N/A")", icon: .toClipboard) {
                UIPasteboard.general.string = env.heapID
                snackBarViewModel.showSnack("HeapID copied to clipboard.")
            },
            DeveloperMenuItem("App Directory\n\(appDir)", icon: .toClipboard) {
                UIPasteboard.general.string = appDir
                snackBarViewModel.showSnack("App Directory copied to clipboard.")
            },
        ])

        if let sharedDirectory {
            items.append(DeveloperMenuItem("Shared Container Directory\n\(sharedDirectory)",
                                           icon: .toClipboard) {
                UIPasteboard.general.string = sharedDirectory
                snackBarViewModel.showSnack("Shared Container Directory copied to clipboard.")
            })
        }

        #if DEBUG
        items.append(
            DeveloperMenuItem("Access Token\n\(env.currentSession?.accessToken ?? "N/A")", icon: .toClipboard) {
                UIPasteboard.general.string = env.currentSession?.accessToken
                snackBarViewModel.showSnack("Access Token copied to clipboard.")
            }
        )
        #endif
    }

    private struct DeveloperMenuItem: Identifiable {
        public enum Icon {
            case disclosure
            case toClipboard
        }
        public let id: String
        public let title: String
        public let icon: Icon
        public let action: () -> Void

        public init(_ title: String, icon: Icon = .disclosure, action: @escaping () -> Void) {
            id = title
            self.title = title
            self.icon = icon
            self.action = action
        }
    }
}
