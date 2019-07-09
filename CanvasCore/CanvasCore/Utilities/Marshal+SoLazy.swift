//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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
import Marshal

private let tilda = CharacterSet(charactersIn: "~")
private let parseNumber = NumberFormatter().number(from:)
private let shardFactor: Int64 = 10_000_000_000_000
private let idTypeMismatchError: (KeyType, Any) -> MarshalError = { key, any in
    return .typeMismatchWithKey(key: key.stringValue, expected: "\([String].self) or \([Int64].self)", actual: type(of: any))
}

/** Converts an id that might be cross-shard to a standard ID (no `~`)
 
    Resources in Canvas may be from a different shard than the logged
    in user. In these cases the ID can have one of two forms. Either it
    will be a single very large number (on the order of
    10,000,000,000,000 or larger). Or it will be of the form
    shard_id~resource_id. Where shard_id is a number and resource_id is
    a number. There is a simple formula to convert the latter form to
    the former.
 
    full_resource_id = shard_id * 10,000,000,000,000 + resource_id
 
    In order to make sure that our predicates all match up we are
    standardizing on the full_resource_id because in general most of
    our ids will not have this issue.
 
    It is safe to pass in IDs that do not have a `~`. The result will
    simply be the ID passed in.
 */
public func expandTildaForCrossShardID(_ id: String) -> String {
    let components = id.components(separatedBy: tilda)
    
    if components.count != 2 {
        return id
    }
    
    guard let shardID = components.first.flatMap(parseNumber)?.int64Value else {
        return id
    }
    guard let resourceID = components.last.flatMap(parseNumber)?.int64Value else {
        return id
    }
    
    return "\(shardID * shardFactor + resourceID)"
}

extension MarshaledObject {
    public func stringID(_ key: KeyType) throws -> String {
        return try convertIDString(key)(try any(for: key))
    }

    public func stringIDs(_ key: KeyType) throws -> [String] {
        let a = try any(for: key) as? [AnyObject]
        guard let ids = try a.flatMap({ try $0.map(convertIDString(key)) }) else {
            throw idTypeMismatchError(key, a as Any)
        }
        return ids
    }

    public func stringID(_ key: KeyType) throws -> String? {
        do {
            let id: String = try stringID(key)
            return id
        } catch MarshalError.keyNotFound {
            return nil
        } catch MarshalError.nullValue {
            return nil
        }
    }

    fileprivate func convertIDString(_ key: KeyType) -> (_ any: Any) throws -> String {
        return { anyValue in
            guard let id = ((try? Int64.value(from: anyValue)).map({ "\($0)" }) ?? (try? String.value(from: anyValue))).map(expandTildaForCrossShardID) else {
                throw idTypeMismatchError(key, anyValue)
            }
            return id
        }
    }
}

public func insert(_ value: Any?, forKey key: String) -> (_ array: [JSONObject]) -> [JSONObject] {
    func insert(_ json: JSONObject) -> JSONObject {
        var json = json
        json[key] = value
        return json
    }
    return { $0.map(insert) }
}
