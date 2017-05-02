/* @flow */

import { updateAssignmentDescription } from '../actions'

test('update assignment description', () => {
  const action = updateAssignmentDescription('1', 'test update description')
  expect(action).toEqual({
    type: updateAssignmentDescription.toString(),
    payload: {
      id: '1',
      description: 'test update description',
    },
  })
})
