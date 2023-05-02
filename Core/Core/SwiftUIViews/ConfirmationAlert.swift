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

import Combine
import SwiftUI

public struct ConfirmationAlertViewModel {
    public let title: String
    public var message: String
    public let cancelButtonTitle: String
    public let confirmButtonTitle: String
    public let confirmButtonRole: ButtonRole?
    public let confirmDidTap = PassthroughSubject<Void, Never>()
    public let cancelDidTap = PassthroughSubject<Void, Never>()

    public init(title: String,
                message: String,
                cancelButtonTitle: String,
                confirmButtonTitle: String,
                isDestructive: Bool = false) {
        self.title = title
        self.message = message
        self.cancelButtonTitle = cancelButtonTitle
        self.confirmButtonTitle = confirmButtonTitle
        self.confirmButtonRole = isDestructive ? .destructive : nil
    }
}

public extension View {
    func confirmationAlert(isPresented: Binding<Bool>,
                           presenting viewModel: ConfirmationAlertViewModel)
    -> some View {
        alertConfirmation(isPresented: isPresented, presenting: viewModel)
    }

    func alertConfirmation(isPresented: Binding<Bool>,
                           presenting viewModel: ConfirmationAlertViewModel)
    -> some View {
        alert(
            viewModel.title,
            isPresented: isPresented,
            actions: {
                Button(viewModel.cancelButtonTitle,
                       role: .cancel,
                       action: viewModel.cancelDidTap.send)
                Button(viewModel.confirmButtonTitle,
                       role: viewModel.confirmButtonRole,
                       action: viewModel.confirmDidTap.send)
            }, message: {
                Text(viewModel.message)
            })
    }
}

#if DEBUG

struct ConfirmationAlertPreview: PreviewProvider {

    class ConfirmDemoViewModel: ObservableObject {
        @Published var statusText = ""
        @Published var isShowingConfirmationDialog = false
        let confirmDialog = ConfirmationAlertViewModel(title: "Confirm Selection",
                                                       message: "This action needs to be confirmed",
                                                       cancelButtonTitle: "Not Now",
                                                       confirmButtonTitle: "I Confirm",
                                                       isDestructive: true)

        public init() {
            confirmDialog.confirmDidTap
                .map { "Confirmed!" }
                .assign(to: &$statusText)
        }

        func showDidTap() {
            statusText = ""
            isShowingConfirmationDialog = true
        }
    }

    struct ConfirmDemoView: View {
        @StateObject var viewModel = ConfirmDemoViewModel()

        var body: some View {
            ZStack {
                VStack {
                    Text(viewModel.statusText).frame(height: 20)
                    Spacer()
                    Button {
                        viewModel.showDidTap()
                    } label: {
                        Text("Show dialog")
                    }
                    .alertConfirmation(isPresented: $viewModel.isShowingConfirmationDialog,
                                       presenting: viewModel.confirmDialog)
                    Spacer()
                }
            }
        }
    }

    static var previews: some View {
        ConfirmDemoView()
    }
}

#endif
