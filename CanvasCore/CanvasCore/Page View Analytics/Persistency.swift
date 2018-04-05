//
// Copyright (C) 2018-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

typealias EmptyHandler = () -> Void

class Persistency {
    private static var __once: () = {
        let persistencyFileName = "PageViewEvents.dat"
        let fileManager = FileManager.default
        let appSupportDirectoryURL = FileManager.appSupportDirectory()
        if let URL = appSupportDirectoryURL {
            if !fileManager.fileExists(atPath: URL.absoluteString) {
                do {
                    try fileManager.createDirectory(at: URL, withIntermediateDirectories: true, attributes: nil)
                }
                catch let error as NSError {
                    print("Cannot create persistancy directory: \(error.localizedDescription)")
                }
            }
            Persistency.persistencyStorageFileURL = URL.appendingPathComponent(persistencyFileName)
        }
    }()
    
    static let instance = Persistency()
    fileprivate let dispatchQueue = DispatchQueue(label: "com.instructure.pageEvent.persistanceQueue", attributes: .concurrent)
    fileprivate var queuedEvents = [PageViewEvent]()
    fileprivate static var persistencyStorageFileURL: URL?
    var queueCount: Int {
        get{ return queuedEvents.count }
    }
    
    init() {
        restoreQueuedEventsFromFile()
    }
    
    func addToQueue(_ event: PageViewEvent) {
        dispatchQueue.async(flags: .barrier) { [weak self] in
            self?.queuedEvents.append(event)
            self?.saveToFile()
        }
    }
    
    func storageFileURL() -> URL? {
        _ = Persistency.__once
        return type(of: self).persistencyStorageFileURL
    }
    
    func saveToFile(_ handler: EmptyHandler? = nil) {
        if queuedEvents.count == 0 { handler?(); return }
        DispatchQueue.global(qos: .background).async { [weak self] in
            if let weakself = self, let path = self?.storageFileURL()?.path {
                self?.dispatchQueue.async(flags: .barrier) {
                    do {
                        let data = try PropertyListEncoder().encode(weakself.queuedEvents)
                        let saveData = NSKeyedArchiver.archivedData(withRootObject: data)
                        try? saveData.write(to: URL(fileURLWithPath: path), options: [.atomic])
                    }
                    catch {
                        print("Archive failed")
                    }
                    DispatchQueue.main.sync { handler?() }
                }
            }
        }
    }
    
    func restoreQueuedEventsFromFile() {
        dispatchQueue.async(flags: .barrier) { [weak self] in
           guard let URL = self?.storageFileURL(),
            let fileData = try? Data(contentsOf: URL),
            let unArchivedData = NSKeyedUnarchiver.unarchiveObject(with: fileData) as? Data else { return }
            if let eventsToRestore = try? PropertyListDecoder().decode([PageViewEvent].self, from: unArchivedData) {
                self?.queuedEvents = eventsToRestore
            }
        }
    }
    
    // MARK: - Queue Ops
    
    func batchOfEvents(_ count: Int) -> [PageViewEvent] {
        return queueCount > 0 ? Array(queuedEvents[0...count-1]) : []
    }
    
    func dequeue(_ count: Int = 1, handler: EmptyHandler? = nil) {
        if queuedEvents.count >= count {
            queuedEvents.removeFirst(count)
            saveToFile(handler)
        }
        else { handler?() }
    }
}

extension FileManager {
    static func appSupportDirectory() -> URL? {
        return FileManager.default.urls(for: FileManager.SearchPathDirectory.applicationSupportDirectory, in: .userDomainMask).last
    }
}

