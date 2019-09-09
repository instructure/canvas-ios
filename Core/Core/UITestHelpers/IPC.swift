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
        return "com.instructure.icanvas.ui-test-app-\(id)"
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

class IPCDriverServer: IPCServer {
    static func portName(id: String) -> String {
        return "com.instructure.icanvas.ui-test-driver-\(id)"
    }

    init (machPortName: String) {
        super.init(machPortName: machPortName, queue: .global())
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

    func requestRemote<R: Codable>(_ request: R) -> Data? {
        if messagePort == nil || !CFMessagePortIsValid(messagePort) {
            openMessagePort()
        }

        var responseData: Unmanaged<CFData>?
        let requestData = (try? JSONEncoder().encode(request))!
        let status = CFMessagePortSendRequest(messagePort, 0, requestData as CFData, 1000, 1000, CFRunLoopMode.defaultMode.rawValue, &responseData)
        guard status == kCFMessagePortSuccess else {
            fatalError("IPCClient.requestRemote: error sending IPC request")
        }
        return responseData?.takeRetainedValue() as Data?
    }
}

#endif
