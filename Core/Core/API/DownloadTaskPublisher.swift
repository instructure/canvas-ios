//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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
import Foundation

struct DownloadTaskParameters {
    let remoteURL: URL
    let localURL: URL
    let fileID: String
}

struct DownloadTaskPublisher: Publisher {
    /// Output is a Float value between 0 and 1 indicating the download progress.
    public typealias Output = Float
    public typealias Failure = Error

    public let parameters: DownloadTaskParameters

    public init(parameters: DownloadTaskParameters) {
        self.parameters = parameters
    }

    public func receive<S>(subscriber: S) where S: Subscriber,
        DownloadTaskPublisher.Failure == S.Failure,
        DownloadTaskPublisher.Output == S.Input {
        let subscription = DownloadTaskSubscription(
            subscriber: subscriber,
            parameters: parameters
        )
        subscriber.receive(subscription: subscription)
    }
}

final class DownloadTaskSubscription<SubscriberType: Subscriber>: NSObject,
    URLSessionDownloadDelegate,
    Subscription where
    SubscriberType.Input == Float,
    SubscriberType.Failure == Error {
    private let parameters: DownloadTaskParameters
    private var subscriber: SubscriberType?
    private var downloadTask: APITask?

    init(
        subscriber: SubscriberType,
        parameters: DownloadTaskParameters
    ) {
        self.subscriber = subscriber
        self.parameters = parameters
    }

    func request(_ demand: Subscribers.Demand) {
        guard demand > 0 else {
            return
        }
        downloadTask = API(
            urlSession: URLSession(
                configuration: .ephemeral,
                delegate: self,
                delegateQueue: nil
            )
        ).makeDownloadRequest(parameters.remoteURL)

        downloadTask?.resume()
    }

    func cancel() {
        resetAll()
    }

    func urlSession(
        _: URLSession,
        downloadTask _: URLSessionDownloadTask,
        didWriteData _: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        _ = subscriber?.receive(Float(totalBytesWritten) / Float(totalBytesExpectedToWrite))
    }

    func urlSession(
        _ session: URLSession,
        downloadTask _: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL
    ) {
        let localURL = parameters.localURL

        defer {
            session.finishTasksAndInvalidate()
            resetAll()
        }

        do {
            try FileManager.default.createDirectory(
                at: localURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            if FileManager.default.fileExists(atPath: localURL.path) {
                try FileManager.default.removeItem(at: localURL)
            }
            try FileManager.default.moveItem(at: location, to: localURL)
        } catch {
            _ = subscriber?.receive(completion: .failure(
                NSError.instructureError(
                    NSLocalizedString(
                        "Couldn't save the file.",
                        comment: ""
                    )
                )
            ))
            return
        }

        _ = subscriber?.receive(completion: .finished)
    }

    func urlSession(
        _ session: URLSession,
        task _: URLSessionTask,
        didCompleteWithError error: Error?
    ) {
        guard let error = error else {
            return
        }
        session.finishTasksAndInvalidate()
        _ = subscriber?.receive(completion: .failure(error))
        resetAll()
    }

    private func resetAll() {
        downloadTask?.cancel()
        downloadTask = nil
        subscriber = nil
    }
}

final class DownloadTaskSubscriber: Subscriber {
    typealias Input = Float
    typealias Failure = Error

    var subscription: Subscription?

    func receive(subscription: Subscription) {
        self.subscription = subscription
        self.subscription?.request(.unlimited)
    }

    func receive(_: Input) -> Subscribers.Demand { .unlimited }

    func receive(completion _: Subscribers.Completion<Failure>) {
        subscription?.cancel()
        subscription = nil
    }
}
