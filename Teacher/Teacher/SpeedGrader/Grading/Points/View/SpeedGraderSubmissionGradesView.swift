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

struct SpeedGraderSubmissionGradesView: View {
    let assignment: Assignment
    let containerHeight: CGFloat

    let attempt: Binding<Int>
    let fileID: Binding<String?>

    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller

    // slider
    @State private var gradeSliderViewModel = GradeSliderViewModel()
    @State var showTooltip = false
    @State var sliderCleared = false
    @State var sliderExcused = false
    @State var sliderTimer: Timer?

    @ObservedObject var gradeViewModel: SpeedGraderSubmissionGradesViewModel
    @ObservedObject var gradeStatusViewModel: GradeStatusViewModel
    @ObservedObject var commentListViewModel: SubmissionCommentListViewModel
    @ObservedObject var rubricsViewModel: RubricsViewModel
    @ObservedObject var redesignedRubricsViewModel: RedesignedRubricsViewModel

    private enum FocusedInput: Hashable {
        case gradeRow
        case points
        case comment
        case rubric(Int)
    }
    @FocusState private var focusedInput: FocusedInput?

    var body: some View {
        ScrollViewReader { scrollViewProxy in
            InstUI.BaseScreen(
                state: gradeViewModel.state,
                config: .init(
                    refreshable: false,
                    emptyPandaConfig: .init(
                        scene: SpacePanda(), // TODO: use `.Unsupported`
                        title: String(localized: "Moderated Grading Unsupported", bundle: .teacher)
                    )
                )
            ) { geometry in
                VStack(spacing: 0) {
                    gradingSection()
                    commentsSection(scrollViewProxy: scrollViewProxy)
                    if assignment.rubric?.isEmpty == false {
                        rubricsSection(geometry: geometry)
                    }

                    if ExperimentalFeature.hideRedesignedRubricsGradingList.isEnabled {
                        Spacer().frame(height: 16)
                    }
                }
            }
            .scrollDismissesKeyboard(keyboardDismissalMode)
        }
    }

    private var keyboardDismissalMode: ScrollDismissesKeyboardMode {
        switch focusedInput {
        case .gradeRow, .points:
            return .never
        default:
            return .interactively
        }
    }

    private func gradingSection() -> some View {
        VStack(spacing: 0) {
            gradingInputViews()

            if gradeViewModel.shouldShowGradeSummary {
                GradeSummaryView(
                    pointsRow: gradeViewModel.pointsRowModel,
                    latePenaltyRow: gradeViewModel.latePenaltyRowModel,
                    finalGradeRow: gradeViewModel.finalGradeRowModel
                )
                .paddingStyle(.horizontal, .standard)
            }
        }
    }

    // MARK: - Grading Inputs

    private func gradingInputViews() -> some View {
        VStack(spacing: 0) {
            gradeRow
                .focused($focusedInput, equals: .gradeRow)

            if gradeViewModel.shouldShowPointsInput {
                gradeInputTextField(
                    title: String(localized: "Points", bundle: .core),
                    inputType: .points,
                    textValue: gradeViewModel.gradeState.originalScoreWithoutMetric ?? ""
                )
                .focused($focusedInput, equals: .points)
            }

            if gradeViewModel.shouldShowSlider {
                slider
            }

            if gradeViewModel.shouldShowSelector {
                gradeInputSelector()
            }

            noGradeAndExcuseButtons

            GradeStatusView(viewModel: gradeStatusViewModel)
        }
        .animation(.smooth, value: gradeStatusViewModel.isShowingDaysLateSection)
        .errorAlert(
            isPresented: $gradeViewModel.isShowingErrorAlert,
            presenting: gradeViewModel.errorAlertViewModel
        )
    }

    @ViewBuilder
    private var gradeRow: some View {
        let title = String(localized: "Grade", bundle: .teacher)
        let gradeState = gradeViewModel.gradeState

        switch gradeViewModel.gradeInputType {
        case .pointsTextField:
            gradeInputTextField(
                title: title,
                inputType: .points,
                textValue: gradeState.originalGradeWithoutMetric ?? ""
            )
        case .percentageTextField:
            gradeInputTextField(
                title: title,
                inputType: .percentage,
                textValue: gradeState.originalGradeWithoutMetric ?? ""
            )
        case .pointsDisplayOnly:
            gradeInputDisplayOnlyView(
                title: title,
                textValue: gradeState.originalScoreWithoutMetric ?? GradeFormatter.BlankPlaceholder.oneDash.stringValue,
                suffix: gradeState.isExcused ? nil : "/ \(gradeState.pointsPossibleText)"
            )
        case .gradePicker:
            SpeedGraderPickerCell(
                title: title,
                placeholder: String(localized: "Select Grade", bundle: .teacher),
                identifierGroup: "SpeedGrader.GradeInputPickerItem",
                allOptions: gradeState.gradeOptions,
                selectOption: gradeViewModel.selectGradeOption,
                didSelectOption: gradeViewModel.didSelectGradeOption,
                isSaving: gradeViewModel.isSavingGrade
            )
            .accessibilityLabel(
                [title, String.accessibiltyLetterGrade(gradeState.originalGrade)]
                    .joined(separator: ",")
            )
        case .statusDisplayOnly:
            gradeInputDisplayOnlyView(
                title: title,
                textValue: gradeState.isExcused
                    ? String(localized: "Excused", bundle: .teacher)
                    : String(localized: "Not Graded", bundle: .teacher),
                suffix: nil
            )
        case nil:
            SwiftUI.EmptyView()
        }
    }

