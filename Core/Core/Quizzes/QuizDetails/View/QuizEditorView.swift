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

public struct QuizEditorView<ViewModel: QuizEditorViewModelProtocol>: View {

    @Environment(\.appEnvironment.router) var router
    @Environment(\.viewController) var controller

    @ObservedObject private var viewModel: ViewModel

    @State var rceHeight: CGFloat = 60
    @State var rceCanSubmit = false
    @State var alert: AlertItem?

    public init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        form
            .navigationBarTitle(Text("Edit Quiz Details", bundle: .core), displayMode: .inline)
            .navBarItems(leading: cancelButton, trailing: {
                Button(action: doneTapped, label: {
                    Text("Done", bundle: .core).bold()
                })
                .disabled(viewModel.state != .ready)
            })
            .alert(item: $alert) { alert in
                switch alert {
                case .error(let error):
                    return Alert(title: Text(error.localizedDescription))
                case .removeOverride(let override):
                    return AssignmentOverridesEditor.alert(toRemove: override, from: $viewModel.assignmentOverrides)
                }
            }
            .onReceive(viewModel.showErrorPopup) {
                router.show($0, from: controller, options: .modal())
            }
    }

    enum AlertItem: Identifiable {
        case error(Error)
        case removeOverride(AssignmentOverridesEditor.Override)

        var id: String {
            switch self {
            case .error(let error):
                return error.localizedDescription
            case .removeOverride(let override):
                return "remove override \(override.id)"
            }
        }
    }

    var form: some View {
        EditorForm(isSpinning: viewModel.state == .loading) {
            switch viewModel.state {
            case .ready:
                titleSection
                basicSettingsSection
                attemptsSection
                oneQuestionSection
                accessCodeSection
                assignmentOverridesSection
            case .error(let errorMessage):
                EmptyPanda(.Unsupported, title: Text("Something went wrong"), message: Text(errorMessage))
            default:
                Spacer()
            }
        }
    }

    @ViewBuilder
    private func cancelButton() -> some View {
        if viewModel.isModallyPresented(viewController: controller.value) {
            Button(action: {
                router.dismiss(controller)
            }, label: {
                Text("Cancel", bundle: .core).fontWeight(.regular)
            })
        }
    }

    @ViewBuilder
    private var titleSection: some View {
        EditorSection(label: Text("Title", bundle: .core)) {
            CustomTextField(placeholder: Text("Add Title", bundle: .core),
                            text: $viewModel.title,
                            identifier: "QuizEditor.titleField",
                            accessibilityLabel: Text("Title", bundle: .core))
        }

        EditorSection(label: Text("Description", bundle: .core)) {
            RichContentEditor(
                placeholder: NSLocalizedString("Add description", comment: ""),
                a11yLabel: NSLocalizedString("Description", comment: ""),
                html: $viewModel.description,
                context: .course(viewModel.courseID),
                uploadTo: .context(.course(viewModel.courseID)),
                height: $rceHeight,
                canSubmit: $rceCanSubmit,
                error: Binding(get: {
                    if case .error(let error) = alert { return error }
                    return nil
                }, set: {
                    if let error = $0 { alert = .error(error) }
                })
            )
                .frame(height: max(200, rceHeight))
        }
    }

    @ViewBuilder
    private var basicSettingsSection: some View {
        EditorSection {
            quizTypeRow
            if (viewModel.shouldShowPublishedToggle) {
                Divider()
                ToggleRow(
                    label: Text("Publish", bundle: .core),
                    value: $viewModel.published)
            }
            if viewModel.assignmentGroup != nil {
                Divider()
                assignmentGroupRow
            }
            Divider()
            ToggleRow(
                label: Text("Shuffle Answers", bundle: .core),
                value: $viewModel.shuffleAnswers)
            Divider()
            ToggleRow(
                label: Text("Time Limit", bundle: .core),
                value: $viewModel.timeLimit)
            if viewModel.timeLimit {
                Divider()
                DoubleFieldRow(
                    label: Text("Length in minutes", bundle: .core),
                    placeholder: "--",
                    value: $viewModel.lengthInMinutes
                )
            }
        }
    }

    @ViewBuilder
    private var attemptsSection: some View {
        EditorSection {
            ToggleRow(
                label: Text("Allow Multiple Attempts", bundle: .core),
                value: $viewModel.allowMultipleAttempts)

            if viewModel.allowMultipleAttempts {
                Divider()
                scoreToKeepRow
                Divider()
                IntFieldRow(
                    label: Text("Allowed Attempts", bundle: .core),
                    placeholder: NSLocalizedString("Unlimited", bundle: .core, comment: ""),
                    value: $viewModel.allowedAttempts
                )
            }
        }
    }

    @ViewBuilder
    private var oneQuestionSection: some View {
        EditorSection {
            ToggleRow(
                label: Text("Show One Question at a Time", bundle: .core),
                value: $viewModel.oneQuestionAtaTime)
            if viewModel.oneQuestionAtaTime {
                Divider()
                ToggleRow(
                    label: Text("Lock Questions After Answering", bundle: .core),
                    value: $viewModel.lockQuestionAfterViewing)
            }
        }
    }

    @ViewBuilder
    private var accessCodeSection: some View {
        EditorSection {
            ToggleRow(
                label: Text("Require an Access Code", bundle: .core),
                value: $viewModel.requireAccessCode)
            if viewModel.requireAccessCode {
                Divider()
                TextFieldRow(
                    label: Text("Access Code", bundle: .core),
                    placeholder: NSLocalizedString("Enter code", comment: ""),
                    text: $viewModel.accessCode
                )
            }
        }
    }

    @ViewBuilder
    private var assignmentOverridesSection: some View {
        AssignmentOverridesEditor(
            courseID: viewModel.courseID,
            groupCategoryID: viewModel.assignment?.groupCategoryID,
            overrides: $viewModel.assignmentOverrides,
            toRemove: Binding(get: {
                if case .removeOverride(let override) = alert {
                    return override
                }
                return nil
            }, set: {
                alert = $0.map { AlertItem.removeOverride($0) }
            })
        )
    }

    @ViewBuilder
    private var quizTypeRow: some View {
        ButtonRow(action: {
            viewModel.quizTypeTapped(router: router, viewController: controller)
        }, content: {
            Text("Quiz Type", bundle: .core)
            Spacer()
            Text(viewModel.quizType.name)
                .font(.medium16).foregroundColor(.textDark)
            Spacer().frame(width: 16)
            DisclosureIndicator()
        })
    }

    @ViewBuilder
    private var assignmentGroupRow: some View {
        ButtonRow(action: {
            viewModel.assignmentGroupTapped(router: router, viewController: controller)
        }, content: {
            Text("Assignment Group", bundle: .core)
            Spacer()
            Text(viewModel.assignmentGroup?.name ?? "")
                .font(.medium16).foregroundColor(.textDark)
            Spacer().frame(width: 16)
            DisclosureIndicator()
        })
    }

    @ViewBuilder
    private var scoreToKeepRow: some View {
        ButtonRow(action: {
            viewModel.scoreToKeepTapped(router: router, viewController: controller)
        }, content: {
            Text("Quiz Score to Keep", bundle: .core)
            Spacer()
            Text(viewModel.scoreToKeep?.text ?? "")
                .font(.medium16).foregroundColor(.textDark)
            Spacer().frame(width: 16)
            DisclosureIndicator()
        })
    }

    func doneTapped() {
        controller.view.endEditing(true) // dismiss keyboard
        viewModel.doneTapped(router: router, viewController: controller)
    }
}

#if DEBUG

struct QuizEditor_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = QuizEditorViewModelPreview(
            state: .ready,
            courseID: "1",
            title: "Preview Quiz",
            description: "This is the quiz description",
            quizType: .practice_quiz,
            published: true,
            shuffleAnswers: false,
            timeLimit: true,
            lengthInMinutes: 123,
            allowMultipleAttempts: true,
            scoreToKeep: .keep_highest,
            allowedAttempts: 0,
            oneQuestionAtaTime: true,
            lockQuestionAfterViewing: true,
            requireAccessCode: true,
            accessCode: "Code"
        )
        QuizEditorView(viewModel: viewModel)
            .previewLayout(.sizeThatFits)

        QuizEditorView(viewModel: QuizEditorViewModelPreview(state: .error("Error")))
            .previewLayout(.sizeThatFits)
    }
}

#endif
