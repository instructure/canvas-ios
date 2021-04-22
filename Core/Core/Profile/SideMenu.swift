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

    let enrollment: HelpLinkEnrollment
    
    public init(_ enrollment: HelpLinkEnrollment) {
        self.enrollment = enrollment
        let env = AppEnvironment.shared
        profile = env.subscribe(GetUserProfile(userID: "self"))
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading) {
                    HeaderView(profileStore: profile)
                    Divider()
                    MainSection(enrollment)
                    Divider()
                    if enrollment != .observer {
                        OptionsSection(enrollment)
                        Divider()
                    }
                    BottomSection(enrollment)
                    Spacer()
                }
            }.clipped()
            FooterView()
        }.onAppear {
            profile.refresh()
        }
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
                MenuItem(id: "inbox", image: .emailLine, title: Text("Inbox", bundle: .core), badgeValue: unreadCount).onAppear {
                    env.api.makeRequest(GetConversationsUnreadCountRequest()) { (response, _, _) in
                        self.unreadCount = response?.unread_count ?? 0
                    }
                }.onTapGesture {
                    route(to: "/conversations")
                }
                
                MenuItem(id: "manageChildren", image: .groupLine, title: Text("Manage Students", bundle: .core)).onTapGesture {
                    route(to: "/profile/observees")
                }
            } else {
                MenuItem(id: "files", image: .folderLine, title: Text("Files", bundle: .core)).onTapGesture {
                    route(to: "/users/self/files")
                }
                
                ForEach(Array(tools), id: \.self) { tool in
                    MenuItem(id: "lti.\(tool.domain ?? "").\(tool.definitionID)", image: imageForDomain(tool.domain),
                             title: Text("\(tool.title)", bundle: .core)).onTapGesture {
                                launchLTI(url: tool.url)
                             }
                }
            }
            
            if enrollment == .student || enrollment == .teacher {
                MenuItem(id: "settings", image: .settingsLine,
                         title: Text("Settings", bundle: .core), badgeValue: 0).onTapGesture {
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
            image = .studioLine
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
            SubHeaderView(title: Text("OPTIONS", bundle: .core))
            if enrollment == .student {
                let showGrades = env.userDefaults?.showGradesOnDashboard == true
                ToggleItem(id: "showGrades", image: .gradebookLine, title: Text("Show Grades", bundle: .core), isOn: showGrades) {
                    env.userDefaults?.showGradesOnDashboard = $0
                }
            }
            
            if enrollment == .student || enrollment == .teacher {
                let colorOverlay = settings.first?.hideDashcardColorOverlays != true
                ToggleItem(id: "colorOverlay", image: .coursesLine, title: Text("Color Overlay", bundle: .core), isOn: colorOverlay) {
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
    
    #if DEBUG
    @State var showDevMenu = true
    #else
    @State var showDevMenu = UserDefaults.standard.bool(forKey: "showDevMenu")
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
            
            if let root = helpLinks.first, helpLinks.count > 1 {
                MenuItem(id: "help", image: .questionLine, title: Text("\(root.text)", bundle: .core), badgeValue: 0).onTapGesture {
                    showHelpMenu()
                }
            }
            
            if canActAsUser {
                MenuItem(id: "actAsUser", image: .userLine, title: Text("Act as User", bundle: .core), badgeValue: 0).onTapGesture {
                    self.route(to: "/act-as-user", options: .modal(embedInNav: true))
                }
            }
            
            if env.currentSession?.isFakeStudent != true {
                MenuItem(id: "changeUser", image: .userLine, title: Text("Change User", bundle: .core), badgeValue: 0).onTapGesture {
                    guard let delegate = self.env.loginDelegate else { return }
                    env.router.dismiss(controller) {
                        delegate.changeUser()
                    }
                }
            }
            
            if env.currentSession?.actAsUserID != nil {
                let isFakeStudent = env.currentSession?.isFakeStudent == true
                let leaveText = Text("Leave Student View", bundle: .core)
                let stopText = Text("Stop Act as User", bundle: .core)
                let logoutTitleText = isFakeStudent ? leaveText : stopText
                MenuItem(id: "logOut", image: Image("logout", bundle: .core), title: logoutTitleText, badgeValue: 0)
            } else {
                MenuItem(id: "logOut", image: Image("logout", bundle: .core), title: Text("Log Out", bundle: .core), badgeValue: 0).onTapGesture {
                    handleLogout()
                }
            }
            
            if showDevMenu {
                MenuItem(id: "developerMenu", image: .settingsLine, title: Text("Developer menu", bundle: .core)).onTapGesture {
                    route(to: "/dev-menu", options: .modal(embedInNav: true))
                }
            }
        }
        .onAppear {
            helpLinks.refresh()
            permissions.refresh()
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
        env.router.show(helpViewController, from: controller.value, options: .modal(.formSheet, embedInNav: true, addDoneButton: true))
    }
}

private struct FooterView: View {
    
    var body: some View {
        if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            HStack {
                Text("v. \(version)").padding(.leading, 10).font(.regular14).foregroundColor(.ash)
                Spacer()
            }.padding().frame(height: 30)
        }
    }
}

private struct HeaderView: View {
    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller
    @ObservedObject var profileStore: Store<GetUserProfile>

    @ObservedObject private var viewModel = ImagePickerViewModel()
    @State private var canUpdateAvatar: Bool = false
    @State private var isShowingActionSheet = false
    @State private var isUploadingImage = false

    private var userName: String? { profileStore.first?.name ?? env.currentSession?.userName }
    private var avatarURL: URL? { profileStore.first?.avatarURL }
    private var initials: String { userName ?? "" }
    private var name: String { userName.flatMap { User.displayName($0, pronouns: profileStore.first?.pronouns) } ?? "" }
    private var email: String { profileStore.first?.email ?? "" }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
            let avatarLabel = canUpdateAvatar ? Text("Profile avatar, double tap to change", bundle: .core) : Text("Profile avatar", bundle: .core)
            Avatar(name: initials, url: avatarURL, size: 72, isAccessible: true)
                .padding(.bottom, 12).onTapGesture {
                    if canUpdateAvatar {
                        isShowingActionSheet = true
                    }
                }
                .accessibilityElement(children: .ignore)
                .accessibility(label: avatarLabel)
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
                .opacity(isUploadingImage ? 0.4 : 1)
                .overlay(isUploadingImage ? CircleProgress().padding(.bottom, 12) : nil)
            Text(name)
                .font(.bold20)
                .padding(.bottom, 2)
                .identifier("Profile.userNameLabel")
            Text(email)
                .font(.regular14)
                .foregroundColor(.ash)
                .minimumScaleFactor(0.2)
                .identifier("Profile.userEmailLabel")
        }.padding(20).frame(height: 185).onAppear {
            env.api.makeRequest(GetUserRequest(userID: "self")) {user, _, _ in
                canUpdateAvatar = user?.permissions?.can_update_avatar == true
            }
        }
        .sheet(isPresented: $viewModel.isPresentingImagePicker) {
            ProfileImagePicker(sourceType: viewModel.sourceType) { image in
                viewModel.isPresentingImagePicker = false
                guard let image = image else { return }
                isUploadingImage = true
                do {
                    UploadAvatar(url: try image.write(nameIt: "profile")).fetch { result in performUIUpdate {
                        isUploadingImage = false
                        switch result {
                        case .success:
                            // Trigger save to CoreData
                            profileStore.refresh(force: true)
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
        env.router.show(alert, from: controller.value, options: .modal())
    }
}

extension HeaderView {
    final class ImagePickerViewModel: ObservableObject {
        @Published var selectedImage: UIImage?
        @Published var isPresentingImagePicker = false
        private(set) var sourceType: ProfileImagePicker.SourceType = .camera
        
        func choosePhoto() {
            sourceType = .photoLibrary
            isPresentingImagePicker = true
        }
        
        func takePhoto() {
            guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
            sourceType = .camera
            isPresentingImagePicker = true
        }
    }
}

private struct SubHeaderView: View {
    
    var title: Text
    
    var body: some View {
        HStack {
            title
                .font(.regular12)
                .foregroundColor(.ash)
            Spacer()
        }.padding(26).frame(height: 30)
    }
}

private struct MenuItem: View {

    let id: String
    let image: Image
    let title: Text
    @State var badgeValue: UInt = 0
    
    var body: some View {
        HStack(spacing: 20) {
            image
            title.font(.regular16)
            Spacer()
            
            if badgeValue > 0 {
                Badge(value: badgeValue)
            }
        }
        .padding(20)
        .frame(height: 48)
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibility(label: title)
        .identifier("Profile.\(id)Button")
    }
}

private struct Badge: View {
    @State var value: UInt
    
    var body: some View {
        ZStack {
            Capsule().fill(Color.crimson).frame(maxWidth: CGFloat(digitCount()) * 12, maxHeight: 18)
            Text("\(value)").font(.regular12).foregroundColor(.white)
        }
    }
    
    func digitCount() -> Double {
        let count = Double("\(value)".count)
        return count == 1 ? 1.5 : count
    }
}

private struct ToggleItem: View {

    let id: String
    let image: Image
    let title: Text
    @State var isOn: Bool
    let onToggle: (Bool) -> Void
    
    var body: some View {
        HStack(spacing: 20) {
            image.accessibility(hidden: true)
            let toggleBinding = Binding(get: { isOn }, set: { newValue in
                isOn = newValue
                onToggle(newValue)
            })
            let toggle = Toggle(isOn: toggleBinding, label: { title })
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
        .contentShape(Rectangle())
        .accessibility(label: title)
        .identifier("Profile.\(id)Toggle")
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        SideMenu(.student)
    }
}
