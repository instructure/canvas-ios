//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

public typealias EmptyHandler = () -> Void

class Persistency {
    static var persistencyFileName = "PageViewEvents.dat"
    // swiftlint:disable:next identifier_name
    private static var __once: () = {
        let fileManager = FileManager.default
        let appSupportDirectoryURL = FileManager.appSupportDirectory()
        if let URL = appSupportDirectoryURL {
            if !fileManager.fileExists(atPath: URL.absoluteString) {
                do {
                    try fileManager.createDirectory(at: URL, withIntermediateDirectories: true, attributes: nil)
                } catch let error as NSError {
                    print("Cannot create persistancy directory: \(error.localizedDescription)")
                }
            }
            Persistency.persistencyStorageFileURL = URL.appendingPathComponent(persistencyFileName)
        }
    }()

    static let instance = Persistency()
    fileprivate let dispatchQueue: DispatchQueue
    fileprivate static let defaultDispatchQueueLabel = "com.instructure.pageEvent.persistanceQueue"
    fileprivate var queuedEvents = [PageViewEvent]()
    fileprivate var safeQueuedEvents: [PageViewEvent] {
        dispatchQueue.sync {
            queuedEvents
        }
    }
    fileprivate static var persistencyStorageFileURL: URL?

    init(dispatchQueue: DispatchQueue = DispatchQueue(label: defaultDispatchQueueLabel, attributes: .concurrent)) {
        self.dispatchQueue = dispatchQueue
        restoreQueuedEventsFromFile()
    }

    func addToQueue(_ event: PageViewEvent, completionHandler: EmptyHandler? = nil) {
        dispatchQueue.sync(flags: .barrier) {
            queuedEvents.append(event)
        }
        saveToFile(completionHandler)
    }

    func storageFileURL() -> URL? {
        _ = Persistency.__once
        return type(of: self).persistencyStorageFileURL
    }

    func saveToFile(_ handler: EmptyHandler? = nil) {
        guard let path = storageFileURL()?.path else {
            return
        }

        do {
            let data = try PropertyListEncoder().encode(safeQueuedEvents)
            let saveData = try NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: false)
            try? saveData.write(to: URL(fileURLWithPath: path), options: [.atomic])
        } catch {
            print("Archive failed")
        }

        DispatchQueue.main.async {
            handler?()
        }
    }

    func restoreQueuedEventsFromFile() {
        guard let URL = storageFileURL(),
              let fileData = try? Data(contentsOf: URL),
              let unArchivedData = (try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSData.self, from: fileData)) as? Data
        else {
            return
        }
        if let eventsToRestore = try? PropertyListDecoder().decode([PageViewEvent].self, from: unArchivedData) {
            dispatchQueue.sync(flags: .barrier) {
                queuedEvents = eventsToRestore
            }
        }
    }

    // MARK: - Queue Ops

    func batchOfEvents(_ count: Int, userID: String) -> [PageViewEvent]? {
        let userQueue = queue(for: userID)
        if (count - 1) >= userQueue.count { return nil }
        return userQueue.count > 0 ? Array(userQueue[0...count-1]) : []
    }

    func dequeue(_ count: Int = 1, userID: String, handler: EmptyHandler? = nil) {
        let userQueue = queue(for: userID)

        if userQueue.count >= count {
            for event in userQueue {
                dispatchQueue.sync(flags: .barrier) {
                    queuedEvents.removeAll { $0.guid == event.guid }
                }
            }
            saveToFile(handler)
        } else { handler?() }
    }

    func queueCount(for userID: String) -> Int {
        safeQueuedEvents.reduce(into: 0) { partialResult, event in
            partialResult += (event.userID == userID ? 1 : 0)
        }
    }

    private func queue(for userID: String) -> [PageViewEvent] {
        safeQueuedEvents.filter { $0.userID == userID }
    }
}

extension FileManager {
    @objc static func appSupportDirectory() -> URL? {
        return FileManager.default.urls(for: FileManager.SearchPathDirectory.applicationSupportDirectory, in: .userDomainMask).last
    }
}
