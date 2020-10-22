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

struct SubmissionGrader: View {
    let assignment: Assignment
    let submission: Submission
    @ObservedObject var attempts: Store<LocalUseCase<Submission>>

    @Binding var drawerState: DrawerState
    @Binding var isPagingEnabled: Bool
    let bottomInset: CGFloat

    @State var attempt: Int?
    @State var fileID: String?
    @State var showAttempts = false
    @State var tab: GraderTab = .grades
    @State var showRecorder: MediaCommentType?

    var selected: Submission { attempts.first { attempt == $0.attempt } ?? submission }
    var file: File? {
        selected.attachments?.first { fileID == $0.id } ??
        selected.attachments?.sorted(by: File.idCompare).first
    }

    init(
        assignment: Assignment,
        submission: Submission,
        drawerState: Binding<DrawerState>,
        isPagingEnabled: Binding<Bool>,
        bottomInset: CGFloat
    ) {
        self.assignment = assignment
        self.submission = submission
        self.attempts = AppEnvironment.shared.subscribe(scope: Scope(
            predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(key: #keyPath(Submission.assignmentID), equals: assignment.id),
                NSPredicate(key: #keyPath(Submission.userID), equals: submission.userID),
                NSPredicate(format: "%K != nil", #keyPath(Submission.submittedAt)),
            ]),
            orderBy: #keyPath(Submission.attempt)
        ))
        self._drawerState = drawerState
        self._isPagingEnabled = isPagingEnabled
        self.bottomInset = bottomInset
    }

    var body: some View {
        GeometryReader { geometry in
            let minHeight = 55 + bottomInset
            let maxHeight = geometry.size.height - 64
            if geometry.size.width > 834 {
                VStack(spacing: 0) {
                    SubmissionHeader(assignment: assignment, submission: submission)
                    Divider()
                    HStack(spacing: 0) {
                        VStack(alignment: .leading, spacing: 0) {
                            attemptToggle
                            Divider()
                            ZStack(alignment: .top) {
                                VStack(spacing: 0) {
                                    SimilarityScore(selected, file: file)
                                    SubmissionViewer(
                                        assignment: assignment,
                                        submission: selected,
                                        fileID: fileID,
                                        isPagingEnabled: $isPagingEnabled
                                    )
                                }
                                attemptPicker
                            }
                            Spacer().frame(height: bottomInset)
                        }
                        Divider()
                        tabs
                            .padding(.top, 16)
                            .frame(width: 375)
                    }
                }
            } else {
                ZStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 0) {
                        SubmissionHeader(assignment: assignment, submission: submission)
                        attemptToggle
                        Divider()
                        ZStack(alignment: .top) {
                            VStack(spacing: 0) {
                                SimilarityScore(selected, file: file)
                                SubmissionViewer(
                                    assignment: assignment,
                                    submission: selected,
                                    fileID: fileID,
                                    isPagingEnabled: $isPagingEnabled
                                )
                            }
                            attemptPicker
                        }
                        Spacer().frame(height: drawerState == .min ? minHeight : (minHeight + maxHeight) / 2)
                    }
                    Drawer(state: $drawerState, minHeight: minHeight, maxHeight: maxHeight) { tabs }
                }
            }
        }
            .background(Color.backgroundLightest)
    }

    @ViewBuilder
    var attemptToggle: some View {
        if let first = attempts.first, attempts.count == 1 {
            Text(first.submittedAt?.dateTimeString ?? "")
                .font(.medium14).foregroundColor(.textDark)
                .frame(minHeight: 24)
                .padding(EdgeInsets(top: 8, leading: 16, bottom: 4, trailing: 8))
        } else if let selected = attempts.first(where: { attempt == $0.attempt }) ?? attempts.last {
            Button(action: {
                showAttempts.toggle()
                isPagingEnabled = !showAttempts
            }, label: {
                HStack {
                    Text(selected.submittedAt?.dateTimeString ?? "")
                        .font(.medium14)
                    Spacer()
                    Icon.miniArrowDownSolid.rotationEffect(.degrees(showAttempts ? 180 : 0))
                }
                    .foregroundColor(.textDark)
                    .padding(EdgeInsets(top: 8, leading: 16, bottom: 4, trailing: 8))
            })
        }
    }

    @ViewBuilder
    var attemptPicker: some View {
        if showAttempts {
            VStack(spacing: 0) {
                Picker(selection: Binding(get: { selected.attempt }, set: { newValue in
                    withTransaction(.exclusive()) {
                        attempt = newValue
                        fileID = nil
                    }
                    showAttempts = false
                    isPagingEnabled = true
                }), label: Text(verbatim: "")) {
                    ForEach(attempts.all, id: \.attempt) { attempt in
                        Text(attempt.submittedAt?.dateTimeString ?? "")
                            .tag(Optional(attempt.attempt))
                    }
                }
                    .labelsHidden()
                Divider()
            }
                .background(Color.backgroundLightest)
        }
    }

    enum GraderTab: Int, CaseIterable, Identifiable {
        case grades, comments, files
        var id: Int { rawValue }
    }

    var tabs: some View {
        VStack(spacing: 0) {
            Picker(selection: Binding(get: { tab }, set: {
                tab = $0
                if drawerState == .min { snapDrawerTo(.mid) }
            }), label: Text(verbatim: "")) {
                Text("Grades").tag(GraderTab.grades)
                Text("Comments").tag(GraderTab.comments)
                if selected.type == .online_upload, let count = selected.attachments?.count, count > 0 {
                    Text("Files (\(count))").tag(GraderTab.files)
                } else {
                    Text("Files").tag(GraderTab.files)
                }
            }
                .pickerStyle(SegmentedPickerStyle())
                .padding(EdgeInsets(top: 0, leading: 16, bottom: 8, trailing: 16))
            Divider()
            let drawerAttempt = Binding(get: { attempt }, set: {
                attempt = $0
                fileID = nil
                snapDrawerTo(.min)
            })
            let drawerFileID = Binding(get: { fileID }, set: {
                fileID = $0
                snapDrawerTo(.min)
            })
            Pages(items: GraderTab.allCases, currentIndex: Binding(get: { tab.rawValue }, set: {
                tab = GraderTab.allCases[$0]
            })) { tab in
                VStack(spacing: 0) {
                    switch tab {
                    case .grades:
                        SubmissionGrades(assignment: assignment, submission: submission)
                            .clipped()
                        Spacer().frame(height: bottomInset)
                    case .comments:
                        SubmissionCommentList(
                            assignment: assignment,
                            submission: submission,
                            attempts: attempts,
                            attempt: drawerAttempt,
                            fileID: drawerFileID,
                            showRecorder: $showRecorder
                        )
                            .clipped()
                        if showRecorder != .video || drawerState == .min {
                            Spacer().frame(height: bottomInset)
                        }
                    case .files:
                        SubmissionFileList(submission: selected, fileID: drawerFileID)
                            .clipped()
                        Spacer().frame(height: bottomInset)
                    }
                }
                    .background(tab == .comments ? Color.backgroundLight : Color.backgroundLightest)
            }
        }
    }

    func snapDrawerTo(_ state: DrawerState) {
        withTransaction(DrawerState.transaction) {
            drawerState = state
        }
    }
}
