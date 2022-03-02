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
    private enum Layout {
        case portrait
        case landscape // only on iPads no matter the iPhone screen size
    }
    let index: Int
    private let assignment: Assignment
    private let submission: Submission
    private var handleRefresh: (() -> Void)?

    @Environment(\.viewController) var controller

    @ObservedObject var attempts: Store<LocalUseCase<Submission>>
    @ObservedObject var commentLibrary = SubmissionCommentLibraryViewModel()

    @State var attempt: Int? {
        willSet {
            let attemptChanged = (selected.attempt != newValue)

            if attemptChanged {
                let newAttempt = attempts.first { newValue == $0.attempt } ?? submission
                studentAnnotationViewModel = StudentAnnotationSubmissionViewerViewModel(submission: newAttempt)
            }
        }
    }
    @State var drawerState: DrawerState = .min
    @State var fileID: String?
    @State var showAttempts = false
    @State var tab: GraderTab = .grades
    @State var showRecorder: MediaCommentType?
    /** This is mainly used by `SubmissionCommentList` but since it's re-created on rotation and app backgrounding the entered text is lost. */
    @State var enteredComment: String = ""
    /** Used to work around an issue which caused the page to re-load after putting the app into background. See `layoutForWidth()` method for more. */
    @State private var lastPresentedLayout: Layout = .portrait
    @State private var studentAnnotationViewModel: StudentAnnotationSubmissionViewerViewModel

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
        self.studentAnnotationViewModel = StudentAnnotationSubmissionViewerViewModel(submission: submission)
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

            switch layoutForWidth(geometry.size.width) {
            case .landscape:
                VStack(spacing: 0) {
                    SubmissionHeader(assignment: assignment, submission: submission)
                        .accessibility(sortPriority: 2)
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
                                        studentAnnotationViewModel: studentAnnotationViewModel,
                                        handleRefresh: handleRefresh
                                    )
                                }
                                    // Disable submission content interaction in case attempt picker is above it
                                    .accessibilityElement(children: showAttempts ? .ignore : .contain)
                                    .accessibility(hidden: showAttempts)
                                attemptPicker
                            }
                            Spacer().frame(height: bottomInset)
                        }
                            .zIndex(1)
                            .accessibility(sortPriority: 1)
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
                    .onAppear { didChangeLayout(to: .landscape) }
            case .portrait:
                ZStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 0) {
                        SubmissionHeader(assignment: assignment, submission: submission)
                        attemptToggle
                            .accessibility(hidden: drawerState == .max)
                        Divider()
                        let isSubmissionContentHiddenFromA11y = (drawerState != .min || showAttempts)
                        ZStack(alignment: .top) {
                            VStack(spacing: 0) {
                                SimilarityScore(selected, file: file)
                                SubmissionViewer(
                                    assignment: assignment,
                                    submission: selected,
                                    fileID: fileID,
                                    studentAnnotationViewModel: studentAnnotationViewModel,
                                    handleRefresh: handleRefresh
                                )
                            }
                                .accessibilityElement(children: isSubmissionContentHiddenFromA11y ? .ignore : .contain)
                                .accessibility(hidden: isSubmissionContentHiddenFromA11y)
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
                    .onAppear { didChangeLayout(to: .portrait) }
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
                    .pickerStyle(WheelPickerStyle())
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
                let isGradesOnScreen = isGraderTabOnScreen(.grades, isDrawer: isDrawer)
                VStack(spacing: 0) {
                    SubmissionGrades(assignment: assignment, containerHeight: geometry.size.height, submission: submission)
                        .clipped()
                    Spacer().frame(height: bottomInset)
                }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .accessibilityElement(children: isGradesOnScreen ? .contain : .ignore)
                    .accessibility(hidden: !isGradesOnScreen)
                let isCommentsOnScreen = isGraderTabOnScreen(.comments, isDrawer: isDrawer)
                VStack(spacing: 0) {
                    SubmissionCommentList(
                        assignment: assignment,
                        submission: submission,
                        attempts: attempts,
                        attempt: drawerAttempt,
                        fileID: drawerFileID,
                        showRecorder: $showRecorder,
                        enteredComment: $enteredComment,
                        commentLibrary: commentLibrary
                    )
                        .clipped()
                    if showRecorder != .video || drawerState == .min {
                        Spacer().frame(height: bottomInset)
                    }
                }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .background(Color.backgroundLight)
                    .accessibilityElement(children: isCommentsOnScreen ? .contain : .ignore)
                    .accessibility(hidden: !isCommentsOnScreen)
                let isFilesOnScreen = isGraderTabOnScreen(.files, isDrawer: isDrawer)
                VStack(spacing: 0) {
                    SubmissionFileList(submission: selected, fileID: drawerFileID)
                        .clipped()
                    Spacer().frame(height: bottomInset)
                }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .accessibilityElement(children: isFilesOnScreen ? .contain : .ignore)
                    .accessibility(hidden: !isFilesOnScreen)
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

    private func isGraderTabOnScreen(_ tab: GraderTab, isDrawer: Bool) -> Bool {
        let isTabSelected = (self.tab == tab)

        if isDrawer {
            return (drawerState != .min && isTabSelected)
        } else {
            return isTabSelected
        }
    }

    private func layoutForWidth(_ width: CGFloat) -> Layout {
        // On iPads if the app is backgrounded then it changes the device orientation back and forth causing the UI to re-render and the submission to re-load.
        // To overcome this we force the last presented layout in case the app is in the background.
        guard UIApplication.shared.applicationState != .background else {
            return lastPresentedLayout
        }
        return width > 834 ? .landscape : .portrait
    }

    private func didChangeLayout(to layout: Layout) {
        if lastPresentedLayout != layout {
            // When the layout changes the keyboard disappears without any system notifications
            // on iPads so we simulate one to allow .avoidKeyboardArea() to work correctly.
            NotificationCenter.default.post(name: UIApplication.keyboardWillHideNotification, object: nil, userInfo: [:])
        }
        lastPresentedLayout = layout
    }
}

private func interpolate(value: CGFloat, fromMin: CGFloat, fromMax: CGFloat, toMin: CGFloat, toMax: CGFloat) -> CGFloat {
    let bounded = max(fromMin, min(value, fromMax))
    return (((toMax - toMin) / (fromMax - fromMin)) * (bounded - fromMin)) + toMin
}
