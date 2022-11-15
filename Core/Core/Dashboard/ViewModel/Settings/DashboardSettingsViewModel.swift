//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

public class DashboardSettingsViewModel: ObservableObject {
    // MARK: - Inputs & Outputs
    @Published public var showGrades: Bool
    @Published public var colorOverlay: Bool

    // MARK: - Outputs
    @Published public private(set) var layout: DashboardLayout
    public let isGradesSwitchVisible: Bool
    public let isColorOverlaySwitchVisible: Bool
    public let popoverSize: CGSize

    // MARK: - Inputs
    public let setLayout = PassthroughSubject<DashboardLayout, Never>()

    // MARK: - Private
    private let interactor: DashboardSettingsInteractor
    private var subscriptions = Set<AnyCancellable>()

    public init(interactor: DashboardSettingsInteractor) {
        self.interactor = interactor
        self.layout = interactor.layout.value
        self.showGrades = interactor.showGrades.value
        self.colorOverlay = interactor.colorOverlay.value
        self.isGradesSwitchVisible = interactor.isGradesSwitchVisible
        self.isColorOverlaySwitchVisible = interactor.isColorOverlaySwitchVisible
        self.popoverSize = {
            let largeLayout = interactor.isGradesSwitchVisible && interactor.isColorOverlaySwitchVisible
            return CGSize(width: 350, height: largeLayout ? 440 : 390)
        }()
        bindInteractorOutputsToSelf()
        bindUserInputsToInteractor()
    }

    private func bindInteractorOutputsToSelf() {
        interactor
            .layout
            .removeDuplicates()
            .assign(to: &$layout)
    }

    private func bindUserInputsToInteractor() {
        setLayout
            .subscribe(interactor.layout)
            .store(in: &subscriptions)

        $showGrades
            .subscribe(interactor.showGrades)
            .store(in: &subscriptions)

        $colorOverlay
            .subscribe(interactor.colorOverlay)
            .store(in: &subscriptions)
    }
}
