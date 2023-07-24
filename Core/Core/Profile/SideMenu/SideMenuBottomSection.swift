//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

struct SideMenuBottomSection: View {
    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller

    @ObservedObject var helpLinks: Store<GetAccountHelpLinks>
    @ObservedObject var permissions: Store<GetContextPermissions>

    var dashboard: UIViewController {
        guard var dashboard = controller.value.presentingViewController else {
            return UIViewController()
        }
        if let tabs = dashboard as? UITabBarController {
            dashboard = tabs.selectedViewController ?? tabs
        }
        if let split = dashboard as? UISplitViewController {
            dashboard = split.masterNavigationController ?? split
        }
        return dashboard
    }

    #if DEBUG
    @State var showDevMenu = true
    #else
    @State var showDevMenu = Self.readDevMenuVisibilityFromUserDefaults()
    #endif

    var canActAsUser: Bool {
        if env.currentSession?.baseURL.host?.hasPrefix("siteadmin.") == true {
            return true
        } else {
            return permissions.first?.becomeUser ?? false
        }
    }

    init(_ enrollment: HelpLinkEnrollment) {
        let env = AppEnvironment.shared
        helpLinks = env.subscribe(GetAccountHelpLinks(for: enrollment))
        permissions = env.subscribe(GetContextPermissions(context: .account("self"), permissions: [.becomeUser]))
    }

    var body: some View {
        VStack(spacing: 0) {
            if showDevMenu {
                SideMenuDeveloperOptionsSection(onDeveloperMenuTap: {
                    route(to: "/dev-menu", options: .modal(embedInNav: true))
                })
                Divider()
            }

            if env.app == .parent {
                Button {
                    self.route(to: "/about", options: .modal(embedInNav: true, addDoneButton: true))
                } label: {
                    SideMenuItem(id: "about", image: .infoLine, title: Text("About", bundle: .core))
                }
                .buttonStyle(ContextButton(contextColor: Brand.shared.primary))
            }

            if let root = helpLinks.first, helpLinks.count > 1 {
                Button {
                    showHelpMenu()
                } label: {
                    SideMenuItem(id: "help", image: .questionLine, title: Text("\(root.text ?? "")", bundle: .core))
                }
                .buttonStyle(ContextButton(contextColor: Brand.shared.primary))
            }

            if canActAsUser {
                Button {
                    self.route(to: "/act-as-user", options: .modal(embedInNav: true))
                } label: {
                    SideMenuItem(id: "actAsUser", image: .userLine, title: Text("Act as User", bundle: .core))
                }
                .buttonStyle(ContextButton(contextColor: Brand.shared.primary))
            }

            if env.currentSession?.isFakeStudent != true {
                Button {
                    guard let delegate = self.env.loginDelegate else { return }
                    env.router.dismiss(controller) {
                        delegate.changeUser()
                    }
                } label: {
                    SideMenuItem(id: "changeUser", image: .userLine, title: Text("Change User", bundle: .core))
                }
                .buttonStyle(ContextButton(contextColor: Brand.shared.primary))
            }

            if env.currentSession?.actAsUserID != nil {
                let isFakeStudent = env.currentSession?.isFakeStudent == true
                let leaveText = Text("Leave Student View", bundle: .core)
                let stopText = Text("Stop Act as User", bundle: .core)
                let logoutTitleText = isFakeStudent ? leaveText : stopText
                Button {
                    stopActing()
                } label: {
                    SideMenuItem(id: "logOut", image: Image("logout", bundle: .core), title: logoutTitleText)
                }
                .buttonStyle(ContextButton(contextColor: Brand.shared.primary))
            } else {
                Button {
                    handleLogout()
                } label: {
                    SideMenuItem(id: "logOut", image: Image("logout", bundle: .core), title: Text("Log Out", bundle: .core))
                }
                .buttonStyle(ContextButton(contextColor: Brand.shared.primary))
            }
        }
        .onAppear {
            helpLinks.refresh()
            permissions.refresh()
        }
        .onReceive(NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification).receive(on: DispatchQueue.main)) { _ in
            showDevMenu = Self.readDevMenuVisibilityFromUserDefaults()
        }
    }

    func handleLogout() {
        UploadManager.shared.isUploading { isUploading in
            guard let session = self.env.currentSession else { return }
            performUIUpdate {
                let logoutBlock = {
                    self.env.router.dismiss(controller) {
                        self.env.loginDelegate?.userDidLogout(session: session)
                    }
                }
                guard isUploading else {
                    logoutBlock()
                    return
                }
                self.showUploadAlert {
                    logoutBlock()
                }
            }
        }
    }

    func stopActing() {
        if let loginDelegate = env.loginDelegate, let session = AppEnvironment.shared.currentSession {
            loginDelegate.stopActing(as: session)
        }
    }

    func route(to: String, options: RouteOptions = .push) {
        let dashboard = self.dashboard
        env.router.dismiss(self.controller) {
            self.env.router.route(to: to, from: dashboard, options: options)
        }
    }

    func showUploadAlert(completionHandler: @escaping () -> Void) {
        let title = NSLocalizedString("Upload in progress", bundle: .core, comment: "")
        let message = NSLocalizedString("One of your submissions is still being uploaded. Logging out might interrupt it.\nAre you sure you want to log out?", bundle: .core, comment: "")
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(AlertAction(NSLocalizedString("Yes", bundle: .core, comment: ""), style: .destructive) { _ in
            completionHandler()
        })
        alert.addAction(AlertAction(NSLocalizedString("Cancel", bundle: .core, comment: ""), style: .cancel))
        env.router.show(alert, from: controller.value, options: .modal())
    }

    public func showHelpMenu() {
        guard let root = helpLinks.first, helpLinks.count > 1 else { return }

        let helpView = HelpView(helpLinks: Array(helpLinks.dropFirst()), tapAction: { helpLink in
            guard let route = helpLink.route else { return }
            self.env.router.dismiss(controller) {
                self.route(to: route.path, options: route.options)
            }
        })
        let helpViewController = CoreHostingController(helpView)
        helpViewController.title = root.text
        env.router.show(helpViewController, from: controller.value, options: .modal(.formSheet, embedInNav: true, addDoneButton: true), analyticsRoute: "/profile/help")
    }

    private static func readDevMenuVisibilityFromUserDefaults() -> Bool {
        UserDefaults.standard.bool(forKey: "showDevMenu")
    }
}

#if DEBUG

struct SideMenuBottomSection_Previews: PreviewProvider {
    static var previews: some View {
        SideMenuBottomSection(.student)
    }
}

#endif
