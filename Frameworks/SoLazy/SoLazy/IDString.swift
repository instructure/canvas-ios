
//
// Copyright (C) 2016-present Instructure, Inc.
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
import Marshal

private let tilda = NSCharacterSet(charactersInString: "~")
private let parseNumber = NSNumberFormatter().numberFromString
private let shardFactor: Int64 = 10_000_000_000_000
private let idTypeMismatchError: (KeyType, Any) -> Marshal.Error = { key, any in
    return Error.TypeMismatchWithKey(key: key.stringValue, expected: "\([String].self) or \([Int64].self)", actual: any.dynamicType)
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
public func expandTildaForCrossShardID(id: String) -> String {
    let components = id.componentsSeparatedByCharactersInSet(tilda)
    
    if components.count != 2 {
        return id
    }
    
    guard let shardID = components.first.flatMap(parseNumber)?.longLongValue else {
        return id
    }
    guard let resourceID = components.last.flatMap(parseNumber)?.longLongValue else {
        return id
    }
    
    return "\(shardID * shardFactor + resourceID)"
}

extension Dictionary where Key: KeyType {
    public func stringID(key: Key) throws -> String {
        return try convertIDString(key)(any: try anyForKey(key))
    }

    public func stringIDs(key: Key) throws -> [String] {
        let any = try anyForKey(key) as? [AnyObject]
        guard let ids = try any.flatMap({ try $0.map(convertIDString(key)) }) else {
            throw idTypeMismatchError(key, any)
        }
        return ids
    }

    public func stringID(key: Key) throws -> String? {
        do {
            let id: String = try stringID(key)
            return id
        } catch Error.KeyNotFound {
            return nil
        } catch Error.NullValue {
            return nil
        }
    }

    private func convertIDString(key: Key) -> (any: Any) throws -> String {
        return { any in
            guard let id = ((try? Int64.value(any)).map({ "\($0)" }) ?? (try? String.value(any))).map(expandTildaForCrossShardID) else {
                throw idTypeMismatchError(key, any)
            }
            return id
        }
    }
}