    @ViewBuilder
    private func gradeInputTextField(
        title: String,
        inputType: GradeInputTextFieldCell.InputType,
        textValue: String
    ) -> some View {
        let gradeState = gradeViewModel.gradeState

        GradeInputTextFieldCell(
            title: title,
            inputType: inputType,
            pointsPossible: gradeState.pointsPossibleText,
            isExcused: gradeState.isExcused,
            text: Binding(
                get: { textValue },
                set: { gradeViewModel.setGradeFromTextField($0, inputType: inputType) }
            ),
            isSaving: gradeViewModel.isSavingGrade
        )
    }

    @ViewBuilder
    private func gradeInputDisplayOnlyView(
        title: String,
        textValue: String,
        suffix: String?
    ) -> some View {
        HStack(alignment: .center, spacing: 8) {
            Text(title)
                .textStyle(.cellLabel)

            HStack(alignment: .center, spacing: 8) {
                Text(textValue)
                    .font(.regular16, lineHeight: .fit)
                    .foregroundStyle(.textDark)
                    .frame(maxWidth: .infinity, alignment: .trailing)

                if let suffix {
                    Text(suffix)
                        .font(.regular16, lineHeight: .fit)
                        .foregroundStyle(.textDark)
                }
            }
            .swapWithSpinner(onLoading: gradeViewModel.isSavingGrade, alignment: .trailing)
        }
        .paddingStyle(set: .standardCell)
    }

    @ViewBuilder
    private func gradeInputSelector() -> some View {
        VStack(spacing: 0) {
            InstUI.Divider()
            SingleSelectionView(
                title: nil,
                identifierGroup: "SpeedGrader.GradeInputSelectorItem",
                allOptions: gradeViewModel.gradeState.gradeOptions,
                selectOption: gradeViewModel.selectGradeOption,
                didSelectOption: gradeViewModel.didSelectGradeOption
            )
            .paddingStyle(.bottom, .standard)
        }
    }

    private var noGradeAndExcuseButtons: some View {
        HStack(spacing: 16) {
            let noGradeTitle = gradeViewModel.gradeState.gradingType == .not_graded
                ? String(localized: "Reset Status", bundle: .teacher)
                : String(localized: "No Grade", bundle: .teacher)
            SpeedGraderButton(title: noGradeTitle) {
                gradeViewModel.removeGrade()
            }
            .disabled(gradeViewModel.isNoGradeButtonDisabled)

            SpeedGraderButton(title: String(localized: "Excuse Student", bundle: .teacher)) {
                gradeViewModel.excuseStudent()
            }
            .disabled(gradeViewModel.gradeState.isExcused)
        }
        .paddingStyle(.horizontal, .standard)
    }

    // MARK: Slider

    @ViewBuilder
    var slider: some View {
        let score = gradeViewModel.sliderValue
        let possible = assignment.pointsPossible ?? 0
        let tooltipText =
            sliderCleared ? Text("No Grade", bundle: .teacher) :
            sliderExcused ? Text("Excused", bundle: .teacher) :
            assignment.gradingType == .percent ? Text(round(score / max(possible, 0.01) * 100) / 100, number: .percent) :
            Text(gradeSliderViewModel.formatScore(score, maxPoints: possible))
        let maxScore = assignment.gradingType == .percent ? 100 : possible

        HStack(spacing: 8) {
            Text(0)
                .foregroundStyle(.tint)
                .frame(width: 30, height: 30)
                .onTapGesture {
                    updateGrade(0)
                }
            ZStack {
                // disables page swipe around the slider
                Rectangle()
                    .contentShape(Rectangle())
                    .foregroundColor(.clear)
                    .gesture(DragGesture(minimumDistance: 0).onChanged { _ in })
                GradeSlider(value: Binding(get: { score }, set: sliderChangedValue),
                            maxValue: assignment.pointsPossible ?? 0,
                            showTooltip: showTooltip,
                            tooltipText: tooltipText,
                            score: score,
                            possible: possible,
                            onEditingChanged: sliderChangedState,
                            viewModel: gradeSliderViewModel)
            }
            Text(maxScore)
                .foregroundStyle(.tint)
                .frame(width: 30, height: 30)
                .onTapGesture {
                    updateGrade(possible)
                }
        }
        .font(.medium14).foregroundColor(.textDarkest)
        .padding(.horizontal, 16).padding(.vertical, 14)
    }

