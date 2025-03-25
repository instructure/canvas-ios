//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

import Combine

public class InterprocessNotificationCenter {
    public static let shared = InterprocessNotificationCenter()

    /** This publisher publishes all notifications this class receives after its registered subscribers. */
    public lazy var notifications: AnyPublisher<String, Never> = notificationsSubject.eraseToAnyPublisher()
    private let notificationsSubject = PassthroughSubject<String, Never>()
    private var subscriberCountByNotificationName: [String: Int] = [:]
    private let synchronizer = DispatchQueue(label: "com.instructure.icanvas.2u.darwinnotificationcenter")

    private init() {
    }

    /**
     This method subscribes this class to inter process notifications for the given name and returns
     a `Publisher` that emits an event each time a notification with the given name received.
     */
    public func subscribe(forName name: String) -> AnyPublisher<Void, Never> {
        addSubscriber(name)
        let publisher = notifications
            .filter { $0 == name }
            .map { _ in () }
            .handleEvents(receiveCancel: { self.removeSubscriber(name) })
            .eraseToAnyPublisher()
        return publisher
    }

    public func post(name: String) {
        CFNotificationCenterPostNotification(
            CFNotificationCenterGetDarwinNotifyCenter(),
            CFNotificationName(name as CFString),
            nil,
            nil,
            true
        )
    }

    private func addSubscriber(_ name: String) {
        synchronizer.sync {
            var subscriberCount = subscriberCountByNotificationName[name] ?? 0

            if subscriberCount == 0 {
                registerNotificationObserver(for: name)
            }

            subscriberCount += 1
            subscriberCountByNotificationName[name] = subscriberCount
        }
    }

    private func removeSubscriber(_ name: String) {
        synchronizer.sync {
            guard var subscriberCount = subscriberCountByNotificationName[name] else { return }
            subscriberCount -= 1
            subscriberCountByNotificationName[name] = subscriberCount

            if subscriberCount == 0 {
                deleteNotificationObserver(for: name)
            }
        }
    }

    private func registerNotificationObserver(for name: String) {
        // This is a C function pointer so we can't use self inside.
        let callback: CFNotificationCallback = { _, _, name, _, _ in
            guard let name = name?.rawValue as String? else { return }
            InterprocessNotificationCenter.shared.notificationsSubject.send(name)
        }

        CFNotificationCenterAddObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            Unmanaged.passUnretained(self).toOpaque(),
            callback,
            name as CFString,
            nil,
            .deliverImmediately
        )
    }

    private func deleteNotificationObserver(for name: String) {
        CFNotificationCenterRemoveObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            Unmanaged.passUnretained(self).toOpaque(),
            CFNotificationName(name as CFString),
            nil
        )
    }
}
