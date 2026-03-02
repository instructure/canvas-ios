//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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
import SDWebImage
import UIKit

public enum ImageCacheConfiguration {
    /// Maximum memory cache size in bytes (50 MB)
    private static let memoryMaxCost: Int = 52_428_800 // 50 * 1024 * 1024
    private static let memoryMaxCount: Int = 100
    /// Maximum disk cache size in bytes (100 MB)
    private static let diskMaxSize: UInt = 104_857_600 // 100 * 1024 * 1024
    private static let diskMaxAge: TimeInterval = 7 * 24 * 60 * 60

    private static var isConfigured = false
    private static var memoryWarningObserver: NSObjectProtocol?

    public static func configure() {
        guard !isConfigured else { return }
        isConfigured = true

        let imageCache = SDImageCache.shared
        imageCache.config.maxMemoryCost = UInt(memoryMaxCost)
        imageCache.config.maxMemoryCount = UInt(memoryMaxCount)
        imageCache.config.maxDiskSize = diskMaxSize
        imageCache.config.maxDiskAge = diskMaxAge

        let optionsProcessor = SDWebImageOptionsProcessor { _, options, context in
            var mutableOptions = options
            mutableOptions.insert(.scaleDownLargeImages)
            mutableOptions.insert(.queryMemoryData)
            return SDWebImageOptionsResult(options: mutableOptions, context: context)
        }
        SDWebImageManager.shared.optionsProcessor = optionsProcessor

        setupMemoryWarningObserver()
    }

    private static func setupMemoryWarningObserver() {
        memoryWarningObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { _ in
            clearMemoryCache()
        }
    }

    public static func clearMemoryCache() {
        SDImageCache.shared.clearMemory()
    }

    public static func clearExpiredDiskCache() {
        SDImageCache.shared.deleteOldFiles(completionBlock: nil)
    }

    public static func clearAllCache() {
        SDImageCache.shared.clearMemory()
        SDImageCache.shared.clearDisk(onCompletion: nil)
    }
}
