//
// Copyright (C) 2019-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation

public class CacheManager {
    public private(set) static var lastDeletedAt: Int {
        get { return UserDefaults.standard.integer(forKey: "lastDeletedAt") }
        set { UserDefaults.standard.set(newValue, forKey: "lastDeletedAt") }
    }

    public static var bundleVersion: Int = {
        if let version = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String, let v = Int(version) {
            return v
        }
        return 0
    }()

    public static func resetAppIfNecessary() {
        guard UserDefaults.standard.bool(forKey: "reset_cache_on_next_launch") else {
            return clearIfNeeded()
        }

        for key in UserDefaults.standard.dictionaryRepresentation().keys {
            if !UserDefaults.standard.objectIsForced(forKey: key) {
                UserDefaults.standard.removeObject(forKey: key)
            }
        }

        clear()
        Keychain.clearEntries()
        clearDirectory(.documentsDirectory) // Also clear documents, which we normally keep around
    }

    public static func clearIfNeeded() {
        if lastDeletedAt != bundleVersion {
            clear()
        }
    }

    public static func clear() {
        URLCache.shared.removeAllCachedResponses()
        clearAppGroup(Bundle.main.appGroupID())
        clearAppGroup("group.com.instructure.Contexts") // LocalStoreAppGroupName
        clearCaches()
        clearLibrary()
        clearRNAsyncStorage()
        lastDeletedAt = bundleVersion
    }

    public static func clearAppGroup(_ id: String?) {
        guard let id = id, let folder = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: id) else { return }
        clearDirectory(folder)
    }

    public static func clearCaches() {
        clearDirectory(.cachesDirectory)
    }

    public static func clearLibrary() {
        clearDirectory(.libraryDirectory)
    }

    public static func clearRNAsyncStorage() {
        let asyncStorage = URL.documentsDirectory.appendingPathComponent("RCTAsyncLocalStorage_V1")
        let manifestURL = asyncStorage.appendingPathComponent("manifest.json")
        let json = (try? Data(contentsOf: manifestURL)).flatMap { try? JSONSerialization.jsonObject(with: $0) } as? [String: Any]
        clearDirectory(asyncStorage)
        let preserve = [ "speed-grader-tutorial", "teacher.profile.developermenu", "teacher.developermenu.featureflagkey" ]
        guard
            let previous = json,
            let manifest = try? JSONSerialization.data(withJSONObject: previous.filter({ entry in preserve.contains(entry.key) }))
        else { return }
        try? manifest.write(to: manifestURL, options: .atomic)
    }

    private static func clearDirectory(_ directory: URL) {
        let fs = FileManager.default
        let urls = (try? fs.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)) ?? []
        for url in urls {
            try? fs.removeItem(at: url)
        }
    }
}
