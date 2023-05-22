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
    @Published private(set) var chart: (other: CGFloat, app: CGFloat, free: CGFloat)
    public let appName: String
    public let a11yLabel: String

    init(interactor: DiskSpaceInteractor, app: AppEnvironment.App) {
        let diskSpace = interactor.getDiskSpace()
        let format = NSLocalizedString("%@ of %@ Used", bundle: .core, comment: "42 GB of 64 GB Used")
        let diskUsage = String.localizedStringWithFormat(format,
                                                         diskSpace.used.humanReadableFileSize,
                                                         diskSpace.total.humanReadableFileSize)
        self.diskUsage = diskUsage

        let appDiskSpace: CGFloat = max(0.01, Double(diskSpace.app) / Double(diskSpace.total))
        let otherDiskSpace: CGFloat = Double(diskSpace.otherApps) / Double(diskSpace.total)
        let chart = (other: otherDiskSpace,
                     app: appDiskSpace,
                     free: 1 - (otherDiskSpace + appDiskSpace))
        self.chart = chart

        let appName = "Canvas \(app.rawValue.capitalized)"
        self.appName = appName

        a11yLabel = [
            NSLocalizedString("Storage Info", comment: ""),
            diskUsage,
            NSLocalizedString("Other Apps", comment: "") + String(format: " %.1f%%", 100 * chart.other),
            appName + String(format: " %.1f%%", 100 * chart.app),
            NSLocalizedString("Remaining", comment: "") + String(format: " %.1f%%", 100 * chart.free),
        ].joined(separator: ",")
    }
}
