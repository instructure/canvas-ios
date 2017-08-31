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
    const action = actions.refreshAnnouncements('35')
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
          courseID: '35',
        },
      },
    ])
    expect(discussionsMock).toHaveBeenCalledWith('35', { only_announcements: true })
  })
})
