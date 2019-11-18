//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

#if DEBUG

import Foundation

struct IPCError: Error {
    let message: String
}

class IPCServer {
    let machPortName: String
    let messagePort: CFMessagePort

    func handler(msgid: Int32, data: Data?) -> Data? {
        fatalError("handler(msgid:data:) must be overridden")
    }

    static var knownIPCServers = [CFMessagePort: IPCServer]()

    init(machPortName: String, queue: DispatchQueue) {
        self.machPortName = machPortName
        let handlerWrapper: CFMessagePortCallBack = { port, msgid, data, _ in
            IPCServer.knownIPCServers[port!]!.handler(msgid: msgid, data: data as Data?).map { Unmanaged.passRetained($0 as CFData) }
        }
        guard let port = CFMessagePortCreateLocal(kCFAllocatorDefault, self.machPortName as CFString, handlerWrapper, nil, nil) else {
            fatalError("Couldn't create mach port \(machPortName)")
        }
        messagePort = port
        IPCServer.knownIPCServers[port] = self
        CFMessagePortSetDispatchQueue(port, queue)
    }
}

class IPCAppServer: IPCServer {
    static func portName(id: String) -> String {
        "com.instructure.icanvas.ui-test-app-\(id)"
    }

    override func handler(msgid: Int32, data: Data?) -> Data? {
        guard
            let data = data,
            let helper = try? JSONDecoder().decode(UITestHelpers.Helper.self, from: data)
        else {
            fatalError("bad IPC request")
        }
        return UITestHelpers.shared?.run(helper)
    }

    init(machPortName: String) {
        super.init(machPortName: machPortName, queue: .main)
    }
}

enum IPCDriverServerMessage {
    case urlRequest(_ url: URL, uploadData: Data? = nil)
}

extension IPCDriverServerMessage: Codable {
    private enum CodingKeys: String, CodingKey {
        case urlRequest, uploadData
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let url = try container.decodeIfPresent(URL.self, forKey: .urlRequest) {
            let data = try container.decodeIfPresent(Data.self, forKey: .uploadData)
            self = .urlRequest(url, uploadData: data)
        } else {
            throw DecodingError.typeMismatch(type(of: self), .init(codingPath: container.codingPath, debugDescription: "Couldn't decode \(type(of: self))"))
        }
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .urlRequest(let url, uploadData: let data):
            try container.encode(url, forKey: .urlRequest)
            try container.encode(data, forKey: .uploadData)
        }
    }
}

protocol IPCDriverServerDelegate: class {
    func handler(_ message: IPCDriverServerMessage) -> Data?
}

class IPCDriverServer: IPCServer {
    static func portName(id: String) -> String {
        "com.instructure.icanvas.ui-test-driver-\(id)"
    }

    override func handler(msgid: Int32, data: Data?) -> Data? {
        guard
            let data = data,
            let message = try? JSONDecoder().decode(IPCDriverServerMessage.self, from: data)
            else {
                fatalError("bad IPC request")
        }
        return delegate!.handler(message)
    }

    weak var delegate: IPCDriverServerDelegate?
    init (machPortName: String, delegate: IPCDriverServerDelegate?) {
        super.init(machPortName: machPortName, queue: .global())
        self.delegate = delegate
    }
}

class IPCClient {
    var messagePort: CFMessagePort?
    var serverPortName: String
    var openTimeout: TimeInterval

    init(serverPortName: String, timeout: TimeInterval = 60.0) {
        self.serverPortName = serverPortName
        self.openTimeout = timeout
    }

    func openMessagePort() {
        let deadline = Date().addingTimeInterval(openTimeout)
        repeat {
            if let port = CFMessagePortCreateRemote(kCFAllocatorDefault, serverPortName as CFString) {
                messagePort = port
                return
            }
            sleep(1)
        } while Date() < deadline
        fatalError("client couldn't connect to server port \(serverPortName)")
    }

    func requestRemote<R: Codable>(_ request: R) throws -> Data? {
        if messagePort == nil || !CFMessagePortIsValid(messagePort) {
            openMessagePort()
        }

        var responseData: Unmanaged<CFData>?
        let requestData = (try? JSONEncoder().encode(request))!
        let status = CFMessagePortSendRequest(messagePort, 0, requestData as CFData, 1000, 1000, CFRunLoopMode.defaultMode.rawValue, &responseData)
        guard status == kCFMessagePortSuccess else {
            throw IPCError(message: "IPCClient.requestRemote: error sending IPC request")
        }
        return responseData?.takeRetainedValue() as Data?
    }
}

#endif
