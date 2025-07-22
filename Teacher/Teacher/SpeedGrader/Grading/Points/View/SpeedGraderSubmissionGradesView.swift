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
    @ObservedObject var rubricsViewModel: RubricsViewModel

    var body: some View {
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
                commentsSection()
                if assignment.rubric?.isEmpty == false {
                    rubricsSection(geometry: geometry)
                }
            }
            .padding(.bottom, 16)
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
//            oldGradeRow
            gradeRow

            if gradeViewModel.shouldShowSlider {
                slider
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
        switch gradeViewModel.gradeInputType {
        case .pointsTextField:
            SwiftUI.EmptyView()
        case .percentageTextField:
            let score = gradeViewModel.gradeState.originalScoreWithoutMetric
            GradeInputTextFieldCell(
                title: String(localized: "Grade", bundle: .teacher),
                placeholder: String(localized: "Write percentage here", bundle: .teacher),
                suffix: "%",
                text: Binding(
                    get: { score ?? "" },
                    set: {
                        guard let value = Double($0) else { return }
                        gradeViewModel.setPercentGrade(value)
                    }
                ),
            )
        case .pointsDisplayOnly:
            SwiftUI.EmptyView()
        case .gradePicker:
            SwiftUI.EmptyView()
        case nil:
            SwiftUI.EmptyView()
        }
    }

    private var noGradeAndExcuseButtons: some View {
        HStack(spacing: 16) {
            SpeedGraderButton(title: String(localized: "No Grade", bundle: .teacher)) {
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
                .frame(width: 30, height: 30)
                .onTapGesture {
                    updateGrade(maxScore)
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
            } else if assignment.gradingType == .points {
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

    // MARK: Old Grade row and input dialog

    private var oldGradeRow: some View {
        HStack(spacing: 0) {
            Text("Grade", bundle: .teacher)
                .accessibilityAddTraits(.isHeader)
            Spacer()
            if gradeViewModel.isSaving {
                ProgressView()
                    .progressViewStyle(.indeterminateCircle(size: 24))
            } else if assignment.gradingType == .not_graded {
                Text("Not Graded", bundle: .teacher)
            } else {
                Button(action: promptNewGrade, label: {
                    if gradeViewModel.gradeState.isExcused {
                        Text("Excused", bundle: .teacher)
                    } else if gradeViewModel.gradeState.isGraded {
                        Text(gradeViewModel.gradeState.originalGradeText)
                    } else {
                        Image.addSolid.foregroundStyle(.tint)
                    }
                })
                .accessibility(hint: Text("Prompts for an updated grade", bundle: .teacher))
                .identifier("SpeedGrader.gradeButton")
            }
            if gradeViewModel.gradeState.isGradedButNotPosted {
                Image.offLine.foregroundColor(.textDanger)
                    .padding(.leading, 12)
            }
        }
        .font(.heavy24)
        .foregroundColor(.textDarkest)
        .padding(.horizontal, 16).padding(.vertical, 12)
    }

    func promptNewGrade() {
        var message: String?
        switch assignment.gradingType {
        case .gpa_scale:
            message = String(localized: "GPA", bundle: .teacher)
        case .letter_grade:
            message = String(localized: "Letter grade", bundle: .teacher)
        case .not_graded, .pass_fail:
            message = nil
        case .percent:
            message = String(localized: "Percent (%)", bundle: .teacher)
        case .points:
            message = assignment.outOfText
        }

        let prompt = UIAlertController(title: String(localized: "Customize Grade", bundle: .teacher), message: message, preferredStyle: .alert)
        if assignment.gradingType == .pass_fail {
            prompt.addAction(AlertAction(String(localized: "Complete", bundle: .teacher)) { _ in
                gradeViewModel.setPassFailGrade(complete: true)
            })
            prompt.addAction(AlertAction(String(localized: "Incomplete", bundle: .teacher)) { _ in
                gradeViewModel.setPassFailGrade(complete: false)
            })
        } else {
            prompt.addTextField { field in
                field.placeholder = ""
                field.returnKeyType = .done
                field.text = gradeViewModel.gradeState.gradeAlertText
                field.addTarget(prompt, action: #selector(UIAlertController.performOKAlertAction), for: .editingDidEndOnExit)
                field.accessibilityLabel = String(localized: "Grade", bundle: .teacher)
            }
        }
        if assignment.gradingType != .pass_fail {
            prompt.addAction(AlertAction(String(localized: "OK", bundle: .teacher)) { _ in
                var grade = prompt.textFields?[0].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                if assignment.gradingType == .percent, !grade.isEmpty, !grade.hasSuffix("%") {
                    grade = "\(grade)%"
                }
                gradeViewModel.setGrade(grade)
            })
        }
        prompt.addAction(AlertAction(String(localized: "Cancel", bundle: .teacher), style: .cancel))
        env.router.show(prompt, from: controller, options: .modal())
    }

    // MARK: - Comments

    private func commentsSection() -> some View {
        // TODO
        SwiftUI.EmptyView()
    }

    // MARK: - Rubrics

    private func rubricsSection(geometry: GeometryProxy) -> some View {
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

extension UIAlertController {

    @objc public func performOKAlertAction() {
        if let ok = actions.first(where: { $0.title == String(localized: "OK", bundle: .teacher) }) as? AlertAction {
            ok.handler?(ok)
            dismiss(animated: true)
        }
    }
}
