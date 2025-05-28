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
    var handleRefresh: (() -> Void)?

    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    @ObservedObject private var studentAnnotationViewModel: StudentAnnotationSubmissionViewerViewModel

    public init(assignment: Assignment, submission: Submission, fileID: String?, studentAnnotationViewModel: StudentAnnotationSubmissionViewerViewModel, handleRefresh: (() -> Void)?) {
        self.assignment = assignment
        self.submission = submission
        self.fileID = fileID
        self.studentAnnotationViewModel = studentAnnotationViewModel
        self.handleRefresh = handleRefresh
    }

    var body: some View {
        switch submission.type {
        case .basic_lti_launch, .external_tool:
            WebSession(url: submission.previewUrl) { url in
                WebView(url: url,
                        features: [
                            .userAgent(UserAgent.safariLTI.description),
                            .invertColorsInDarkMode,
                            .disableLinksOverlayPreviews
                        ]
                )
                .onLink(openInSafari)
            }
        case .discussion_topic:
            WebSession(url: submission.previewUrl) { url in
                WebView(url: url,
                        features: [.invertColorsInDarkMode])
                .onLink(handleLink)
                .onNavigationFinished(handleRefresh)
            }
        case .online_quiz:
            if assignment.anonymousSubmissions == true {
                VStack {
                    Spacer()
                    HStack { Spacer() }
                    Text("This student's responses are hidden because this assignment is anonymous.", bundle: .teacher)
                    Spacer()
                }
                .font(.regular16)
                .padding(InstUI.Styles.Padding.standard.rawValue)
                .foregroundColor(.textDarkest)
                .multilineTextAlignment(.center)
            } else {
                WebSession(url: submission.previewUrl) { url in
                    WebView(url: url,
                            features: [
                                .invertColorsInDarkMode,
                                .disableLinksOverlayPreviews
                            ])
                    .onLink(handleLink)
                    .onNavigationFinished(handleRefresh)
                }
            }
        case .media_recording:
            VideoPlayer(url: submission.mediaComment?.url)
        case .online_text_entry:
            WebView(
                html: submission.body,
                baseURL: env.currentSession?.baseURL,
                canToggleTheme: true
            )
            .onLink(handleLink)
        case .online_upload:
            let file = submission.attachments?.first { fileID == $0.id } ??
                submission.attachments?.sorted(by: File.idCompare).first
            if let file = file, let url = file.url, let previewURL = file.previewURL {
                DocViewer(filename: file.filename, previewURL: previewURL, fallbackURL: url)
            } else if let id = file?.id {
                FileViewer(fileID: id)
            }
        case .online_url:
            URLSubmissionViewer(submission: submission)
        case .student_annotation:
            switch studentAnnotationViewModel.session {
            case .success(let session):
                DocViewer(filename: "", previewURL: session, fallbackURL: session)
            case .failure(let error):
                VStack(alignment: .center, spacing: 0) {
                    Spacer()
                    Text("Failed to load submission data!", bundle: .teacher)
                        .font(.regular16)
                        .foregroundColor(.textDarkest)
                    Text(error.localizedDescription)
                        .font(.regular16)
                        .foregroundColor(.textDarkest)
                        .padding(.bottom, 10)
                    Button(action: studentAnnotationViewModel.retry) {
                        Text("Retry", bundle: .teacher)
                            .foregroundColor(Color(Brand.shared.primary))
                    }
                    Spacer()
                }
                .padding(InstUI.Styles.Padding.standard.rawValue)
                .frame(maxWidth: .infinity)
            case nil:
                ProgressView()
                    .progressViewStyle(.indeterminateCircle())
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .onAppear {
                        studentAnnotationViewModel.viewDidAppear()
                    }
            }
        default:
            VStack {
                Spacer()
                HStack { Spacer() }
                if assignment.submissionTypes.contains(.on_paper) {
                    Text("This assignment only allows on-paper submissions.", bundle: .teacher)
                } else if assignment.submissionTypes.contains(.none) {
                    Text("This assignment does not allow submissions.", bundle: .teacher)
                } else if submission.groupID != nil {
                    Text("This group does not have a submission for this assignment.", bundle: .teacher)
                } else {
                    Text("This student does not have a submission for this assignment.", bundle: .teacher)
                }
                Spacer()
            }
                .font(.regular16)
                .padding(InstUI.Styles.Padding.standard.rawValue)
                .foregroundColor(.textDarkest)
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
}

#Preview {
    let environment = PreviewEnvironment()
    SubmissionViewer(
        assignment: .save(
            .make(anonymous_submissions: true),
            in: environment.database.viewContext,
            updateSubmission: false,
            updateScoreStatistics: false
        ),
        submission: .save(
            .make(submission_type: .online_quiz),
            in: environment.database.viewContext,
        ),
        fileID: nil,
        studentAnnotationViewModel: .init(submission: .save(.make(), in: environment.database.viewContext)),
        handleRefresh: { }
    )
}
