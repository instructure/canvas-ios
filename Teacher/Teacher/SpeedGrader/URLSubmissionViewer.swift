//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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
import Core

struct URLSubmissionViewer: View {
    let submission: Submission

    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller

    @State var image: UIImage?
    @State var loaded: URL?
    @State var error: Error?

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                HStack {
                    Text("This submission is a URL to an external page. We've included a snapshot of what the page looked like when it was submitted.", bundle: .teacher)
                        .font(.regular16).foregroundColor(.textDarkest)
                    Spacer()
                }
                Button(action: {
                    guard let url = submission.url else { return }
                    env.loginDelegate?.openExternalURL(url)
                }, label: {
                    Text(submission.url?.absoluteString ?? "")
                        .font(.semibold16).foregroundColor(Color(Brand.shared.linkColor))
                        .padding(.vertical, 16)
                })
                if let file = submission.attachments?.first, let id = file.id, let url = file.url {
                    if let error = error, url == loaded {
                        Text(error.localizedDescription)
                            .font(.regular16).foregroundColor(.textDanger)
                    } else if let image = image, url == loaded {
                        Button(action: {
                            env.router.route(
                                to: "/files/\(id)",
                                from: controller,
                                options: .modal(embedInNav: true, addDoneButton: true)
                            )
                        }, label: {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(image.size, contentMode: .fill)
                                .accessibility(label: Text("URL Preview Image", bundle: .teacher))
                        })
                            .padding(.horizontal, -16)
                    } else {
                        ProgressView()
                            .progressViewStyle(.indeterminateCircle())
                            .padding(32)
                            .onAppear {
                            env.api.makeRequest(url) { (data, _, error) in
                                image = data.flatMap { UIImage(data: $0) }
                                self.error = error
                                self.loaded = url
                            }
                        }
                    }
                } else {
                    Text("Preview Unavailable", bundle: .teacher)
                        .font(.regular16).foregroundColor(.textDark)
                }
            }
                .multilineTextAlignment(.leading)
                .padding(16)
        }
    }
}
