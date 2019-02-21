//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import UIKit
import Core

class GroupNavigationUseCase: PresenterUseCase {
    init(context: Context, env: AppEnvironment = .shared) {
        super.init()
        addSequence([
            GetContext(context: ContextModel(.group, id: context.id), env: env),
        ])
        let getGroupOp = GetContext(context: context, env: env)
        let tabsOp = GetContextTabs(context: context, env: env, force: false)
        addOperations([getGroupOp, tabsOp])
    }
}
