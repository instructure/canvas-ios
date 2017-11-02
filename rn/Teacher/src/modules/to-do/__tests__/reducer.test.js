// @flow

import reducer from '../reducer'
import { default as ListActions } from '../list/actions'

const { refreshedToDo } = ListActions

const template = {
  ...require('../../../__templates__/toDo'),
}

test('refreshedToDo', () => {
  const grading = template.toDoItem({ type: 'grading' })
  const submitting = template.toDoItem({ type: 'submitting' })
  const items = [grading, submitting]
  const action = refreshedToDo(items)
  expect(reducer({}, action)).toEqual({
    items,
  })
})
