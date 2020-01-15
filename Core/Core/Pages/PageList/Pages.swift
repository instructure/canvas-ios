//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

import Foundation

class Pages {
    let context: Context
    let env: AppEnvironment = .shared
    var handler: EmptyHandler?
    private var forceRefreshPages = false
    private var fetchingPages = false

    var frontPage: Store<GetFrontPage>?
    var all: Store<GetPages>?

    init(context: Context, handler: EmptyHandler?) {
        self.context = context
        self.handler = handler

        self.frontPage = env.subscribe(GetFrontPage(context: context)) { [weak self] in
            if self?.frontPage?.pending == false && self?.fetchingPages == false {
                self?.fetchingPages = true
                self?.frontPageDidUpdate()
            }
        }

        self.all = env.subscribe(GetPages(context: context)) { [weak self] in
            self?.pagesDidUpdate()
        }
    }

    func refresh(force: Bool = false) {
        //  refresh --> frontPage --> pages
        forceRefreshPages = force
        frontPage?.refresh(force: force)
    }

    func frontPageDidUpdate() {
        all?.refresh(force: forceRefreshPages)
    }

    func pagesDidUpdate() {
        let pending = all?.pending == true || frontPage?.pending == true
        if !pending {
            forceRefreshPages = false
            fetchingPages = false
            notify()
        }
    }

    func notify() {
        performUIUpdate {
            self.handler?()
        }
    }
}
