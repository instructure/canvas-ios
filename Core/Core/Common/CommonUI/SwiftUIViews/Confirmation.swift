//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

import Combine
import SwiftUI

public final class ConfirmationViewModel<Option: Hashable> {

    public enum ViewType {
        case alert
        case confirmationDialog
    }

    public struct ButtonModel {
        public let title: String
        public let buttonRole: ButtonRole?
        public let option: Option

        public init(title: String, isDestructive: Bool = false, option: Option) {
            self.title = title
            self.buttonRole = isDestructive ? .destructive : nil
            self.option = option
        }
    }

    public let title: String
    public let message: String?
    public let cancelButtonTitle: String
    public let confirmButtons: [ButtonModel]
    public let viewType: ViewType

    private var subscribers: [PassthroughSubject<Option, Never>] = []

    public init(
        title: String,
        message: String? = nil,
        cancelButtonTitle: String,
        confirmButtons: [ButtonModel],
        viewType: ViewType = .confirmationDialog
    ) {
        self.title = title
        self.message = message
        self.cancelButtonTitle = cancelButtonTitle
        self.confirmButtons = confirmButtons
        self.viewType = viewType
    }

    /// Convenience initializer which sets `Option` type via the `confirmValue` parameter.
    /// - Returns: A ViewModel with an `.alert` view type, matching the parameters.
    public convenience init(
        title: String,
        message: String?,
        cancelButtonTitle: String,
        confirmButtonTitle: String,
        isDestructive: Bool = false,
        confirmValue: Option
    ) {
        self.init(
            title: title,
            message: message,
            cancelButtonTitle: cancelButtonTitle,
            confirmButtons: [.init(
                title: confirmButtonTitle,
                isDestructive: isDestructive,
                option: confirmValue
            )],
            viewType: .alert
        )
    }

    /// Convenience initializer which doesn't care about the `Option` type.
    /// - Returns: A ViewModel with an `.alert` view type, matching the parameters.
    public convenience init(
        title: String,
        message: String?,
        cancelButtonTitle: String,
        confirmButtonTitle: String,
        isDestructive: Bool = false
    ) where Option == Bool {
        self.init(
            title: title,
            message: message,
            cancelButtonTitle: cancelButtonTitle,
            confirmButtonTitle: confirmButtonTitle,
            isDestructive: isDestructive,
            confirmValue: true
        )
    }

    /// To be used as a placeholder where storing the ViewModel as an optional is not feasible.
    /// - Returns: A ViewModel for an empty dialog.
    public convenience init() {
        self.init(title: "", cancelButtonTitle: "", confirmButtons: [])
    }

    /**
     - Returns: A Publisher that finishes when either of the confirmation view's button is pressed.
     If the user confirmed an option the publisher will send the selected option before completing.
     */
    public func userConfirmsOption() -> AnyPublisher<Option, Never> {
        let subject = PassthroughSubject<Option, Never>()
        subscribers.append(subject)
        return subject.eraseToAnyPublisher()
    }

    /**
     - Parameter passdownValue: A value (usually coming from upstream) to be sent downstream together with the selected option.
     - Returns: A Publisher that finishes when either of the confirmation view's button is pressed.
     If the user confirmed an option the publisher will send the selected option before completing.
     */
    public func userConfirmsOption<T>(passdownValue: T) -> AnyPublisher<(Option, T), Never> {
        userConfirmsOption()
            .map { ($0, passdownValue) }
            .eraseToAnyPublisher()
    }

    /**
     - Returns: A Publisher that finishes when either of the confirmation view's button is pressed.
     If the user confirmed the action the publisher will send a value before completing.
     */
    public func userConfirmation() -> AnyPublisher<Void, Never> {
        userConfirmsOption()
            .map { _ in }
            .eraseToAnyPublisher()
    }

    /**
     - Parameter passdownValue: A value (usually coming from upstream) to be sent downstream together with the selected option.
     - Returns: A Publisher that finishes when either of the confirmation view's button is pressed.
     If the user confirmed the action the publisher will send a value before completing.
     */
    public func userConfirmation<T>(passdownValue: T) -> AnyPublisher<T, Never> {
        userConfirmation()
            .map { passdownValue }
            .eraseToAnyPublisher()
    }

