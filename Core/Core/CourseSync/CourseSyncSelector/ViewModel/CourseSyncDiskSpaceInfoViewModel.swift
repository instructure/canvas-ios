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

class CourseSyncDiskSpaceInfoViewModel: ObservableObject {
    @Published private(set) var diskUsage: String
    @Published private(set) var chart: (CGFloat, CGFloat, CGFloat)
    public let appName: String

    init(interactor: DiskSpaceInteractor, app: AppEnvironment.App) {
        let diskSpace = interactor.getDiskSpace()
        let format = NSLocalizedString("%@ of %@ Used", bundle: .core, comment: "42 GB of 64 GB Used")
        diskUsage = String.localizedStringWithFormat(format, diskSpace.used.humanReadableFileSize, diskSpace.total.humanReadableFileSize)

        let otherDiskSpace: CGFloat = Double(diskSpace.otherApps) / Double(diskSpace.total)
        let appDiskSpace: CGFloat = Double(diskSpace.app) / Double(diskSpace.total)
        chart = (otherDiskSpace,
                 appDiskSpace,
                 1 - (otherDiskSpace + appDiskSpace))

        appName = "Canvas \(app.rawValue.capitalized)"
    }
}
