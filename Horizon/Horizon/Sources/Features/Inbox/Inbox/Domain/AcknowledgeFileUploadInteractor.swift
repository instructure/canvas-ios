//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

import Core
import Combine
import Foundation

protocol AcknowledgeFileUploadInteractor {
    func acknowledgeUpload(of file: File)
}

class AcknowledgeFileUploadInteractorLive: AcknowledgeFileUploadInteractor {
    // MARK: Private
    private var observations = [String: NSKeyValueObservation]()
    private var subscriptions: Set<AnyCancellable> = []

    // MARK: Dependencies
    private let api: API

    // MARK: Init
    init(api: API = AppEnvironment.shared.api) {
        self.api = api
    }

    // MARK: Inputs
    func acknowledgeUpload(of file: File) {
        guard let createdAt = file.createdAt?.description else {
            return
        }
        let observation = file.observe(\.url) { [weak self] file, _ in
            guard let self = self,
                  let url = file.url else {
                return
            }
            api.makeRequest(url, method: .get)
                .sink()
                .store(in: &subscriptions)
            self.observations[createdAt]?.invalidate()
        }
        observations[createdAt] = observation
    }
}
