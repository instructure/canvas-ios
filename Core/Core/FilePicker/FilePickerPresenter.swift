//
// Copyright (C) 2019-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation

protocol FilePickerViewProtocol: class {
    func update()
    func showError(_ error: Error)
}

class FilePickerPresenter {
    let env: AppEnvironment
    let batch: UploadBatch
    weak var view: FilePickerViewProtocol?

    init(environment: AppEnvironment = .shared, batchID: String = UUID.string) {
        self.env = environment
        self.batch = UploadBatch(environment: environment, batchID: batchID, callback: nil)
    }

    func viewIsReady() {
        batch.subscribe { [weak self] _ in
            self?.view?.update()
        }
    }

    func add(url: URL) {
        do {
            try batch.addFile(url)
        } catch {
            view?.showError(error)
        }
    }
}
