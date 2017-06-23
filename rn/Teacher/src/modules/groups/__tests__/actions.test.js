// @flow

import Actions, { GroupActions } from '../actions'
import { testAsyncAction } from '../../../../test/helpers/async'
import { apiResponse } from '../../../../test/helpers/apiMock'

const { refreshGroupsForCourse } = Actions

const template = {
  ...require('../../../api/canvas-api/__templates__/group'),
}

test('should refresh groups', async () => {
  const groups = [
    template.group({ id: '1' }),
    template.group({ id: '2', name: 'Yellow Squadron' }),
  ]

  let actions = GroupActions({
    getGroupsForCourse: apiResponse(groups),
  })

  let result = await testAsyncAction(actions.refreshGroupsForCourse('who cares'))
  expect(result).toMatchObject([
    {
      type: refreshGroupsForCourse.toString(),
      pending: true,
      payload: {},
    },
    {
      type: refreshGroupsForCourse.toString(),
      payload: {
        result: { data: groups },
      },
    },
  ])
})

