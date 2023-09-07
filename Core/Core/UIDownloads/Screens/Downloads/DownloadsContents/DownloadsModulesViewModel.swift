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

final class DownloadsModulesViewModel: ObservableObject {

    class Section {
        let id: String
        let title: String
        let position: Int
        var content: [OfflineDownloaderEntry]

        init(id: String, title: String, position: Int, content: [OfflineDownloaderEntry]) {
            self.id = id
            self.title = title
            self.position = position
            self.content = content
        }
    }

    // MARK: - Injections -

    private var storageManager: OfflineStorageManager = .shared
    private var downloadsManager: OfflineDownloadsManager = .shared

    // MARK: - Properties -

    @Published var content: [Section] = []
    @Published var error: String = ""
    @Published var deleting: Bool = false

    let courseDataModel: CourseStorageDataModel
    var onDeleted: ((OfflineDownloaderEntry) -> Void)?
    var onDeletedAll: (() -> Void)?

    var color: UIColor {
        UIColor(hexString: courseDataModel.course.courseColor) ?? .oxford
    }

    init(
        entries: [OfflineDownloaderEntry],
        courseDataModel: CourseStorageDataModel,
        onDeleted: ((OfflineDownloaderEntry) -> Void)? = nil,
        onDeletedAll: (() -> Void)? = nil
    ) {
        self.courseDataModel = courseDataModel
        self.onDeleted = onDeleted
        self.onDeletedAll = onDeletedAll
        self.content = self.configureSections(entries: entries)
    }

    private func configureSections(entries: [OfflineDownloaderEntry]) -> [Section] {
        var sections: [Section] = []

        entries.forEach {
            guard let moduleItem = try? ModuleItem.fromOfflineModel($0.dataModel) else {
                return
            }

            guard let module = moduleItem.module else {
                if let index = sections.firstIndex(where: { $0.id.isEmpty }) {
                    sections[index].content.append($0)
                } else {
                    sections.append(
                        Section(
                            id: "",
                            title: "",
                            position: -1,
                            content: [$0]
                        )
                    )
                }
                return
            }

            if let index = sections.firstIndex(where: {$0.id == module.id}) {
                sections[index].content.append($0)
            } else {
                sections.append(
                    Section(
                        id: module.id,
                        title: module.name,
                        position: module.position,
                        content: [$0]
                    )
                )
            }
        }
        sections.sort(by: { $0.position < $1.position })
        sections.forEach { section in
            section.content.sort {
                guard let moduleItem0 = try? ModuleItem.fromOfflineModel($0.dataModel),
                      let moduleItem1 = try? ModuleItem.fromOfflineModel($1.dataModel) else {
                    return false
                }
                return moduleItem0.position < moduleItem1.position
            }
        }
        return sections
    }

    func deleteAll() {
        deleting = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            do {
                try self.content.flatMap { $0.content }.forEach {
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

    func delete(section: Int, row: Int) {
        guard content.indices.contains(section),
              content[section].content.indices.contains(row) else {
            return
        }

        do {
            let entry = content[section].content[row]
            try downloadsManager.delete(entry: entry)
            content[section].content.remove(at: row)
            if content[section].content.isEmpty {
                content.remove(at: section)
            }
            onDeleted?(entry)
            isDeleteAll()
        } catch {
            self.error = error.localizedDescription
        }
    }

    func delete(entry: OfflineDownloaderEntry) {
        content.enumerated().forEach { sectionIndex, section in
            section.content.enumerated().forEach { rowIndex, contentEntry in
                if entry.dataModel.id == contentEntry.dataModel.id {
                    do {
                        try downloadsManager.delete(entry: entry)
                        content[sectionIndex].content.remove(at: rowIndex)
                        if content[sectionIndex].content.isEmpty {
                            content.remove(at: sectionIndex)
                        }
                        onDeleted?(entry)
                        isDeleteAll()
                    } catch {
                        self.error = error.localizedDescription
                    }
                }
            }
        }
    }

    private func isDeleteAll() {
        guard content.isEmpty else {
            return
        }
        onDeletedAll?()
    }
}
