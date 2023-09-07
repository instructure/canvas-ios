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

import mobile_offline_downloader_ios

public struct DownloadableItem {

    private(set) var objectId: String
    private(set) var userInfo: String
    private(set) var assetType: String
    private(set) var object: OfflineDownloadTypeProtocol
    private(set) var course: Course

     init(
        objectId: String,
        userInfo: String,
        assetType: String,
        object: OfflineDownloadTypeProtocol,
        course: Course
    ) {
        self.objectId = objectId
        self.userInfo = userInfo
        self.assetType = assetType
        self.object = object
        self.course = course
    }
}

protocol DownloadableItems: UIViewController {
    func subscribe(
        detailViewController: DownloadableViewController,
        assetType: GetModuleItemSequenceRequest.AssetType
    )
}

extension DownloadableItems {
    func subscribe(
        detailViewController: DownloadableViewController,
        assetType: GetModuleItemSequenceRequest.AssetType
    ) {
        if let moduleDetail = detailViewController as? ModuleItemDetailsViewController {
            subscribe(moduleDetail: moduleDetail, assetType: assetType) { [weak detailViewController] item in
                detailViewController?.set(downloadableItem: item)
            }
        } else if let pageDetail = detailViewController as? PageDetailsViewController {
            subscribe(pageDetail: pageDetail, assetType: assetType) { [weak detailViewController] item in
                detailViewController?.set(downloadableItem: item)
            }
        } else if let fileDetail = detailViewController as? FileDetailsViewController {
            subscribe(fileDetail: fileDetail, assetType: assetType) { [weak detailViewController] item in
                detailViewController?.set(downloadableItem: item)
            }
        }
    }

    private func subscribe(
        moduleDetail: ModuleItemDetailsViewController,
        assetType: GetModuleItemSequenceRequest.AssetType,
        completion: @escaping ((DownloadableItem) -> Void)
    ) {
        moduleDetail.onEmbedContainer = { [weak moduleDetail, weak self] vc in
            if assetType == .page, let detailPage = vc as? PageDetailsViewController {
                detailPage.updated = { page, course in
                    guard var url = page.htmlURL  else {
                        return
                    }
                    debugLog("subscribe detail PAGE", url, assetType.rawValue, page.title, course.name ?? "")
                    if DownloadsHelper.getCourseId(userInfo: url.absoluteString) == nil {
                        url = url.appendingPathComponent("/courses/\(course.id)")
                    }
                    let item = DownloadableItem(
                        objectId: page.id,
                        userInfo: url.absoluteString,
                        assetType: assetType.rawValue,
                        object: page,
                        course: course
                    )
                    completion(item)
                }
            } else if assetType == .file, let fileDetails = vc as? FileDetailsViewController {
                fileDetails.updated = { file, course in
                    guard var url = file.url  else {
                        return
                    }
                    debugLog("subscribe detail File", url, assetType.rawValue, file.displayName ?? "", course.name ?? "")
                    if DownloadsHelper.getCourseId(userInfo: url.absoluteString) == nil {
                        url = url.appendingPathComponent("/courses/\(course.id)")
                    }
                    let item = DownloadableItem(
                        objectId: file.id ?? UUID.string,
                        userInfo: url.absoluteString,
                        assetType: assetType.rawValue,
                        object: file,
                        course: course
                    )
                    completion(item)
                }
            } else if assetType == .moduleItem || vc is LTIViewController {
                if let moduleDetail = moduleDetail {
                    self?.create(moduleDetail: moduleDetail, completion: completion)
                }
            }
        }
    }

    private func create(
        moduleDetail: ModuleItemDetailsViewController,
        completion: @escaping ((DownloadableItem) -> Void)
    ) {
        guard let moduleItem = moduleDetail.item,
              var url = moduleDetail.item?.htmlURL,
              let course = moduleDetail.course.first else {
            return
        }
        if DownloadsHelper.getCourseId(userInfo: url.absoluteString) == nil {
            url = url.appendingPathComponent("/courses/\(course.id)")
        }
        let item = DownloadableItem(
            objectId: moduleItem.id,
            userInfo: url.absoluteString,
            assetType: GetModuleItemSequenceRequest.AssetType.moduleItem.rawValue,
            object: moduleItem,
            course: course
        )
        completion(item)
    }

    private func subscribe(
        pageDetail: PageDetailsViewController,
        assetType: GetModuleItemSequenceRequest.AssetType,
        completion: @escaping ((DownloadableItem) -> Void)
    ) {
        pageDetail.updated = { page, course in
            guard var url = page.htmlURL else {
                return
            }
            debugLog("subscribe detail PAGE", url, assetType.rawValue, page.title, course.name ?? "")
            if DownloadsHelper.getCourseId(userInfo: url.absoluteString) == nil {
                url = url.appendingPathComponent("/courses/\(course.id)")
            }
            let item = DownloadableItem(
                objectId: page.id,
                userInfo: url.absoluteString,
                assetType: assetType.rawValue,
                object: page,
                course: course
            )
            completion(item)
        }
    }

    private func subscribe(
        fileDetail: FileDetailsViewController,
        assetType: GetModuleItemSequenceRequest.AssetType,
        completion: @escaping ((DownloadableItem) -> Void)
    ) {
        fileDetail.updated = { file, course in
            guard var url = file.url  else {
                return
            }
            debugLog("subscribe detail File", url, assetType.rawValue, file.displayName ?? "", course.name ?? "")
            if DownloadsHelper.getCourseId(userInfo: url.absoluteString) == nil {
                url = url.appendingPathComponent("/courses/\(course.id)")
            }
            let item = DownloadableItem(
                objectId: file.id ?? UUID.string,
                userInfo: url.absoluteString,
                assetType: assetType.rawValue,
                object: file,
                course: course
            )
            completion(item)
        }
    }
}
