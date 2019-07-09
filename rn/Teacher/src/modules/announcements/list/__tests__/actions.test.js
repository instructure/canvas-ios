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

/* @flow */

import { Actions } from '../actions'
import { apiResponse } from '../../../../../test/helpers/apiMock'
import { testAsyncAction } from '../../../../../test/helpers/async'

const template = {
  ...require('../../../../__templates__/discussion'),
}

describe('refreshAnnouncements', () => {
  it('refresh announcement discussions', async () => {
    const announcement = template.discussion({ title: 'refreshed' })
    const discussionsMock = apiResponse([announcement])
    const api = {
      getDiscussions: discussionsMock,
    }
    const actions = Actions(api)
    const action = actions.refreshAnnouncements('courses', '35')
    const result = await testAsyncAction(action)
    expect(result).toMatchObject([
      {
        type: actions.refreshAnnouncements.toString(),
        pending: true,
      },
      {
        type: actions.refreshAnnouncements.toString(),
        payload: {
          result: { data: [announcement] },
          contextID: '35',
          context: 'courses',
        },
      },
    ])
    expect(discussionsMock).toHaveBeenCalledWith('courses', '35', { only_announcements: true })
  })
})
