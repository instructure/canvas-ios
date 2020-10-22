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

struct SubmissionViewer: View {
    let assignment: Assignment
    let submission: Submission
    let fileID: String?

    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller

    @State var hasOverflow = false

    var body: some View {
        switch submission.type {
        case .basic_lti_launch, .external_tool:
            WebSession(url: submission.previewUrl) { url in
                WebView(url: url)
                    .onLink(openInSafari)
                    .onChangeSize(handleSize)
                    .highPriorityGesture(DragGesture(), including: hasOverflow ? .all : .subviews)
            }
        case .discussion_topic, .online_quiz:
            WebSession(url: submission.previewUrl) { url in
                WebView(url: url)
                    .onLink(handleLink)
                    .onChangeSize(handleSize)
                    .highPriorityGesture(DragGesture(), including: hasOverflow ? .all : .subviews)
            }
        case .media_recording:
            VideoPlayer(url: submission.mediaComment?.url)
        case .online_text_entry:
            WebView(html: submission.body)
                .onLink(handleLink)
                .onChangeSize(handleSize)
                .highPriorityGesture(DragGesture(), including: hasOverflow ? .all : .subviews)
        case .online_upload:
            let file = submission.attachments?.first { fileID == $0.id } ??
                submission.attachments?.sorted(by: File.idCompare).first
            if let file = file, let url = file.url, let previewURL = file.previewURL {
                DocViewer(filename: file.filename, previewURL: previewURL, fallbackURL: url)
            } else if let id = file?.id {
                FileSubmissionViewer(fileID: id)
            }
        case .online_url:
            URLSubmissionViewer(submission: submission)
        default:
            VStack {
                Spacer()
                if assignment.submissionTypes.contains(.on_paper) {
                    Text("This assignment only allows on-paper submissions.")
                } else if assignment.submissionTypes.contains(.none) {
                    Text("This assignment does not allow submissions.")
                } else if submission.groupID != nil {
                    Text("This group does not have a submission for this assignment.")
                } else {
                    Text("This student does not have a submission for this assignment.")
                }
                Spacer()
            }
                .font(.regular16).foregroundColor(.textDarkest)
                .multilineTextAlignment(.center)
        }
    }

    func handleLink(url: URL) -> Bool {
        env.router.route(to: url, from: controller, options: .modal(embedInNav: true, addDoneButton: true))
        return true
    }

    func openInSafari(url: URL) -> Bool {
        env.loginDelegate?.openExternalURL(url)
        return true
    }

    func handleSize(webView: Core.CoreWebView, height: CGFloat) {
        hasOverflow = webView.scrollView.contentSize.width > webView.scrollView.frame.width
    }
}

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
                    Text("This submission is a URL to an external page. We've included a snapshot of what the page looked like when it was submitted.")
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
                if let file = submission.attachments?.first, let url = file.url {
                    if let error = error, url == loaded {
                        Text(error.localizedDescription)
                            .font(.regular16).foregroundColor(.textDanger)
                    } else if let image = image, url == loaded {
                        Button(action: {
                            guard let id = submission.attachments?.first?.id else { return }
                            env.router.route(
                                to: "/files/\(id)",
                                from: controller,
                                options: .modal(embedInNav: true, addDoneButton: true)
                            )
                        }, label: {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(image.size, contentMode: .fill)
                                .accessibility(label: Text("URL Preview Image"))
                        })
                            .padding(.horizontal, -16)
                    } else {
                        CircleProgress().padding(32).onAppear {
                            env.api.makeRequest(url) { (data, _, error) in
                                image = data.flatMap { UIImage(data: $0) }
                                self.error = error
                                self.loaded = url
                            }
                        }
                    }
                } else {
                    Text("Preview Unavailable")
                        .font(.regular16).foregroundColor(.textDark)
                }
            }
                .multilineTextAlignment(.leading)
                .padding(16)
        }
    }
}

struct FileSubmissionViewer: UIViewControllerRepresentable {
    let fileID: String

    func makeUIViewController(context: Self.Context) -> UIViewController { UIViewController() }

    func updateUIViewController(_ uiViewController: UIViewController, context: Self.Context) {
        let prev = uiViewController.children.first as? FileDetailsViewController
        if prev?.fileID != fileID {
            prev?.unembed()
            let next = FileDetailsViewController.create(context: nil, fileID: fileID)
            uiViewController.embed(next, in: uiViewController.view)
        }
    }
}
