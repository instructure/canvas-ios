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

public struct SideMenu: View {
    
    @Environment(\.appEnvironment) var env
    @ObservedObject var profile: Store<GetUserProfile>
    
    @State var versionText = ""
    
    let enrollment: HelpLinkEnrollment
    #if DEBUG
    @State var showDevMenu = true
    #else
    @State var showDevMenu = UserDefaults.standard.bool(forKey: "showDevMenu")
    #endif
    
    public init(_ enrollment: HelpLinkEnrollment) {
        self.enrollment = enrollment
        let env = AppEnvironment.shared
        profile = env.subscribe(GetUserProfile(userID: "self"))
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                profileHeader()
                Divider()
                MainSection(enrollment)
                Divider()
                OptionsSection(enrollment)
                Divider()
                BottomSection(enrollment)
                Spacer()
                FooterView(title: versionText)
            }.padding(0)
        }
    }
    
    @ViewBuilder
    func profileHeader() -> some View {
        let profile = self.profile.first
        let userName = profile?.name ?? env.currentSession?.userName
        
        HeaderView(avatarURL: profile?.avatarURL,
                   initials: userName ?? "",
                   name: userName.flatMap { User.displayName($0, pronouns: profile?.pronouns) } ?? "",
                   email: profile?.email ?? "")
    }
}

private struct MainSection: View {
    
    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller
    
    @State var unreadCount: UInt = 0
    @State var canUpdateAvatar: Bool = false
    
    let enrollment: HelpLinkEnrollment
    var tools: Store<GetGlobalNavExternalPlacements>
    var dashboard: UIViewController {
        guard var dashboard = controller.value.presentingViewController else {
            return UIViewController()
        }
        if let tabs = dashboard as? UITabBarController {
            dashboard = tabs.selectedViewController ?? tabs
        }
        if let split = dashboard as? UISplitViewController {
            dashboard = split.viewControllers.first ?? split
        }
        
        return dashboard
    }
    
    init(_ enrollment: HelpLinkEnrollment) {
        self.enrollment = enrollment
        let env = AppEnvironment.shared
        self.tools = env.subscribe(GetGlobalNavExternalPlacements())
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if enrollment == .observer {
                MenuItem(image: .emailLine, title: "Inbox", badgeValue: unreadCount).onAppear {
                    env.api.makeRequest(GetConversationsUnreadCountRequest()) { (response, _, _) in
                        self.unreadCount = response?.unread_count ?? 0
                    }
                }
                
                MenuItem(image: .groupLine, title: "Manage Students").onTapGesture {
                    route(to: "/profile/observees")
                }
            } else {
                MenuItem(image: .folderLine, title: "Files").onTapGesture {
                    route(to: "/users/self/files")
                }
                
                ForEach(Array(tools), id: \.self) { tool in
                    MenuItem(image: imageForDomain(tool.domain),
                             title: tool.title).onTapGesture {
                                launchLTI(url: tool.url)
                             }
                }
            }
            
            if enrollment == .student || enrollment == .teacher {
                MenuItem(image: Image("settings", bundle: .core),
                         title: "Settings", badgeValue: 0).onTapGesture {
                            self.route(to: "/profile/settings", options: .modal(.formSheet, embedInNav: true, addDoneButton: true))
                         }
            }
        }
    }
    
    func imageForDomain(_ domain: String?) -> Image {
        var image = Image.ltiLine
        guard let domain = domain else {
            return image
        }
        if domain == "arc.instructure.com" {
            image = Image("studio", bundle: .core)
        }
        return image
    }
    
    func route(to: String, options: RouteOptions = .push) {
        let dashboard = self.dashboard
        env.router.dismiss(controller) {
            self.env.router.route(to: to, from: dashboard, options: options)
        }
    }
    
    func launchLTI(url: URL?) {
        guard let url = url else { return }
        let dashboard = self.dashboard
        env.router.dismiss(controller) {
            LTITools(url: url).presentTool(from: dashboard, animated: true)
        }
    }
}

