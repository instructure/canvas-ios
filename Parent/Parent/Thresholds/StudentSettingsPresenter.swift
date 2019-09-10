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

protocol StudentSettingsViewProtocol: ErrorViewController {
    func update()
    func didUpdateAlert()
}

class StudentSettingsPresenter {
    weak var view: StudentSettingsViewProtocol?
    var env: AppEnvironment
    var studentID: String

    lazy var thresholds = env.subscribe(GetAlertThresholds(studentID: studentID)) { [weak self] in
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
        let u = CreateAlertThreshold(userID: studentID, value: value, alertType: alertType)
        u.fetch(environment: env, force: true) { [weak self] result, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.view?.showError(error)
                    return
                }
                self?.update()
            }
        }
    }

    func updateAlert(value: String, alertType: AlertThresholdType, thresholdID: String) {
        let u = UpdateAlertThreshold(thresholdID: thresholdID, value: value, alertType: alertType)
        u.fetch(environment: env, force: true) { [weak self] result, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.view?.showError(error)
                    return
                }
                self?.view?.didUpdateAlert()
            }
        }
    }

    func removeAlert(alertID: String) {
        let u = RemoveAlertThreshold(thresholdID: alertID)
        u.fetch(environment: env, force: true) { [weak self] result, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.view?.showError(error)
                    return
                }
                self?.update()
            }
        }
    }

    func thresholdForType(_ type: AlertThresholdType) -> Core.AlertThreshold? {
        let matchingThresholds = thresholds.filter { threshold -> Bool in
            return threshold.type == type
        }

        return matchingThresholds.first
    }
}
