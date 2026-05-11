//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

import StoreKit
import SwiftUI

public struct ForceUpdateView: View {
    @Environment(\.viewController) private var viewController
    @Environment(\.dismiss) private var dismiss

    @State private var isErrorAlertPresented = false

    let isDismissable: Bool
    let appID: String

    public init(app: AppEnvironment.App, isDismissable: Bool) {
        self.isDismissable = isDismissable
        self.appID = app.appID
    }

    public var body: some View {
        ZStack(alignment: .topTrailing) {
            if isDismissable {
                Button {
                    dismiss()
                } label: {
                    Text("Later")
                }
                .buttonStyle(.bordered)
                .padding()
            }

            VStack(spacing: 24) {
                Image(systemName: "icloud.and.arrow.down")
                    .font(.system(size: 80))
                    .foregroundStyle(.textDark)

                Text(verbatim: "Canvas needs updating.")
                    .foregroundStyle(.textDarkest)

                Button(action: loadAppStorePage) {
                    Label("App Store", systemImage: "applelogo")
                }
                .buttonStyle(.borderedProminent)
                .tint(.backgroundDarkest)
                .foregroundStyle(.textLightest)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .alert("Failed to open the App Store", isPresented: $isErrorAlertPresented, actions: { })
    }

    private func loadAppStorePage() {
        Task {
            do {
                let controller = SKStoreProductViewController()
                let parameters = [SKStoreProductParameterITunesItemIdentifier: appID]
                try await controller.loadProduct(withParameters: parameters)

                viewController.value.present(controller, animated: true)
            } catch {
                isErrorAlertPresented = true
            }
        }
    }
}

#Preview {
    ForceUpdateView(app: .student, isDismissable: true)
}
