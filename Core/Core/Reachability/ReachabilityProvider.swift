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

import CombineReachability
import Reachability
import Combine

public final class ReachabilityProvider: ObservableObject {

    private let reachability = try? Reachability()

    @Published public var isConnected: Bool = false
    public var newtorkReachabilityPublisher: AnyPublisher<Bool, Never> {
        $isConnected
            .dropFirst()
            .eraseToAnyPublisher()
    }
    private(set) var notifierRunning: Bool = false
    private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()

    init() {
        start()
        addObservers()
    }

    func start() {
        do {
            try reachability?.startNotifier()
            notifierRunning = true
        } catch {
            print("Unable to start notifier")
        }
    }

    func addObservers() {
        do {
            try reachability?.startNotifier()
        } catch {
            print("Unable to start notifier")
        }

        reachability?.isReachable
            .sink { [weak self] isReachable in
                self?.isConnected = isReachable
            }
            .store(in: &cancellables)
    }
}
