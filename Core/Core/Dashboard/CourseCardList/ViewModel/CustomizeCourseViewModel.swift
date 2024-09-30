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

class CustomizeCourseViewModel: ObservableObject {
    public struct AlertMessage: Identifiable, Equatable {
        public var id: String { message }
        public let message: String
    }

    // MARK: - Outputs
    @Published public private(set) var isLoading: Bool = false
    public let colors: KeyValuePairs<UIColor, String>
    public let courseImage: URL?
    public let hideColorOverlay: Bool
    public let dismissView = PassthroughSubject<Void, Never>()

    // MARK: - Inputs
    public let didTapDone = PassthroughSubject<Void, Never>()

    // MARK: - Inputs / Outputs
    @Published public var color: UIColor
    public var courseName: String
    @Published public var errorMessage: AlertMessage?

    // MARK: - Private State
    private let courseId: String
    private var originalCourseName: String
    private var originalCourseColor: UIColor
    private var subscriptions = Set<AnyCancellable>()

    init(
        courseId: String,
        courseImage: URL?,
        courseColor: UIColor,
        courseName: String,
        hideColorOverlay: Bool,
        courseColorsInteractor: CourseColorsInteractor = CourseColorsInteractorLive()
    ) {
        self.courseId = courseId
        self.courseImage = courseImage
        self.color = courseColor
        self.originalCourseColor = courseColor
        self.courseName = courseName
        self.originalCourseName = courseName
        self.hideColorOverlay = hideColorOverlay
        self.colors = courseColorsInteractor.colors
        saveCourseData(on: didTapDone)
    }

    func shouldShowCheckmark(for color: UIColor) -> Bool {
        self.color == color
    }

    private func saveCourseData(on tapAction: PassthroughSubject<Void, Never>) {
        tapAction
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.isLoading = true
            })
            .flatMap { [weak self] in
                guard let self else {
                    return Just<Result<Void, Error>>(.success)
                        .eraseToAnyPublisher()
                }

                return Publishers.CombineLatest(
                    saveCourseName(),
                    saveCourseColor()
                )
                .mapToVoid()
                .mapToResult()
                .eraseToAnyPublisher()
            }
            .sink { [weak self] result in
                switch result {
                case .success:
                    self?.dismissView.send(())
                case .failure(let error):
                    self?.isLoading = false
                    self?.errorMessage = AlertMessage(message: error.localizedDescription)
                }
            }
            .store(in: &subscriptions)
    }

    private func saveCourseName() -> AnyPublisher<Void, Error> {
        guard courseName != originalCourseName else {
            return Just(())
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        let useCase = UpdateCourseNickname(
            courseID: courseId,
            nickname: courseName
        )
        return ReactiveStore(useCase: useCase)
            .getEntities()
            .mapToVoid()
            .handleEvents(receiveOutput: { [weak self] _ in
                guard let self else { return }
                /// Update to prevent this being sent out again if the color update fails and the user re-tries.
                self.originalCourseName = self.courseName
            })
            .eraseToAnyPublisher()
    }

    private func saveCourseColor() -> AnyPublisher<Void, Error> {
        guard color != originalCourseColor else {
            return Just(())
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        let useCase = UpdateCustomColor(
            context: .course(courseId),
            color: color.variantForLightMode.hexString
        )
        return ReactiveStore(useCase: useCase)
            .getEntities()
            .mapToVoid()
            .handleEvents(receiveOutput: { [weak self] _ in
                guard let self else { return }
                /// Update to prevent this being sent out again if the name update fails and the user re-tries.
                self.originalCourseColor = color
            })
            .eraseToAnyPublisher()
    }
}
