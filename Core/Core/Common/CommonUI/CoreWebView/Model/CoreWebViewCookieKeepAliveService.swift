//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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
import CombineExt
import WebKit

final class CoreWebViewCookieKeepAliveService {

    private let webView = CoreWebView()
    private var subscriptions = Set<AnyCancellable>()
    private let manualRefreshSubject = PassthroughSubject<Void, Never>()
    private let networkService: NetworkAvailabilityService

    init(networkService: NetworkAvailabilityService = NetworkAvailabilityServiceLive()) {
        self.networkService = networkService
        networkService.startMonitoring()
    }

    @MainActor
    func start(env: AppEnvironment) {
        guard env.api.loginSession?.accessToken != nil, subscriptions.isEmpty else { return }

        crossCookieInjectionPublisher()
            .sink()
            .store(in: &subscriptions)

        Publishers.MergeMany([timerPublisher(), networkOnlinePublisher(), manualRefreshSubject.eraseToAnyPublisher()])
            .prepend(()) // Renew immediately on start without waiting for the first timer tick or network change
            .flatMap { [webView] in Self.renewCookies(api: env.api, webView: webView) }
            .sink()
            .store(in: &subscriptions)
    }

    @MainActor
    func stop() {
        subscriptions.removeAll()
    }

    func refresh() {
        manualRefreshSubject.send()
    }

    @MainActor
    func deleteAllCookies() -> AnyPublisher<Void, Never> {
        webView.configuration.websiteDataStore.httpCookieStore.deleteAllCookies()
    }

    // MARK: - Private

    private func crossCookieInjectionPublisher() -> AnyPublisher<Void, Never> {
        CoreWebViewCrossCookieInjection()
            .injectCrossSiteCookies(httpCookieStore: webView.configuration.websiteDataStore.httpCookieStore)
    }

    private func timerPublisher() -> AnyPublisher<Void, Never> {
        Timer.publish(every: 10 * 60, on: .main, in: .common)
            .autoconnect()
            .mapToVoid()
            .eraseToAnyPublisher()
    }

    private func networkOnlinePublisher() -> AnyPublisher<Void, Never> {
        networkService
            .startObservingStatus()
            .dropFirst() // Prevent initial subscription triggering an extra refresh
            .compactMap { $0 }
            .removeDuplicates() // The same status is reported multiple times by the OS
            .filter { $0.isConnected }
            .mapToVoid()
            .eraseToAnyPublisher()
    }

    private static func renewCookies(api: API, webView: CoreWebView) -> AnyPublisher<Void, Never> {
        api.makeRequest(GetWebSessionRequest(to: nil))
            .map { $0.body.session_url }
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { url in
                var request = URLRequest(url: url)
                request.httpMethod = "HEAD"
                webView.load(request)
            })
            .mapToVoid()
            .catch { _ in Publishers.typedJust() }
            .eraseToAnyPublisher()
    }
}

// MARK: - CoreWebView Cookie Keep-Alive

extension CoreWebView {
    private static let cookieKeepAliveService = CoreWebViewCookieKeepAliveService()

    public static func keepCookieAlive(for env: AppEnvironment) {
        cookieKeepAliveService.start(env: env)
    }

    public static func stopCookieKeepAlive() {
        cookieKeepAliveService.stop()
    }

    /// Refreshes webview session cookies immediately outside of the scheduled renewal.
    public static func refreshKeepAliveCookies() {
        cookieKeepAliveService.refresh()
    }

    public static func deleteAllCookies() -> AnyPublisher<Void, Never> {
        cookieKeepAliveService.deleteAllCookies()
    }
}