    // Don't use this function outside of this class. Internal access level is required because of tests.
    internal func notifyCompletion(option: Option?) {
        for subscriber in subscribers {
            if let option {
                subscriber.send(option)
            }
            subscriber.send(completion: .finished)
        }

        subscribers.removeAll()
    }
}

public extension View {
    @ViewBuilder
    func confirmation<Option: Hashable>(
        isPresented: Binding<Bool>,
        presenting viewModel: ConfirmationViewModel<Option>
    )
    -> some View {
        switch viewModel.viewType {
        case .alert:
            alert(
                viewModel.title,
                isPresented: isPresented,
                actions: {
                    ForEach(viewModel.confirmButtons, id: \.option) { button in
                        Button(button.title,
                               role: button.buttonRole,
                               action: { viewModel.notifyCompletion(option: button.option) })
                    }

                    Button(viewModel.cancelButtonTitle,
                           role: .cancel,
                           action: { viewModel.notifyCompletion(option: nil) })
                },
                message: {
                    if let message = viewModel.message {
                        Text(message)
                    }
                }
            )
        case .confirmationDialog:
            confirmationDialog(
                viewModel.title,
                isPresented: isPresented,
                titleVisibility: .visible,
                actions: {
                    ForEach(viewModel.confirmButtons, id: \.option) { button in
                        Button(button.title,
                               role: button.buttonRole,
                               action: { viewModel.notifyCompletion(option: button.option) })
                    }

                    Button(viewModel.cancelButtonTitle,
                           role: .cancel,
                           action: { viewModel.notifyCompletion(option: nil) })
                },
                message: {
                    if let message = viewModel.message {
                        Text(message)
                    }
                }
            )
        }
    }
}

#if DEBUG

struct ConfirmationPreview: PreviewProvider {

    class ConfirmDemoViewModel: ObservableObject {
        @Published var statusText = ""
        @Published var isShowingConfirmationAlert = false
        @Published var isShowingConfirmationDialog = false

        let confirmAlert = ConfirmationViewModel(
            title: "Confirm Selection",
            message: "This action needs to be confirmed",
            cancelButtonTitle: "Not Now",
            confirmButtonTitle: "I Confirm",
            isDestructive: true
        )
        let confirmDialog = ConfirmationViewModel(
            title: "Confirm Deletion",
            message: "This action needs to be confirmed by selecting one of these options",
            cancelButtonTitle: "Not Now",
            confirmButtons: [
                .init(title: "Confirm with Option 1", isDestructive: true, option: 1),
                .init(title: "Confirm with Option 2", isDestructive: true, option: 2),
                .init(title: "Confirm with Option 3", isDestructive: true, option: 3)
            ]
        )

        let didTapShowAlert = PassthroughSubject<Void, Never>()
        let didTapShowDialog = PassthroughSubject<Void, Never>()

        public init() {
            unowned let unownedSelf = self

            didTapShowAlert
                .handleEvents(receiveOutput: {
                    unownedSelf.statusText = ""
                    unownedSelf.isShowingConfirmationAlert = true
                })
                .flatMap { unownedSelf.confirmAlert.userConfirmation() }
                .map { "Confirmed via alert!" }
                .assign(to: &$statusText)

            didTapShowDialog
                .handleEvents(receiveOutput: {
                    unownedSelf.statusText = ""
                    unownedSelf.isShowingConfirmationDialog = true
                })
                .flatMap { unownedSelf.confirmDialog.userConfirmsOption() }
                .map { "Confirmed via dialog option \($0)!" }
                .assign(to: &$statusText)
        }
    }

    struct ConfirmDemoView: View {
        @StateObject var viewModel = ConfirmDemoViewModel()

        var body: some View {
            VStack {
                Text(viewModel.statusText).frame(height: 20)
                Spacer()

                Button {
                    viewModel.didTapShowAlert.send()
                } label: {
                    Text(verbatim: "Show confirmation alert")
                }
                .confirmation(
                    isPresented: $viewModel.isShowingConfirmationAlert,
                    presenting: viewModel.confirmAlert
                )
                Spacer()

                Button {
                    viewModel.didTapShowDialog.send()
                } label: {
                    Text(verbatim: "Show confirmation dialog")
                }
                .confirmation(
                    isPresented: $viewModel.isShowingConfirmationDialog,
                    presenting: viewModel.confirmDialog
                )
                Spacer()
            }
        }
    }

    static var previews: some View {
        ConfirmDemoView()
    }
}

#endif
