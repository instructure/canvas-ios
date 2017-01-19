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
    
    

public typealias JSONShape = [JSONKeyType]

public enum JSONKey: JSONKeyType {
    case value(String)
    case values([String])
    case notValue(String)
    case object(String, JSONShape)
    case objects(String, JSONShape)

    public var jsonKeyValue: JSONKey { return self }
}

public protocol JSONKeyType {
    var jsonKeyValue: JSONKey { get }
}

extension String: JSONKeyType {
    public var jsonKeyValue: JSONKey {
        return .value(self)
    }
}

public func object(_ name: String, _ keys: JSONShape) -> JSONKeyType {
    return JSONKey.object(name, keys)
}

public func objects(_ name: String, _ keys: JSONShape) -> JSONKeyType {
    return JSONKey.objects(name, keys)
}

public func jsonShape(_ shape: JSONShape, matchesObject object: [String: Any]) -> (Bool, String?) {
    for key in shape {
        switch key.jsonKeyValue {
        case .value(let name):
            if !object.keys.contains(name) {
                return (false, name)
            }
        case .objects(let name, let shape):
            guard let arrayOfObjects = object[name] as? [[String: Any]] else {
                return (false, name)
            }
            for innerObject in arrayOfObjects {
                let (hasKeys, key) = jsonShape(shape, matchesObject: innerObject)
                if !hasKeys {
                    return (false, key)
                }
            }
        case .object(let name, let shape):
            guard let innerObject = object[name] as? [String: Any] else {
                return (false, name)
            }
            return jsonShape(shape, matchesObject: innerObject)
        case .values(let names):
            for innerName in names {
                if !object.keys.contains(innerName) {
                    return (false, innerName)
                }
            }
        case .notValue(let name):
            if object.keys.contains(name) {
                return (false, "!\(name)")
            }
        }
    }
    return (true, nil)
}

public func jsonShape(_ shape: JSONShape, matchesObject object: [[String: Any]]) -> (Bool, String?) {
    return jsonShape([JSONKey.objects("root", shape)], matchesObject: ["root": object])
}

prefix public func !(jsonKeyType: JSONKeyType) -> JSONKeyType {
    switch jsonKeyType.jsonKeyValue {
    case .value(let v):
        return JSONKey.notValue(v)
    default:
        fatalError("! operator only applicable to Value types")
    }
}
