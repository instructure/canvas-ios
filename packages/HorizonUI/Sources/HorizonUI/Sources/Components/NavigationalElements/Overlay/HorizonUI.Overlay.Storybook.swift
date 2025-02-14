//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

public extension HorizonUI.Overlay {
    struct Storybook: View {
        @State private var present: Bool = false
        @State private var height: CGFloat = 0.0
        @State private var buttons:[ButtonAttribute] = []
        @State private var title: String = ""
        private let viewModel = StorybookViewModel()
        
        public var body: some View {
            VStack {
                Button("Present File Sheet") {
                    buttons = viewModel.fileUploadButtons
                    title = "Upload File"
                    present.toggle()

                }

                Button("Tools Sheet") {
                    buttons = viewModel.toolsButtons
                    title = "Tools"
                    present.toggle()
                }
            }
            .sheet(isPresented: $present){
                HorizonUI.Overlay(title: title, buttons: buttons)
                    .readingFrame(onChange: { frame in
                        height = frame.size.height
                    })
                    .presentationCompactAdaptation(.sheet)
                    .presentationCornerRadius(32)
                    .interactiveDismissDisabled()
                    .presentationDetents([.height(height)])
            }
            .navigationTitle("File Upload Sheet")
        }
    }
}

#Preview {
    HorizonUI.Overlay.Storybook()
}

public extension HorizonUI.Overlay {
    final class StorybookViewModel {
        var fileUploadButtons: [ButtonAttribute] {
            [
                .init(title: "Choose Photo or Video", icon: Image.huiIcons.image) { print("Choose Photo or Video") },
                .init(title: "Take Photo or Video", icon: Image.huiIcons.camera) { print("Take Photo or Video") },
                .init(title: "Choose File", icon: Image.huiIcons.folder) { print("Choose File") }
            ]
        }

        var toolsButtons: [ButtonAttribute] {
            [
                .init(title: "Attempt History", icon: Image.huiIcons.history) { print("Attempt History") },
                .init(title: "Comments", icon: Image.huiIcons.chat) { print("Comments") },
            ]
        }
    }
}