    func updateGrade(excused: Bool? = nil, noMark: Bool? = false, _ grade: Double? = nil) {
        if excused == true {
            gradeViewModel.excuseStudent()
        } else if noMark == true {
            gradeViewModel.removeGrade()
        } else if let grade = grade {
            gradeViewModel.setPointsGrade(grade)
        }
    }

    func sliderChangedState(_ editing: Bool) {
        withAnimation(.default) { showTooltip = editing }
        if editing == false {
            let value = gradeViewModel.sliderValue
            sliderTimer?.invalidate()
            sliderTimer = nil
            if sliderCleared {
                gradeViewModel.removeGrade()
            } else if sliderExcused {
                updateGrade(excused: true, 0)
            } else if assignment.gradingType == .percent {
                let percentValue = round(value / max(assignment.pointsPossible ?? 0, 0.01) * 100)
                gradeViewModel.setPercentGrade(percentValue)
            } else { // slider uses points in all other cases where visible (points, gpa, letterGrade)
                gradeViewModel.setPointsGrade(value)
            }
        }
    }

    func sliderChangedValue(_ value: Double) {
        let previous = gradeViewModel.sliderValue
        gradeViewModel.sliderValue = value
        guard previous != value || sliderTimer == nil else { return }
        sliderTimer?.invalidate()
        sliderTimer = nil
        sliderCleared = false
        sliderExcused = false
        if value == 0 {
            sliderTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
                sliderCleared = true
                sliderExcused = false
                UISelectionFeedbackGenerator().selectionChanged()
            }
        } else if value == assignment.pointsPossible ?? 0 {
            sliderTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
                sliderCleared = false
                sliderExcused = true
                UISelectionFeedbackGenerator().selectionChanged()
            }
        }
    }

    // MARK: - Comments

    private func commentsSection(scrollViewProxy: ScrollViewProxy) -> some View {
        comments
            .id("comments")
            .focused($focusedInput, equals: .comment)
            .onChange(of: focusedInput) {
                if focusedInput == .comment {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation {
                            scrollViewProxy.scrollTo("comments", anchor: .bottom)
                        }
                    }
                }
            }
    }

    @ViewBuilder
    private var comments: some View {
        let commentCount = commentListViewModel.commentCount
        let header = HStack(spacing: InstUI.Styles.Padding.cellIconText.rawValue) {
            Image.discussionLine
                .scaledIcon()
                .foregroundStyle(.tint)
                .accessibilityHidden(true)

            Text("Comments (\(commentCount))", bundle: .teacher)
                .foregroundStyle(.textDarkest)
                .font(.semibold16)
                .accessibilityLabel(
                    [String(localized: "Comments", bundle: .core),
                     String.localizedNumberOfItems(commentCount)
                    ].joined(separator: ", ")
                )
                .accessibilityAddTraits(.isHeader)
        }
        let content = SubmissionCommentListView(
            viewModel: commentListViewModel,
            attempt: attempt,
            fileID: fileID
        )

        VStack(spacing: 0) {
            InstUI.Divider()

            if assignment.hasRubrics {
                DisclosureGroup {
                    content
                } label: {
                    header
                }
                .disclosureGroupStyle(InstUI.SectionDisclosureStyle(headerConfig: .init(
                    paddingSet: .iconCell,
                    accessoryIconSize: 24,
                    hasDividerBelowHeader: true
                )))
            } else {
                header
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .paddingStyle(set: .iconCell)

                InstUI.Divider()

                content
            }
        }
        .padding(.top, 16)
    }

    // MARK: - Rubrics

    @ViewBuilder
    private func rubricsSection(geometry: GeometryProxy) -> some View {

        if ExperimentalFeature.hideRedesignedRubricsGradingList.isEnabled {

            VStack(spacing: 0) {
                RubricsView(
                    currentScore: rubricsViewModel.totalRubricScore,
                    containerFrameInGlobal: geometry.frame(in: .global),
                    viewModel: rubricsViewModel
                )

                if rubricsViewModel.commentingOnCriterionID != nil {
                    commentEditor()
                }
            }

        } else {
            RedesignedRubricsView(viewModel: redesignedRubricsViewModel)
        }
    }

    private func commentEditor() -> some View {
        OldCommentEditorView(
            text: $rubricsViewModel.criterionComment,
            shouldShowCommentLibrary: false,
            showCommentLibrary: .constant(false),
            action: rubricsViewModel.saveComment,
            containerHeight: containerHeight,
            contextColor: Color(Brand.shared.primary)
        )
        .padding(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
        .background(Color.backgroundLight)
    }
}

#if DEBUG
#Preview {
    SpeedGraderAssembly.makeSpeedGraderViewControllerPreview(state: .data)
}
#endif