private struct OptionsSection: View {
    
    @Environment(\.appEnvironment) var env
    @State var showGrades = false
    @ObservedObject var settings: Store<GetUserSettings>
    
    let enrollment: HelpLinkEnrollment
    
    init(_ enrollment: HelpLinkEnrollment) {
        self.enrollment = enrollment
        let env = AppEnvironment.shared
        settings = env.subscribe(GetUserSettings(userID: "self"))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            SubHeaderView(title: "Options")
            if enrollment == .student {
                let showGrades = env.userDefaults?.showGradesOnDashboard == true
                ToggleItem(image: .gradebookLine, title: "Show Grades", isOn: showGrades) {
                    env.userDefaults?.showGradesOnDashboard = $0
                }
            }
            
            if enrollment == .student || enrollment == .teacher {
                let colorOverlay = settings.first?.hideDashcardColorOverlays != true
                ToggleItem(image: .coursesLine, title: "Color Overlay", isOn: colorOverlay) {
                    UpdateUserSettings(hide_dashcard_color_overlays: !$0).fetch()
                }
            }
        }
    }
}

private struct BottomSection: View {
    
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
            dashboard = split.viewControllers.first ?? split
        }
        return dashboard
    }
    
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
            
            if let root = helpLinks.first, helpLinks.count > 1 {
                MenuItem(image: Image("question", bundle: .core), title: root.text, badgeValue: 0).onTapGesture {
                    showHelpMenu()
                }
            }
            
            if canActAsUser {
                MenuItem(image: Image("user", bundle: .core), title: "Act as User", badgeValue: 0).onTapGesture {
                    self.route(to: "/act-as-user", options: .modal(embedInNav: true))
                }
            }
            
            if env.currentSession?.isFakeStudent != true {
                MenuItem(image: Image("user", bundle: .core), title: "Change User", badgeValue: 0).onTapGesture {
                    guard let delegate = self.env.loginDelegate else { return }
                    env.router.dismiss(controller) {
                        delegate.changeUser()
                    }
                }
            }
            
            if env.currentSession?.actAsUserID != nil {
                let logoutTitle = env.currentSession?.isFakeStudent == true ? "Leave Student View" : "Stop Act as User"
                MenuItem(image: Image("logout", bundle: .core), title: logoutTitle, badgeValue: 0)
            } else {
                MenuItem(image: Image("logout", bundle: .core), title: "Log Out", badgeValue: 0).onTapGesture {
                    handleLogout()
                }
            }
        }
    }
    
    func handleLogout() {
        UploadManager.shared.isUploading { isUploading in
            guard let session = self.env.currentSession else { return }
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
        env.router.show(alert, from: controller, options: .modal())
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
        env.router.show(helpViewController, from: controller, options: .modal(.formSheet, embedInNav: true, addDoneButton: true))
    }
}

private struct FooterView: View {
    
    var title: String
    
    var body: some View {
        HStack {
            Text(title).padding(.leading, 10).font(.regular14).foregroundColor(.ash)
            Spacer()
        }.padding().frame(height: 30)
    }
}

private struct HeaderView: View {
    
    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller
    
    @State var avatarURL: URL?
    var initials: String
    var name: String
    var email: String
    @State var canUpdateAvatar: Bool = false
    @State var isShowingActionSheet = false
    
