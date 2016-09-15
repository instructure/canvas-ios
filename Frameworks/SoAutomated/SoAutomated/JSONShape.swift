//
//  JSONShape.swift
//  SoAutomated
//
//  Created by Nathan Armstrong on 7/22/16.
//  Copyright © 2016 instructure. All rights reserved.
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
