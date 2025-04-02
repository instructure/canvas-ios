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

import Core
import SwiftUI

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
    @State private var selectedIndex = 0
    @StateObject private var rubricsViewModel: RubricsViewModel

    @AccessibilityFocusState private var focusedTab: GraderTab?

    private var selected: Submission { attempts.first { attempt == $0.attempt } ?? submission }
    private var file: File? {
        selected.attachments?.first { fileID == $0.id } ??
            selected.attachments?.sorted(by: File.idCompare).first
    }

    init(
        env: AppEnvironment,
        index: Int,
        assignment: Assignment,
        submission: Submission,
        handleRefresh: (() -> Void)?
    ) {
        self.index = index
        self.assignment = assignment
        self.submission = submission
        attempts = env.subscribe(scope: Scope(
            predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(key: #keyPath(Submission.assignmentID), equals: assignment.id),
                NSPredicate(key: #keyPath(Submission.userID), equals: submission.userID),
                NSPredicate(format: "%K != nil", #keyPath(Submission.submittedAt))
            ]),
            orderBy: #keyPath(Submission.attempt)
        ))
        attempt = submission.attempt
        self.handleRefresh = handleRefresh
        studentAnnotationViewModel = StudentAnnotationSubmissionViewerViewModel(submission: submission)
        _rubricsViewModel = StateObject(wrappedValue: RubricsViewModel(assignment: assignment, submission: submission, interactor: .init(assignment: assignment, submission: submission)))
    }

    var body: some View {
        GeometryReader { geometry in
            let bottomInset = geometry.safeAreaInsets.bottom
            let minHeight = bottomInset + 58
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
        .avoidKeyboardArea()
    }

    @ViewBuilder
    var attemptToggle: some View {
        if let first = attempts.first, attempts.count == 1 {
            HStack {
                Text("Attempt \(attempt ?? 1)", bundle: .teacher).font(.regular14)
                Spacer()
                Text(first.submittedAt?.dateTimeString ?? "")
                    .font(.regular14)
                    .frame(minHeight: 24)
            }
            .foregroundColor(.textDark)
            .padding(EdgeInsets(top: 8, leading: 16, bottom: 4, trailing: 16))

        } else if let selected = attempts.first(where: { attempt == $0.attempt }) ?? attempts.last {
            Button(action: {
                showAttempts.toggle()
            }, label: {
                HStack {
                    Text("Attempt \(attempt ?? 1)", bundle: .teacher).font(.regular14)
                    Spacer()
                    Text(selected.submittedAt?.dateTimeString ?? "")
                        .font(.regular14)
                        .frame(minHeight: 24)
                    Image.arrowOpenDownLine
                        .resizable()
                        .frame(width: 14, height: 14)
                        .rotationEffect(.degrees(showAttempts ? 180 : 0))
                }
                .foregroundColor(.textDark)
                .padding(EdgeInsets(top: 8, leading: 16, bottom: 4, trailing: 16))
            })
        }
    }

    @ViewBuilder
    var attemptPicker: some View {
        if showAttempts {
            VStack(spacing: 0) {
                Picker(selection: Binding(get: { selected.attempt }, set: { newValue in
                    withTransaction(.exclusive()) {
                        NotificationCenter.default.post(name: .SpeedGraderAttemptPickerChanged, object: newValue)
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

    private func segmentedTitles() -> [String] {
        let filesString: String!
        if selected.type == .online_upload, let count = selected.attachments?.count, count > 0 {
            filesString = String(localized: "Files (\(count))", bundle: .teacher)
        } else {
            filesString = String(localized: "Files", bundle: .teacher)
        }

        return [
            String(localized: "Grades", bundle: .teacher),
            String(localized: "Comments", bundle: .teacher),
            filesString
        ]
    }

    @ViewBuilder
    func tools(bottomInset: CGFloat, isDrawer: Bool) -> some View {
        SegmentedPicker(
            segmentedTitles(),
            selectedIndex: Binding(
                get: { selectedIndex },
                set: { newValue in
                    selectedIndex = newValue ?? 0
                    if drawerState == .min {
                        snapDrawerTo(.mid)
                    }
                    let newTab = SubmissionGrader.GraderTab(rawValue: newValue ?? 0)!
                    withAnimation(.default) {
                        tab = newTab
                    }
                    controller.view.endEditing(true)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        focusedTab = tab
                    }
                }
            ),
            selectionAlignment: .bottom,
            content: { item, _ in
                Text(item)
                    .font(.regular14)
                    .foregroundColor(.textDark)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
            }
        )
        .onAppear {
            selectedIndex = 0
        }
        .identifier("SpeedGrader.toolPicker")
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
                    SubmissionGrades(assignment: assignment, containerHeight: geometry.size.height, submission: submission, rubricsViewModel: rubricsViewModel)
                        .clipped()
                    Spacer().frame(height: bottomInset)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .accessibilityElement(children: isGradesOnScreen ? .contain : .ignore)
                .accessibility(hidden: !isGradesOnScreen)
                .accessibilityFocused($focusedTab, equals: .grades)

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
                        commentLibrary: commentLibrary,
                        focusedTab: _focusedTab
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
                .accessibilityFocused($focusedTab, equals: .files)
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

extension NSNotification.Name {
    public static var SpeedGraderAttemptPickerChanged = NSNotification.Name("com.instructure.core.speedgrader-attempt-changed")
}
