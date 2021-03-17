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

struct RubricAssessor: View {
    let assignment: Assignment
    let submission: Submission
    let currentScore: Double
    @Binding var comment: String
    @Binding var commentID: String?
    @Binding var assessments: APIRubricAssessmentMap {
        didSet {
            rubricAssessmentDidChange()
        }
    }

    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller

    @State private var isSaving = false
    @State private var assessmentsChangedDuringUpload = false

    var body: some View {
        HStack() {
            VStack(alignment: .leading, spacing: 0) {
                Text("Rubric")
                    .font(.heavy24).foregroundColor(.textDarkest)
                Text("\(currentScore, specifier: "%g") out of \(assignment.rubricPointsPossible ?? 0, specifier: "%g")")
                    .font(.medium14).foregroundColor(.textDark)
            }
            Spacer()

            if isSaving {
                CircleProgress(size: 24)
            }
        }
            .padding(.horizontal, 16).padding(.vertical, 12)

        VStack(spacing: 12) {
            ForEach(assignment.rubric ?? [], id: \.id) { criteria in
                RubricCriteriaAssessor(criteria: criteria)
            }
        }
            .multilineTextAlignment(.leading)
            .padding(.horizontal, 16)
    }

    func RubricCriteriaAssessor(criteria: Rubric) -> some View { VStack(alignment: .leading, spacing: 0) {
        let assessment = assessments[criteria.id] ?? submission.rubricAssessments?[criteria.id].map {
            APIRubricAssessment(comments: $0.comments, points: $0.points, rating_id: $0.ratingID)
        }

        HStack { Spacer() }
        Text(criteria.desc)
            .font(.semibold16).foregroundColor(.textDarkest)
        if criteria.ignoreForScoring {
            Text("This criterion will not impact the score.")
                .font(.regular12).foregroundColor(.textDark)
                .padding(.top, 2)
        }

        FlowStack(spacing: UIOffset(horizontal: 8, vertical: 8)) { leading, top in
            if !assignment.freeFormCriterionCommentsOnRubric, let ratings = criteria.ratings {
                ForEach(ratings.reversed(), id: \.id) { rating in
                    let isSelected = assessment?.rating_id == rating.id
                    let value = Text((isSelected ? assessment?.points : nil) ?? rating.points)
                    CircleToggle(isOn: Binding(get: { isSelected }, set: { newValue in
                        assessments[criteria.id] = newValue ? APIRubricAssessment(
                            comments: assessment?.comments,
                            points: rating.points,
                            rating_id: rating.id
                        ) : APIRubricAssessment(comments: assessment?.comments)
                    }), tooltip: rating.desc) {
                        value
                    }
                        .accessibility(value: value)
                        .accessibility(label: rating.desc.isEmpty ? value : Text(rating.desc))
                        .alignmentGuide(.leading, computeValue: leading)
                        .alignmentGuide(.top, computeValue: top)
                }
            }

            let customGrade = (assignment.freeFormCriterionCommentsOnRubric || assessment?.rating_id == nil)
                ? assessment?.points : nil
            CircleToggle(isOn: Binding(get: { customGrade != nil }, set: { newValue in
                if newValue {
                    promptCustomGrade(criteria, assessment: assessment)
                } else {
                    assessments[criteria.id] = APIRubricAssessment(comments: assessment?.comments)
                }
            })) {
                if let grade = customGrade {
                    Text(grade)
                } else {
                    Image.addSolid
                }
            }
                .accessibility(label: Text("Customize Grade"))
                .alignmentGuide(.leading, computeValue: leading)
                .alignmentGuide(.top, computeValue: top)
        }
            .padding(.top, 8)

        let showAdd = assignment.freeFormCriterionCommentsOnRubric && assessment?.comments?.isEmpty != false
        let showLong = criteria.longDesc.isEmpty == false
        if showAdd || showLong {
            HStack(spacing: 6) {
                if showAdd {
                    Button(action: { withAnimation(.default) {
                        comment = ""
                        commentID = criteria.id
                    } }, label: {
                        Text("Add Comment")
                            .font(.medium14).foregroundColor(.accentColor)
                    })
                        .identifier("SpeedGrader.Rubric.\(criteria.id).addCommentButton")
                }
                if showAdd, showLong {
                    Text(verbatim: "•")
                        .font(.regular12).foregroundColor(.textDark)
                }
                if showLong {
                    Button(action: {
                        let web = CoreWebViewController()
                        web.title = criteria.desc
                        web.webView.loadHTMLString(criteria.longDesc)
                        web.addDoneButton(side: .right)
                        env.router.show(web, from: controller, options: .modal(embedInNav: true))
                    }, label: {
                        Text("View Long Description")
                            .font(.medium14).foregroundColor(.accentColor)
                    })
                }
            }
                .padding(.top, 8)
        }

        if let comments = assessment?.comments, !comments.isEmpty {
            HStack {
                Text(comments)
                    .font(.regular14).foregroundColor(.textDarkest)
                    .padding(.horizontal, 12).padding(.vertical, 8)
                    .background(CommentBackground()
                        .fill(Color.backgroundLight)
                    )
                Spacer()
                Button(action: { withAnimation(.default) {
                    comment = comments
                    commentID = criteria.id
                } }, label: {
                    Text("Edit")
                        .font(.medium14).foregroundColor(.accentColor)
                })
            }
                .padding(.top, 8)
        }
    } }

