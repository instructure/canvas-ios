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

public enum ColorContext {
    case course(courseID: String)
    case group(groupID: String, parentCourseID: String?)
}

public protocol ContextColorsInteractor {

    func getContextColor(
        _ colorContext: ColorContext,
        ignoreCache: Bool
    ) -> AnyPublisher<UIColor, Never>
}

public class ContextColorsInteractorLive: ContextColorsInteractor {

    public init() {}

    public func getContextColor(
        _ colorContext: ColorContext,
        ignoreCache: Bool
    ) -> AnyPublisher<UIColor, Never> {
        switch colorContext {
        case .course(let courseID):
            return getElementaryStateForCourse(
                courseID: courseID,
                ignoreCache: ignoreCache
            )
            .flatMap { isElementary in
                self.getContextColor(
                    Context(.course, id: courseID),
                    isElementary: isElementary,
                    ignoreCache: ignoreCache
                )
            }
            .eraseToAnyPublisher()

        case .group(let groupID, let parentCourseID):
            let isElementary: AnyPublisher<Bool, Never> = {
                if let parentCourseID {
                    return getElementaryStateForCourse(courseID: parentCourseID, ignoreCache: ignoreCache)
                } else {
                    return Just(false).eraseToAnyPublisher()
                }
            }()

            return isElementary
                .flatMap { isElementary in
                    self.getContextColor(
                        Context(.group, id: groupID),
                        isElementary: isElementary,
                        ignoreCache: ignoreCache
                    )
                }
                .eraseToAnyPublisher()
        }
    }

    // MARK: - Private Helpers

    private func getElementaryStateForCourse(
        courseID: String,
        ignoreCache: Bool
    ) -> AnyPublisher<Bool, Never> {
        let useCase = GetDashboardCards(showOnlyTeacherEnrollment: false)
        return ReactiveStore(useCase: useCase)
            .getEntities(ignoreCache: ignoreCache)
            .map { dashboardCards in
                let cardForCourse = dashboardCards.first { $0.id == courseID }
                return cardForCourse?.isK5Subject ?? false
            }
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }

    private func getContextColor(
        _ context: Context,
        isElementary: Bool = false,
        ignoreCache: Bool = false
    ) -> AnyPublisher<UIColor, Never> {
        getColors(ignoreCache: ignoreCache)
            .map { colorObjects -> CDContextColor? in
                colorObjects.first(where: { $0.canvasContextID == context.canvasContextID })
            }
            .map { colorObject -> UIColor in
                return .contextColor(
                    elementaryCourseColorHex: colorObject?.elementaryCourseColorHex,
                    contextColorHex: colorObject?.contextColorHex,
                    isElementary: isElementary
                )
            }
            .eraseToAnyPublisher()
    }

    private func getColors(
        ignoreCache: Bool = false
    ) -> AnyPublisher<[CDContextColor], Never> {
        let colorsUseCase = GetCDContextColorsUseCase()
        return ReactiveStore(useCase: colorsUseCase)
            .getEntities(ignoreCache: ignoreCache, keepObservingDatabaseChanges: true)
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
}

extension UIColor {

    static var defaultContextColor: UIColor { .ash }
    static var defaultElementaryColor: UIColor { .oxford }

    /// - parameters:
    ///   - courseColorHex: The course color assigned to an elementary course by the teacher.
    ///   - contextColorHex: The context's color that can be customized by the user.
    static func contextColor(
        elementaryCourseColorHex: String?,
        contextColorHex: String?,
        isElementary: Bool
    ) -> UIColor {
        let effectiveColorHex = isElementary ? elementaryCourseColorHex : contextColorHex

        guard let effectiveColor = UIColor(hexString: effectiveColorHex) else {
            return isElementary ? defaultElementaryColor : defaultContextColor
        }

        return effectiveColor.ensureContrast(against: backgroundLightest)
    }
}