    @ObservedObject var viewModel = ImagePickerViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
            Avatar(name: initials, url: avatarURL, size: 72)
                .padding(.bottom, 12).onTapGesture {
                    if canUpdateAvatar {
                        isShowingActionSheet = true
                    }
                }
                .actionSheet(isPresented: $isShowingActionSheet) {
                    ActionSheet(title: Text("Choose Profile Picture", bundle: .core), buttons: [
                                    .default(Text("Take Photo", bundle: .core)) {
                                        viewModel.takePhoto()
                                    },
                                    .default(Text("Choose Photo", bundle: .core)) {
                                        viewModel.choosePhoto()
                                    },
                                    .cancel(Text("Cancel", bundle: .core)) {
                                        isShowingActionSheet = false
                                    }])
                }
            Text(name)
                .font(.bold20)
                .padding(.bottom, 2)
            Text(email)
                .font(.regular14)
                .foregroundColor(.ash)
        }.padding(20).frame(height: 185).onAppear {
            env.api.makeRequest(GetUserRequest(userID: "self")) {user, _, _ in
                canUpdateAvatar = user?.permissions?.can_update_avatar == false
            }
        }
        .sheet(isPresented: $viewModel.isPresentingImagePicker) {
            ImagePicker(sourceType: viewModel.sourceType) { image in
                viewModel.isPresentingImagePicker = false
                guard let image = image else { return }
                do {
                    UploadAvatar(url: try image.write(nameIt: "profile")).fetch { result in performUIUpdate {
                        switch result {
                        case .success(let url):
                            avatarURL = url
                        case .failure(let error):
                            showError(error)
                        }
                    }}
                } catch {
                    showError(error)
                }
            }
        }
    }
    
    public func showError(_ error: Error) {
        let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(AlertAction(NSLocalizedString("Dismiss", bundle: .core, comment: ""), style: .default))
        env.router.show(alert, from: controller, options: .modal())
    }
}

extension HeaderView {
    final class ImagePickerViewModel: ObservableObject {
        @Published var selectedImage: UIImage?
        @Published var isPresentingImagePicker = false
        private(set) var sourceType: ImagePicker.SourceType = .camera
        
        func choosePhoto() {
            sourceType = .photoLibrary
            isPresentingImagePicker = true
        }
        
        func takePhoto() {
            sourceType = .camera
            isPresentingImagePicker = true
        }
    }
}

private struct SubHeaderView: View {
    
    var title: String
    
    var body: some View {
        HStack {
            Text(LocalizedStringKey(title.uppercased()), bundle: .core)
                .font(.regular12)
                .foregroundColor(.ash)
            Spacer()
        }.padding(26).frame(height: 30)
    }
}

private struct MenuItem: View {
    
    var image: Image
    var title: String
    @State var badgeValue: UInt = 0
    
    var body: some View {
        HStack(spacing: 20) {
            image
            Text(LocalizedStringKey(title), bundle: .core)
                .font(.regular16)
            Spacer()
            
            if badgeValue > 0 {
                Badge(value: badgeValue)
            }
        }
        .padding(20)
        .frame(height: 48)
    }
}

private struct Badge: View {
    @State var value: UInt
    
    var body: some View {
        ZStack {
            Capsule().fill(Color.crimson).frame(maxWidth: CGFloat(digitCount()) * 12,maxHeight: 18)
            Text("\(value)").font(.regular12).foregroundColor(.white)
        }
    }
    
    func digitCount() -> Double {
        let count = Double("\(value)".count)
        return count == 1 ? 1.5 : count
    }
}

private struct ToggleItem: View {
    
    var image: Image
    var title: String
    @State var isOn: Bool
    var onToggle: (Bool) -> Void
    
    var body: some View {
        HStack(spacing: 20) {
            image
            let toggleBinding = Binding(get: { isOn }, set: { newValue in
                isOn = newValue
                onToggle(newValue)
            })
            let toggle = Toggle(isOn: toggleBinding, label: {Text(LocalizedStringKey(title), bundle: .core)})
                .font(.regular16)
                .foregroundColor(.textDarkest)
            if #available(iOS 14, *) {
                toggle.toggleStyle(SwitchToggleStyle(tint: Color(Brand.shared.primary)))
            } else {
                toggle
            }
        }
        .padding(20)
        .frame(height: 48)
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        SideMenu(.student)
    }
}
