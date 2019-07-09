//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
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

// @flow

import { Reducer } from 'redux'
import { asyncRefsReducer } from '../../redux/async-refs-reducer'
import Actions from './actions'
import i18n from 'format-message'

const { refreshGroupsForCourse } = Actions

type Response = { result: { data: Array<Group> } }

const groups: Reducer<AsyncRefs, any> = asyncRefsReducer(
  refreshGroupsForCourse.toString(),
  () => i18n('There was a problem loading the groups.'),
  ({ result }: Response) => result.data.map(group => group.id)
)

export default groups
