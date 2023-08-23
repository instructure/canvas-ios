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
    @StateObject private var offlineModeViewModel = OfflineModeViewModel(interactor: OfflineModeAssembly.make())

    @State private var isShowingActionSheet = false
    @State private var isUploadingImage = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
            let avatarLabel = userModel.canUpdateAvatar ? Text("Profile avatar, double tap to change", bundle: .core) : Text("Profile avatar", bundle: .core)
            Avatar(name: userModel.userName, url: userModel.avatarURL, size: 72, isAccessible: true)
                .padding(.bottom, 12).onTapGesture {
                    if userModel.canUpdateAvatar {
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
                .overlay(isUploadingImage ?
                    ProgressView()
                        .progressViewStyle(.indeterminateCircle())
                        .padding(.bottom, 12) :
                    nil
                )
            Text(userModel.name)
                .font(.bold20)
                .padding(.bottom, 2)
                .identifier("Profile.userNameLabel")
            Text(userModel.email)
                .font(.regular14)
                .foregroundColor(.textDark)
                .minimumScaleFactor(0.2)
                .identifier("Profile.userEmailLabel")

            if offlineModeViewModel.isOffline {
                HStack(spacing: 4) {
                    Image
                        .offlineLine
                        .resizable()
                        .frame(width: 24, height: 24)
                    Text("Offline", bundle: .core)
                        .font(.regular14)
                        .padding(.bottom, 2)
                }
                .foregroundColor(.textDarkest)
                .padding(.top, 6)
            }
        }
        .animation(.default, value: offlineModeViewModel.isOffline)
        .padding(20)
        .frame(minHeight: 185)
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
        private let env = AppEnvironment.shared

        lazy var profile = env.subscribe(GetUserProfile(userID: "self")) { [weak self] in
            self?.profileUpdated()
        }

        @Published var userName: String = ""
        @Published var avatarURL: URL?
        @Published var shortName: String?
        @Published var name: String = ""
        @Published var email: String = ""
        @Published var canUpdateAvatar = false

        init() {
            profile.refresh()
        }

        private func profileUpdated() {
            guard let profile = profile.first else {
                env.api.makeRequest(GetEnrollmentsRequest(context: .currentUser)) { [weak self] (enrollments, _, _) in performUIUpdate {
                    if let enrollment = enrollments?.first, let user = enrollment.user {
                        self?.userName = user.name
                        self?.avatarURL = user.avatar_url?.rawValue
                        self?.email = user.email ?? ""
                        self?.canUpdateAvatar = user.permissions?.can_update_avatar == true
                        if let displayName = user.short_name.isEmpty ? self?.userName : user.short_name {
                            self?.name = User.displayName(displayName, pronouns: user.pronouns)
                        }
                    }
                }}
                return }
            userName = profile.name
            avatarURL = profile.avatarURL
            email = profile.email ?? ""
            env.api.makeRequest(GetUserRequest(userID: "self")) { [weak self] (user, _, _) in performUIUpdate {
                self?.canUpdateAvatar = user?.permissions?.can_update_avatar == true
                let displayName = user?.short_name ?? self?.userName ?? ""
                self?.name = User.displayName(displayName, pronouns: profile.pronouns)
            }}
        }
    }
}

#if DEBUG

struct SideMenuHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        SideMenuHeaderView()
    }
}

#endif
