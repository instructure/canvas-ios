//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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
import Network

public struct NWPathWrapper {
    var status: NWPath.Status
    var isExpensive: Bool

    public init(
        status: NWPath.Status,
        isExpensive: Bool
    ) {
        self.status = status
        self.isExpensive = isExpensive
    }

    init(from path: NWPath) {
        self.init(
            status: path.status,
            isExpensive: path.isExpensive
        )
    }
}

public class NWPathMonitorWrapper {
    let start: (_ queue: DispatchQueue) -> Void
    let cancel: () -> Void
    var updateHandler: ((NWPathWrapper) -> Void)?

    public init(
        start: @escaping (_ queue: DispatchQueue) -> Void,
        cancel: @escaping () -> Void
    ) {
        self.start = start
        self.cancel = cancel
    }

    public convenience init(from monitor: NWPathMonitor) {
        self.init(
            start: { monitor.start(queue: $0) },
            cancel: { monitor.cancel() }
        )

        monitor.pathUpdateHandler = { [weak self] path in
            self?.updateHandler?(NWPathWrapper(from: path))
        }
    }
}
