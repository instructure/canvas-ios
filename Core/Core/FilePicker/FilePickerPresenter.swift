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

protocol FilePickerViewProtocol: class {
    func update()
    func showError(_ error: Error)
}

class FilePickerPresenter {
    let env: AppEnvironment
    let batchID: String
    lazy var files = UploadManager.shared.subscribe(batchID: batchID) { [weak self] in
        self?.view?.update()
    }
    weak var view: FilePickerViewProtocol?

    init(environment: AppEnvironment = .shared, batchID: String = UUID.string) {
        self.env = environment
        self.batchID = batchID
    }

    func viewIsReady() {
        files.refresh()
    }

    func add(url: URL) {
        UploadManager.shared.viewContext.perform {
            do {
                try UploadManager.shared.add(url: url, batchID: self.batchID)
            } catch {
                self.view?.showError(error)
            }
        }
    }
}