    struct CircleToggle<Content: View>: View {
        let content: Content
        @Binding var isOn: Bool
        let tooltip: String

        @GestureState var showTooltip = false

        init(isOn: Binding<Bool>, tooltip: String = "", @ViewBuilder content: () -> Content) {
            self.content = content()
            self._isOn = isOn
            self.tooltip = tooltip
        }

        var body: some View {
            content
                .font(.medium20)
                .foregroundColor(isOn ? Color(Brand.shared.buttonPrimaryText) : .textDark)
                .frame(minWidth: 48, minHeight: 48, maxHeight: 48)
                .background(isOn ?
                    RoundedRectangle(cornerRadius: 24).fill(Color(Brand.shared.buttonPrimaryBackground)) :
                    nil
                )
                .background(!isOn ?
                    RoundedRectangle(cornerRadius: 24).stroke(Color.borderMedium) :
                    nil
                )
                .accessibility(addTraits: isOn ? [ .isButton, .isSelected ] : .isButton)
                .onTapGesture { isOn.toggle() }
                .gesture(LongPressGesture(minimumDuration: .infinity)
                    .updating($showTooltip) { _, state, transation in
                        transation.animation = .spring(response: 0.2, dampingFraction: 0.6)
                        state = true
                    }
                )
                .overlay(!showTooltip || tooltip.isEmpty ? nil :
                    GeometryReader { geometry in
                        let screenWidth = UIScreen.main.bounds.width
                        let maxWidth = min(600, screenWidth - 32)
                        let maxHeight: CGFloat = 300
                        let midX = geometry.frame(in: .global).midX
                        Text(tooltip)
                            .foregroundColor(.textLightest)
                            .padding(8)
                            .background(RoundedRectangle(cornerRadius: 5).fill(Color.backgroundDarkest))
                            .offset(x: geometry.size.width / 2) // start with align leading to circle's center
                            .alignmentGuide(.leading) { size in
                                min(midX - 16, // don't go more left than 16 from leading
                                    max(size.width - (screenWidth - midX) + 16, // 16 from trailing
                                        size.width / 2
                                ))
                            }
                            .alignmentGuide(.bottom) { size in size.height + maxHeight + 8 }
                            .frame(width: maxWidth, height: maxHeight, alignment: .bottomLeading)
                    }
                        .transition(.scale),
                    alignment: .bottomLeading
                )
        }
    }

    func promptCustomGrade(_ criteria: Rubric, assessment: APIRubricAssessment?) {
        let format = NSLocalizedString("out_of_g_pts", bundle: .core, comment: "")
        let message = String.localizedStringWithFormat(format, criteria.points)
        let prompt = UIAlertController(title: NSLocalizedString("Customize Grade", comment: ""), message: message, preferredStyle: .alert)
        prompt.addTextField { field in
            field.placeholder = ""
            field.returnKeyType = .done
            field.addTarget(prompt, action: #selector(UIAlertController.performOKAlertAction), for: .editingDidEndOnExit)
        }
        prompt.addAction(AlertAction(NSLocalizedString("OK", comment: "")) { _ in
            let text = prompt.textFields?[0].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            assessments[criteria.id] = APIRubricAssessment(
                comments: assessment?.comments,
                points: DoubleFieldRow.formatter.number(from: text)?.doubleValue
            )
        })
        prompt.addAction(AlertAction(NSLocalizedString("Cancel", comment: ""), style: .cancel))
        env.router.show(prompt, from: controller, options: .modal())
    }

    private func rubricAssessmentDidChange() {
        if isSaving {
            assessmentsChangedDuringUpload = true
        } else {
            uploadRubricAssessments()
        }
    }

    private func uploadRubricAssessments() {
        if assessments.isEmpty {
            isSaving = false
            return
        }

        isSaving = true
        let prevAssessments = submission.rubricAssessments // create map only once
        var nextAssessments: APIRubricAssessmentMap = [:]

        for criteria in assignment.rubric ?? [] {
            nextAssessments[criteria.id] = assessments[criteria.id] ?? prevAssessments?[criteria.id].map {
                APIRubricAssessment(comments: $0.comments, points: $0.points, rating_id: $0.ratingID)
            }
        }

        GradeSubmission(
            courseID: assignment.courseID,
            assignmentID: assignment.id,
            userID: submission.userID,
            rubricAssessment: nextAssessments
        ).fetch { _, _, error in performUIUpdate {
            handleUploadFinished(error: error)
        } }
    }

    private func handleUploadFinished(error: Error?) {
        if assessmentsChangedDuringUpload {
            assessmentsChangedDuringUpload = false
            uploadRubricAssessments()
            return
        }

        isSaving = false

        if let error = error {
            showError(error)
        }
    }

    private func showError(_ error: Error) {
        let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(AlertAction(NSLocalizedString("OK", comment: ""), style: .default))
        env.router.show(alert, from: controller, options: .modal())
    }
}
