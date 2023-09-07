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
import SwiftUI

final class DownloadsContentViewModel: ObservableObject {

    // MARK: - Injections -

    private var storageManager: OfflineStorageManager = .shared
    private var downloadsManager: OfflineDownloadsManager = .shared

    // MARK: - Properties -

    @Published var content: [OfflineDownloaderEntry] = []
    @Published var error: String = ""
    @Published var deleting: Bool = false

    let courseDataModel: CourseStorageDataModel
    var onDeleted: ((OfflineDownloaderEntry) -> Void)?
    var onDeletedAll: (() -> Void)?

    var color: UIColor {
        UIColor(hexString: courseDataModel.course.courseColor) ?? .oxford
    }

    init(
        content: [OfflineDownloaderEntry],
        courseDataModel: CourseStorageDataModel,
        onDeleted: ((OfflineDownloaderEntry) -> Void)? = nil,
        onDeletedAll: (() -> Void)? = nil
    ) {
        self.courseDataModel = courseDataModel
        self.onDeleted = onDeleted
        self.onDeletedAll = onDeletedAll
        self.content = self.sort(content: content)
    }

    func deleteAll() {
        deleting = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            do {
                try self.content.forEach {
                    try self.downloadsManager.delete(entry: $0)
                }
                self.content = []
                self.isDeleteAll()
            } catch {
                self.error = error.localizedDescription
            }
            self.deleting = false
        }
    }

    func delete(index: Int) {
        do {
            try downloadsManager.delete(entry: content[index])
            let entry = content.remove(at: index)
            onDeleted?(entry)
            isDeleteAll()
        } catch {
            self.error = error.localizedDescription
        }
    }

    func delete(entry: OfflineDownloaderEntry) {
        do {
            guard let index = content.firstIndex(where: {$0.dataModel.id  == entry.dataModel.id}) else {
                return
            }
            try downloadsManager.delete(entry: content[index])
            let entry = content.remove(at: index)
            onDeleted?(entry)
            isDeleteAll()
        } catch {
            self.error = error.localizedDescription
        }
    }

    private func isDeleteAll() {
        guard content.isEmpty else {
            return
        }
        onDeletedAll?()
    }

    func sort(content: [OfflineDownloaderEntry]) -> [OfflineDownloaderEntry] {
       let sortedContent = content.sorted {
            if let page0 = try? Page.fromOfflineModel($0.dataModel),
                  let page1 = try? Page.fromOfflineModel($1.dataModel) {
                return page0.title < page1.title
            }
            if let file0 = try? File.fromOfflineModel($0.dataModel),
                let file1 = try? File.fromOfflineModel($1.dataModel) {
                return file0.displayName ?? file0.filename  < file1.displayName ?? file1.filename
            }
            return false
        }
        return sortedContent
    }
}
