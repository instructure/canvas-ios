//
//  DarwinNotificationCenter.swift
//
//  Copyright © 2017 WeTransfer. All rights reserved.
//

import Foundation

/// A Darwin notification payload. It does not contain any userInfo, a Darwin notification is purely event handling.
public struct DarwinNotification {
    /// The Darwin notification name
    public struct Name: Equatable {
        /// The CFNotificationName's value
        fileprivate var rawValue: CFString
    }

    /// The Darwin notification name
    var name: Name

    /// Initializes the notification based on the name.
    fileprivate init(_ name: Name) {
        self.name = name
    }
}

// MARK: -

public extension DarwinNotification.Name {
    /// Initializes a new Notification Name, based on a custom string. This string should be identifying for not only this notification, but for the full system. Therefore, you should include a bundle identifier to the string.
    init(_ rawValue: String) {
        self.rawValue = rawValue as CFString
    }

    /// Initialize a new Notification Name, based on a CFNotificationName.
    internal init(_ cfNotificationName: CFNotificationName) {
        rawValue = cfNotificationName.rawValue
    }

    static func == (lhs: DarwinNotification.Name, rhs: DarwinNotification.Name) -> Bool {
        return (lhs.rawValue as String) == (rhs.rawValue as String)
    }
}

// MARK: -

/// A system-wide notification center. This means that all notifications will be delivered to all interested observers, regardless of the process owner. Darwin notifications don't support userInfo payloads to the notifications. This wrapper is thread-safe.
public final class DarwinNotificationCenter {
    /// An active observation by an observer.
    fileprivate final class Observation {
        /// The handler to be executed when the notification is received.
        let handler: NotificationHandler

        /// The notification name where the observer is interested in.
        let name: DarwinNotification.Name

        /// The interested object
        weak var observer: AnyObject?

        init(observer: AnyObject, name: DarwinNotification.Name, handler: @escaping NotificationHandler) {
            self.observer = observer
            self.name = name
            self.handler = handler
            observe()
        }
    }

    /// The handler type to be executed when the notification is received.
    public typealias NotificationHandler = (DarwinNotification) -> Void

    /// The shared DarwinNotificationCenter, it will always return the same instance.
    public static var shared = DarwinNotificationCenter()

    /// The underlying CFNotificationCenter.
    private let center = CFNotificationCenterGetDarwinNotifyCenter()

    /// All observation info. This frequently needs some cleanup, as done by the cleanupObservers() method.
    private var observations = [Observation]()

    /// A serial queue to sync all observation changes onto, to make the wrapper thread-safe.
    private let queue = DispatchQueue(label: "com.instructure.icanvas.darwin-notificationcenter", qos: .default, attributes: [], autoreleaseFrequency: .workItem)

    private init() {}

    // MARK: -

    /// Cleanup all deallocated observers
    private func cleanupObservers() {
        queue.async {
            self.observations = self.observations.filter { observation -> Bool in
                let stillAlive = observation.observer != nil
                if !stillAlive {
                    observation.unobserve()
                }
                return stillAlive
            }
        }
    }

    /// Adds a given observer, to watch for the given Darwin notification, using a given handler.
    ///
    /// - Parameters:
    ///   - observer: The observer that is interested in the notification. Whenever the observer gets deallocated, the handler won't be guaranteed to be called anymore.
    ///   - name: The notification name of interest.
    ///   - handler: The handler to be executed when the notification is received. This will always be executed on a dedicated userinteractive queue, so NOT the main queue. If you want, you can dispatch to the main queue yourself.
    public func addObserver(_ observer: AnyObject, for name: DarwinNotification.Name, using handler: @escaping NotificationHandler) {
        cleanupObservers()
        queue.async {
            let observation = Observation(observer: observer, name: name, handler: handler)
            if !self.observations.contains(observation) {
                self.observations.append(observation)
            }
        }
    }

    /// Remove a given observer. By default, all notifications for the given observer will be removed, but it's also possible to pass a specific notification name.
    ///
    /// - Parameters:
    ///   - observer: The observer that needs to be removed.
    ///   - name: The notification name that is not interesting anymore. This is nil by default, meaning that all notifications will be removed for the given observer.
    public func removeObserver(_ observer: AnyObject, for name: DarwinNotification.Name? = nil) {
        cleanupObservers()

        queue.async {
            self.observations = self.observations.filter { observation -> Bool in
                let shouldRetain = observer !== observation.observer || (name != nil && observation.name != name)
                if !shouldRetain {
                    observation.unobserve()
                }
                return shouldRetain
            }
        }
    }

    /// Checks whether the given object is an observer for the given notification name.
    ///
    /// - Parameters:
    ///   - observer: The observer to check.
    ///   - name: The name to check.
    /// - Returns: Whether the object is an observer.
    public func isObserver(_ observer: AnyObject, for name: DarwinNotification.Name? = nil) -> Bool {
        cleanupObservers()

        return queue.sync { () -> Bool in
            observations.contains(where: { observation -> Bool in
                observer === observation.observer && (name == nil || observation.name == name)
            })
        }
    }

    /// Posts the given Notification name to the system.
    ///
    /// - Parameter name: The notification name to post.
    public func postNotification(_ name: DarwinNotification.Name) {
        // Before posting a notification, cleanup all observers that are deallocated.
        cleanupObservers()

        guard let cfNotificationCenter = center else {
            fatalError("Invalid CFNotificationCenter")
        }

        CFNotificationCenterPostNotification(cfNotificationCenter, CFNotificationName(rawValue: name.rawValue), nil, nil, false)
    }

    /// Execute the observation handler for all observers that observe the given notification name.
    private func signalNotification(_ name: DarwinNotification.Name) {
        cleanupObservers()
        queue.async {
            let affectedObservations = self.observations.filter { observation -> Bool in
                observation.name == name
            }
            let notification = DarwinNotification(name)
            for observation in affectedObservations {
                observation.handler(notification)
            }
        }
    }
}

// MARK: -

extension DarwinNotificationCenter.Observation: Equatable {
    /// Start observing the notification.
    fileprivate func observe() {
        guard let cfCenter = DarwinNotificationCenter.shared.center else {
            fatalError("Invalid Darwin observation info.")
        }

        // A notification callback. Since this is a C function pointer, it can not have any ownership context.
        let callback: CFNotificationCallback = { _, _, name, _, _ in
            guard let cfName = name else {
                return
            }

            let notificationName = DarwinNotification.Name(cfName)
            DarwinNotificationCenter.shared.signalNotification(notificationName)
        }

        let observer = Unmanaged.passUnretained(self).toOpaque()
        CFNotificationCenterAddObserver(cfCenter, observer, callback, name.rawValue, nil, .coalesce)
    }

    /// Stop observing the notification. This should be done whenever the observation is going to be removed.
    fileprivate func unobserve() {
        guard let cfCenter = DarwinNotificationCenter.shared.center else {
            fatalError("Invalid Darwin observation info.")
        }
        let notificationName = CFNotificationName(rawValue: name.rawValue)
        var observer = self
        CFNotificationCenterRemoveObserver(cfCenter, &observer, notificationName, nil)
    }

    static func == (lhs: DarwinNotificationCenter.Observation, rhs: DarwinNotificationCenter.Observation) -> Bool {
        return lhs.observer === rhs.observer && lhs.name == rhs.name
    }
}
