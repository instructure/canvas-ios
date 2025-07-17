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
    @ObservedObject var submission: Submission

    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller

    @State var isSaving = false

    @State var showTooltip = false
    @State var sliderCleared = false
    @State var sliderExcused = false
    @State var sliderTimer: Timer?
    @State var sliderValue: Double?

    @ObservedObject var rubricsViewModel: RubricsViewModel
    @ObservedObject var gradeStatusViewModel: GradeStatusViewModel

    var hasLateDeduction: Bool {
        submission.late &&
            (submission.pointsDeducted ?? 0) > 0 &&
            submission.grade?.isEmpty == false
    }

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
                        if isSaving {
                            ProgressView()
                                .progressViewStyle(.indeterminateCircle(size: 24))
                        } else if assignment.gradingType == .not_graded {
                            Text("Not Graded", bundle: .teacher)
                        } else {
                            Button(action: promptNewGrade, label: {
                                if submission.excused == true {
                                    Text("Excused", bundle: .teacher)
                                } else if submission.grade?.isEmpty == false {
                                    Text(GradeFormatter.longString(
                                        for: assignment,
                                        submission: submission,
                                        rubricScore: rubricsViewModel.isRubricScoreAvailable ? rubricsViewModel.totalRubricScore : nil,
                                        final: false
                                    ))
                                } else {
                                    Image.addSolid.foregroundStyle(.tint)
                                }
                            })
                            .accessibility(hint: Text("Prompts for an updated grade", bundle: .teacher))
                            .identifier("SpeedGrader.gradeButton")
                        }
                        if submission.grade?.isEmpty == false, submission.postedAt == nil {
                            Image.offLine.foregroundColor(.textDanger)
                                .padding(.leading, 12)
                        }
                    }
                    .font(.heavy24)
                    .foregroundColor(hasLateDeduction ? .textDark : .textDarkest)
                    .padding(.horizontal, 16).padding(.vertical, 12)
                    if hasLateDeduction, let deducted = submission.pointsDeducted {
                        HStack {
                            Text("Late", bundle: .teacher)
                            Spacer()
                            Text("\(-deducted, specifier: "%g") pts", bundle: .core)
                        }
                        .font(.medium14).foregroundColor(.textWarning)
                        .padding(EdgeInsets(top: -10, leading: 16, bottom: -4, trailing: 16))
                        HStack {
                            Text("Final Grade", bundle: .teacher)
                            Spacer()
                            Text(GradeFormatter.longString(for: assignment, submission: submission, final: true))
                        }
                        .font(.heavy24).foregroundColor(.textDarkest)
                        .padding(.horizontal, 16).padding(.vertical, 12)
                    }
                    if !assignment.useRubricForGrading, assignment.gradingType == .points || assignment.gradingType == .percent {
                        slider
                    }

                    GradeStatusView(viewModel: gradeStatusViewModel)

                    if assignment.rubric?.isEmpty == false {
                        Divider().padding(.horizontal, 16)
                        RubricsView(
                            currentScore: rubricsViewModel.totalRubricScore,
                            containerFrameInGlobal: geometry.frame(in: .global),
                            viewModel: rubricsViewModel
                        )
                        .background(Color.backgroundLight)
                    }
                }.padding(.bottom, 16)
            } }
            .animation(.smooth, value: gradeStatusViewModel.isShowingDaysLateSection)

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

    // MARK: Slider

    @ViewBuilder
    var slider: some View {
        let score = sliderValue ?? submission.enteredScore ?? submission.score ?? 0
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
        var gradeString: String?
        if excused == true {
            gradeString = nil
        } else if noMark == true {
            gradeString = ""
        } else {
            if let grade = grade {
                gradeString = String(grade)
            }
        }
        saveGrade(excused: excused, gradeString)
        sliderValue = grade
    }

    func sliderChangedState(_ editing: Bool) {
        withAnimation(.default) { showTooltip = editing }
        if editing == false, let value = sliderValue {
            sliderTimer?.invalidate()
            sliderTimer = nil
            if sliderCleared {
                saveGrade("")
            } else if sliderExcused {
                updateGrade(excused: true, 0)
            } else if assignment.gradingType == .percent {
                saveGrade("\(round(value / max(assignment.pointsPossible ?? 0, 0.01) * 100))%")
            } else if assignment.gradingType == .points {
                saveGrade(String(value))
            }
        }
    }

    func sliderChangedValue(_ value: Double) {
        let previous = sliderValue.map { $0 }
        sliderValue = value
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
        sliderValue = nil
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
            prompt.addAction(AlertAction(String(localized: "Complete", bundle: .teacher)) { _ in saveGrade("complete") })
            prompt.addAction(AlertAction(String(localized: "Incomplete", bundle: .teacher)) { _ in saveGrade("incomplete") })
        } else {
            prompt.addTextField { field in
                field.placeholder = ""
                field.returnKeyType = .done
                field.text = submission.excused == true ? String(localized: "Excused", bundle: .teacher) :
                    hasLateDeduction ? submission.enteredGrade : submission.grade
                field.addTarget(prompt, action: #selector(UIAlertController.performOKAlertAction), for: .editingDidEndOnExit)
                field.accessibilityLabel = String(localized: "Grade", bundle: .teacher)
            }
        }
        prompt.addAction(AlertAction(String(localized: "No Grade", bundle: .teacher)) { _ in saveGrade("") })
        if submission.excused != true {
            prompt.addAction(AlertAction(String(localized: "Excuse Student", bundle: .teacher)) { _ in saveGrade(excused: true) })
        }
        if assignment.gradingType != .pass_fail {
            prompt.addAction(AlertAction(String(localized: "OK", bundle: .teacher)) { _ in
                saveGrade(prompt.textFields?[0].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
            })
        }
        prompt.addAction(AlertAction(String(localized: "Cancel", bundle: .teacher), style: .cancel))
        env.router.show(prompt, from: controller, options: .modal())
    }

    // MARK: Save

    func saveGrade(excused: Bool? = nil, _ grade: String? = nil) {
        guard !(submission.excused == true && grade == String(localized: "Excused", bundle: .teacher)) else { return }
        var grade = grade
        if assignment.gradingType == .percent, let percent = grade, !percent.hasSuffix("%") {
            grade = "\(percent)%"
        }

        isSaving = true
        GradeSubmission(
            courseID: assignment.courseID,
            assignmentID: assignment.id,
            userID: submission.userID,
            excused: excused,
            grade: grade
        ).fetch { _, _, error in performUIUpdate {
            isSaving = false
            if let error = error { showError(error) }
        } }
    }

    func showError(_ error: Error) {
        let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(AlertAction(String(localized: "OK", bundle: .teacher), style: .default))
        env.router.show(alert, from: controller, options: .modal())
    }
}

extension UIAlertController {

    @objc public func performOKAlertAction() {
        if let ok = actions.first(where: { $0.title == String(localized: "OK", bundle: .teacher) }) as? AlertAction {
            ok.handler?(ok)
            AppEnvironment.shared.router.dismiss(self)
        }
    }
}
