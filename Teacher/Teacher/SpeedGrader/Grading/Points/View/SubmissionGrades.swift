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

struct SubmissionGrades: View {
    let assignment: Assignment
    let containerHeight: CGFloat

    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller

    @State var showTooltip = false
    @State var sliderCleared = false
    @State var sliderExcused = false
    @State var sliderTimer: Timer?

    @ObservedObject var rubricsViewModel: RubricsViewModel
    @ObservedObject var gradeStatusViewModel: GradeStatusViewModel
    @ObservedObject var gradeViewModel: GradeViewModel

    var body: some View {
        if assignment.moderatedGrading {
            GeometryReader { geometry in
                ScrollView {
                    EmptyPanda(.Unsupported, message: Text("Moderated Grading Unsupported", bundle: .teacher))
                        .frame(minWidth: geometry.size.width, minHeight: geometry.size.height)
                }
            }
        } else {
            GeometryReader { geometry in ScrollView {
                VStack(spacing: 0) {
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
                                if gradeViewModel.state.isExcused {
                                    Text("Excused", bundle: .teacher)
                                } else if gradeViewModel.state.isGraded {
                                    Text(gradeViewModel.state.gradeText)
                                } else {
                                    Image.addSolid.foregroundStyle(.tint)
                                }
                            })
                            .accessibility(hint: Text("Prompts for an updated grade", bundle: .teacher))
                            .identifier("SpeedGrader.gradeButton")
                        }
                        if gradeViewModel.state.isGradedButNotPosted {
                            Image.offLine.foregroundColor(.textDanger)
                                .padding(.leading, 12)
                        }
                    }
                    .font(.heavy24)
                    .foregroundColor(gradeViewModel.state.hasLateDeduction ? .textDark : .textDarkest)
                    .padding(.horizontal, 16).padding(.vertical, 12)
                    if gradeViewModel.state.hasLateDeduction {
                        HStack {
                            Text("Late", bundle: .teacher)
                            Spacer()
                            Text(gradeViewModel.state.pointsDeductedText)
                        }
                        .font(.medium14).foregroundColor(.textWarning)
                        .padding(EdgeInsets(top: -10, leading: 16, bottom: -4, trailing: 16))
                        HStack {
                            Text("Final Grade", bundle: .teacher)
                            Spacer()
                            Text(gradeViewModel.state.finalGradeText)
                        }
                        .font(.heavy24).foregroundColor(.textDarkest)
                        .padding(.horizontal, 16).padding(.vertical, 12)
                    }

                    if !assignment.useRubricForGrading, assignment.gradingType == .points || assignment.gradingType == .percent {
                        slider
                    }

                    noGradeAndExcuseButtons

                    GradeStatusView(viewModel: gradeStatusViewModel)

                    if assignment.rubric?.isEmpty == false {
                        Divider().padding(.horizontal, 16)
                        RubricsView(
                            currentScore: rubricsViewModel.totalRubricScore,
                            containerFrameInGlobal: geometry.frame(in: .global),
                            viewModel: rubricsViewModel
                        )
                    }
                }.padding(.bottom, 16)
            } }
            .animation(.smooth, value: gradeStatusViewModel.isShowingDaysLateSection)
            .errorAlert(
                isPresented: $gradeViewModel.isShowingErrorAlert,
                presenting: gradeViewModel.errorAlertViewModel
            )

            if rubricsViewModel.commentingOnCriterionID != nil {
                commentEditor()
            }
        }
    }

    private var noGradeAndExcuseButtons: some View {
        HStack(spacing: 16) {
            SpeedGraderButton(title: String(localized: "No Grade")) {
                gradeViewModel.removeGrade()
            }
            .disabled(!gradeViewModel.state.isGraded && !gradeViewModel.state.isExcused)

            SpeedGraderButton(title: String(localized: "Excuse Student")) {
                gradeViewModel.excuseStudent()
            }
            .disabled(gradeViewModel.state.isExcused)
        }
        .paddingStyle(.horizontal, .standard)
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

    // MARK: Slider

    @ViewBuilder
    var slider: some View {
        let score = gradeViewModel.sliderValue
        let possible = assignment.pointsPossible ?? 0
        let tooltipText =
            sliderCleared ? Text("No Grade", bundle: .teacher) :
            sliderExcused ? Text("Excused", bundle: .teacher) :
            assignment.gradingType == .percent ? Text(round(score / max(possible, 0.01) * 100) / 100, number: .percent) :
            Text(score)
        let maxScore = assignment.gradingType == .percent ? 100 : possible

        HStack(spacing: 8) {
            VStack {
                Spacer()
                Text(0)
                    .frame(width: 30, height: 30)
                    .onTapGesture {
                        updateGrade(0)
                    }
                    .onLongPressGesture {
                        updateGrade(noMark: true)
                    }
                Spacer()
            }
            VStack {
                Spacer()
                ZStack {
                    // disables page swipe around the slider
                    Rectangle()
                        .contentShape(Rectangle())
                        .foregroundColor(.clear)
                        .gesture(DragGesture(minimumDistance: 0).onChanged { _ in })
                    GradeSlider(value: Binding(get: { score }, set: sliderChangedValue),
                                range: 0 ... (assignment.pointsPossible ?? 0),
                                showTooltip: showTooltip,
                                tooltipText: tooltipText,
                                score: score,
                                possible: possible,
                                onEditingChanged: sliderChangedState)
                }
            }
            Text(maxScore)
                .frame(width: 30, height: 30)
                .onTapGesture {
                    updateGrade(maxScore)
                }
                .onLongPressGesture {
                    updateGrade(excused: true)
                }
        }
        .font(.medium14).foregroundColor(.textDarkest)
        .padding(.horizontal, 16).padding(.vertical, 12)
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

    // MARK: Prompt for an updated grade

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
                field.text = gradeViewModel.state.gradeAlertText
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

    // MARK: Save
}

extension UIAlertController {

    @objc public func performOKAlertAction() {
        if let ok = actions.first(where: { $0.title == String(localized: "OK", bundle: .teacher) }) as? AlertAction {
            ok.handler?(ok)
            AppEnvironment.shared.router.dismiss(self)
        }
    }
}
