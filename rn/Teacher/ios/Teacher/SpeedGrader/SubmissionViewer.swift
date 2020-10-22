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
    @Binding var isPagingEnabled: Bool

    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller

    @State var webView: WeakReference<Core.CoreWebView> = WeakReference()
    var hasOverflow: Bool {
        guard let scrollView = webView.value?.scrollView else { return false }
        return scrollView.contentSize.width > scrollView.frame.width
    }

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
                DocViewer(filename: file.filename, previewURL: previewURL, fallbackURL: url) {
                    isPagingEnabled = !$0
                }
            } else if let id = file?.id {
                FileViewer(fileID: id)
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
        guard self.webView.value != webView else { return }
        let ref = WeakReference<Core.CoreWebView>()
        ref.value = webView
        self.webView = ref
    }
}
