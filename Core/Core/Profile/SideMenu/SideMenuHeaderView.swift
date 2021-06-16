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

struct SideMenuHeaderView: View {
    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller

    @ObservedObject private var viewModel = ImagePickerViewModel()
    @ObservedObject var userModel = UserModel()

    @State private var canUpdateAvatar: Bool = false
    @State private var isShowingActionSheet = false
    @State private var isUploadingImage = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
            let avatarLabel = canUpdateAvatar ? Text("Profile avatar, double tap to change", bundle: .core) : Text("Profile avatar", bundle: .core)
            Avatar(name: userModel.initials, url: userModel.avatarURL, size: 72, isAccessible: true)
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
                                    },
                    ])
                }
                .opacity(isUploadingImage ? 0.4 : 1)
                .overlay(isUploadingImage ? CircleProgress().padding(.bottom, 12) : nil)
            Text(userModel.name)
                .font(.bold20)
                .padding(.bottom, 2)
                .identifier("Profile.userNameLabel")
            Text(userModel.email)
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
                            userModel.profile.refresh(force: true)
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

extension SideMenuHeaderView {

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

    final class UserModel: ObservableObject {
        @Environment(\.appEnvironment) var env

        lazy var profile = env.subscribe(GetUserProfile(userID: "self")) { [weak self] in
            self?.profileUpdated()
        }

        @Published var userName: String?
        @Published var avatarURL: URL?
        @Published var initials: String = ""
        @Published var shortName: String?
        @Published var name: String = ""
        @Published var email: String = ""

        init() {
            profile.refresh()
        }

        private func profileUpdated() {
            guard let profile = profile.first, let userID = env.currentSession?.userID else { return }
            userName = env.currentSession?.userName ?? ""
            avatarURL = profile.avatarURL
            initials = userName ?? ""
            env.api.makeRequest(GetUserRequest(userID: "self")) {[weak self] (user, _, error) in
                if let userShortName = user?.short_name {
                    self?.shortName = User.displayName(userShortName, pronouns: self?.profile.first?.pronouns)
                }
            }
            name = shortName ?? userName.flatMap { User.displayName($0, pronouns: profile.pronouns) } ?? ""
            email = profile.email ?? ""
        }
    }
}

struct SideMenuHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        SideMenuHeaderView()
    }
}
