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
    let index: Int
    private let assignment: Assignment
    private let submission: Submission
    private var handleRefresh: (() -> Void)?

    @Environment(\.viewController) var controller

    @ObservedObject var attempts: Store<LocalUseCase<Submission>>

    @State var attempt: Int?
    @State var drawerState: DrawerState = .min
    @State var fileID: String?
    @State var showAttempts = false
    @State var tab: GraderTab = .grades
    @State var showRecorder: MediaCommentType?

    private var selected: Submission { attempts.first { attempt == $0.attempt } ?? submission }
    private var file: File? {
        selected.attachments?.first { fileID == $0.id } ??
        selected.attachments?.sorted(by: File.idCompare).first
    }

    init(
        index: Int,
        assignment: Assignment,
        submission: Submission,
        handleRefresh: (() -> Void)?
    ) {
        self.index = index
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
        self.handleRefresh = handleRefresh
    }

    var body: some View {
        GeometryReader { geometry in
            let bottomInset = geometry.safeAreaInsets.bottom
            let minHeight = bottomInset + 55
            let maxHeight = bottomInset + geometry.size.height - 64
            // At 1/4 of a screen offset, scale to 90% and round corners to 20
            let delta = abs(geometry.frame(in: .global).minX / max(1, geometry.size.width))
            let scale = interpolate(value: delta, fromMin: 0, fromMax: 0.25, toMin: 1, toMax: 0.9)
            let cornerRadius = interpolate(value: delta, fromMin: 0, fromMax: 0.25, toMin: 0, toMax: 20)
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
                                        handleRefresh: handleRefresh
                                    )
                                }
                                attemptPicker
                            }
                            Spacer().frame(height: bottomInset)
                        }
                            .zIndex(1)
                        Divider()
                        VStack(spacing: 0) {
                            tools(bottomInset: bottomInset, isDrawer: false)
                        }
                            .padding(.top, 16)
                            .frame(width: 375)
                    }
                }
                    .background(Color.backgroundLightest)
                    .cornerRadius(cornerRadius)
                    .scaleEffect(scale)
                    .edgesIgnoringSafeArea(.bottom)
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
                                    handleRefresh: handleRefresh
                                )
                            }
                            attemptPicker
                        }
                        Spacer().frame(height: drawerState == .min ? minHeight : (minHeight + maxHeight) / 2)
                    }
                    Drawer(state: $drawerState, minHeight: minHeight, maxHeight: maxHeight) {
                        tools(bottomInset: bottomInset, isDrawer: true)
                    }
                }
                    .background(Color.backgroundLightest)
                    .cornerRadius(cornerRadius)
                    .scaleEffect(scale)
                    .edgesIgnoringSafeArea(.bottom)
            }
        }
            .avoidKeyboardArea(force: true)
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
            }, label: {
                HStack {
                    Text(selected.submittedAt?.dateTimeString ?? "")
                        .font(.medium14)
                    Spacer()
                    Image.miniArrowDownSolid.rotationEffect(.degrees(showAttempts ? 180 : 0))
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

    enum GraderTab: Int, CaseIterable { case grades, comments, files }

    @ViewBuilder
    func tools(bottomInset: CGFloat, isDrawer: Bool) -> some View {
        Picker(selection: Binding(get: { isDrawer && drawerState == .min ? nil : tab }, set: { newValue in
            guard let newValue = newValue else { return }
            if drawerState == .min {
                snapDrawerTo(.mid)
            }
            withAnimation(.default) {
                tab = newValue
            }
            controller.view.endEditing(true)
        }), label: Text(verbatim: "")) {
            Text("Grades").tag(Optional(GraderTab.grades))
            Text("Comments").tag(Optional(GraderTab.comments))
            if selected.type == .online_upload, let count = selected.attachments?.count, count > 0 {
                Text("Files (\(count))").tag(Optional(GraderTab.files))
            } else {
                Text("Files").tag(Optional(GraderTab.files))
            }
        }
            .pickerStyle(SegmentedPickerStyle())
            .identifier("SpeedGrader.toolPicker")
            .padding(EdgeInsets(top: 0, leading: 16, bottom: 8, trailing: 16))
        Divider()
        GeometryReader { geometry in
            HStack(spacing: 0) {
                let drawerAttempt = Binding(get: { attempt }, set: {
                    attempt = $0
                    fileID = nil
                    snapDrawerTo(.min)
                })
                let drawerFileID = Binding(get: { fileID }, set: {
                    fileID = $0
                    snapDrawerTo(.min)
                })
                VStack(spacing: 0) {
                    SubmissionGrades(assignment: assignment, submission: submission)
                        .clipped()
                    Spacer().frame(height: bottomInset)
                }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                VStack(spacing: 0) {
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
                }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .background(Color.backgroundLight)
                VStack(spacing: 0) {
                    SubmissionFileList(submission: selected, fileID: drawerFileID)
                        .clipped()
                    Spacer().frame(height: bottomInset)
                }
                    .frame(width: geometry.size.width, height: geometry.size.height)
            }
                .frame(width: geometry.size.width, alignment: .leading)
                .background(Color.backgroundLightest)
                .offset(x: -CGFloat(tab.rawValue) * geometry.size.width)
        }
            .clipped()
    }

    private func snapDrawerTo(_ state: DrawerState) {
        withTransaction(DrawerState.transaction) {
            drawerState = state
        }
    }
}

private func interpolate(value: CGFloat, fromMin: CGFloat, fromMax: CGFloat, toMin: CGFloat, toMax: CGFloat) -> CGFloat {
    let bounded = max(fromMin, min(value, fromMax))
    return (((toMax - toMin) / (fromMax - fromMin)) * (bounded - fromMin)) + toMin
}
