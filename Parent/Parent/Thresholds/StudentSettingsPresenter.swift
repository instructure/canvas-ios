//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

import Foundation
import Core

protocol StudentSettingsViewProtocol: class {
    func update()
    func didUpdateAlert()
}

class StudentSettingsPresenter {
    weak var view: StudentSettingsViewProtocol?
    var env: AppEnvironment
    var studentID: String

    private var createUseCase: Store<CreateAlertThreshold>?
    private var removeUseCase: Store<RemoveAlertThreshold>?
    private var updateUseCase: Store<UpdateAlertThreshold>?

    private lazy var thresholds = env.subscribe(GetAlertThresholds(studentID: studentID)) { [weak self] in
        self?.update()
    }

    init(environment: AppEnvironment = .shared, view: StudentSettingsViewProtocol, studentID: String) {
        self.env = environment
        self.view = view
        self.studentID = studentID
    }

    func viewIsReady() {
        thresholds.exhaust(while: { _ in true })
    }

    func update() {
        view?.update()
    }

    func createAlert(value: String?, alertType: AlertThresholdType) {
        let useCase = CreateAlertThreshold(userID: studentID, value: value, alertType: alertType)
        createUseCase = env.subscribe(useCase) { [weak self] in
            self?.update()
        }
        createUseCase?.refresh(force: true)
    }

    func updateAlert(value: String, alertType: AlertThresholdType, thresholdID: String) {
        updateUseCase = env.subscribe(UpdateAlertThreshold(thresholdID: thresholdID, value: value, alertType: alertType) ) { [weak self] in
            if self?.updateUseCase?.pending == false {
                self?.view?.didUpdateAlert()
            }
        }
        updateUseCase?.refresh(force: true)
    }

    func removeAlert(alertID: String) {
        removeUseCase = env.subscribe(RemoveAlertThreshold(thresholdID: alertID)) { [weak self] in
            if self?.removeUseCase?.pending == false {
                self?.update()
            }
        }
        removeUseCase?.refresh(force: true)
    }

    func thresholdForType(_ type: AlertThresholdType) -> Core.AlertThreshold? {
        let matchingThresholds = thresholds.filter { threshold -> Bool in
            return threshold.type == type
        }

        return matchingThresholds.first
    }
}
