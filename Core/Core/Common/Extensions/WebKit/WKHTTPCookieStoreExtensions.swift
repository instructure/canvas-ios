//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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
import WebKit

public extension WKHTTPCookieStore {

    func getAllCookies() -> AnyPublisher<[HTTPCookie], Never> {
        Future { promise in
            self.getAllCookies { cookies in
                promise(.success(cookies))
            }
        }.eraseToAnyPublisher()
    }

    func deleteAllCookies() -> AnyPublisher<Void, Never> {
        getAllCookies()
            .flatMap { cookies in
                Publishers.Sequence(sequence: cookies)
                    .flatMap { cookie in
                        self.deleteCookie(cookie)
                    }
                    .collect()
            }
            .mapToVoid()
            .eraseToAnyPublisher()
    }

    func setCookies(_ cookies: [HTTPCookie]) -> AnyPublisher<Void, Never> {
        Publishers.Sequence(sequence: cookies)
            .flatMap(maxPublishers: .max(1)) { cookie in
                self.setCookie(cookie)
            }
            .collect()
            .mapToVoid()
            .eraseToAnyPublisher()
    }

    func setCookie(_ cookie: HTTPCookie) -> AnyPublisher<Void, Never> {
        Future { promise in
            self.setCookie(cookie) {
                promise(.success)
            }
        }
        .eraseToAnyPublisher()
    }

    func deleteCookie(_ cookie: HTTPCookie) -> AnyPublisher<Void, Never> {
        Future { promise in
            self.delete(cookie) {
                promise(.success)
            }
        }
        .eraseToAnyPublisher()
    }
}
