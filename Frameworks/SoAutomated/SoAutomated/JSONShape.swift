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
    case Value(String)
    case Values([String])
    case NotValue(String)
    case Object(String, JSONShape)
    case Objects(String, JSONShape)

    public var jsonKeyValue: JSONKey { return self }
}

public protocol JSONKeyType {
    var jsonKeyValue: JSONKey { get }
}

extension String: JSONKeyType {
    public var jsonKeyValue: JSONKey {
        return .Value(self)
    }
}

public func object(name: String, _ keys: JSONShape) -> JSONKeyType {
    return JSONKey.Object(name, keys)
}

public func objects(name: String, _ keys: JSONShape) -> JSONKeyType {
    return JSONKey.Objects(name, keys)
}

public func jsonShape(shape: JSONShape, matchesObject object: [String: AnyObject]) -> (Bool, String?) {
    for key in shape {
        switch key.jsonKeyValue {
        case .Value(let name):
            if !object.keys.contains(name) {
                return (false, name)
            }
        case .Objects(let name, let shape):
            guard let arrayOfObjects = object[name] as? [[String: AnyObject]] else {
                return (false, name)
            }
            for innerObject in arrayOfObjects {
                let (hasKeys, key) = jsonShape(shape, matchesObject: innerObject)
                if !hasKeys {
                    return (false, key)
                }
            }
        case .Object(let name, let shape):
            guard let innerObject = object[name] as? [String: AnyObject] else {
                return (false, name)
            }
            return jsonShape(shape, matchesObject: innerObject)
        case .Values(let names):
            for innerName in names {
                if !object.keys.contains(innerName) {
                    return (false, innerName)
                }
            }
        case .NotValue(let name):
            if object.keys.contains(name) {
                return (false, "!\(name)")
            }
        }
    }
    return (true, nil)
}

public func jsonShape(shape: JSONShape, matchesObject object: [[String: AnyObject]]) -> (Bool, String?) {
    return jsonShape([objects("root", shape)], matchesObject: ["root": object])
}

prefix public func !(jsonKeyType: JSONKeyType) -> JSONKeyType {
    switch jsonKeyType.jsonKeyValue {
    case .Value(let v):
        return JSONKey.NotValue(v)
    default:
        fatalError("! operator only applicable to Value types")
    }
}
