// @flow

import Actions from '../actions'

const { refreshedToDo } = Actions

const template = {
  ...require('../../../../__templates__/toDo'),
}

describe('refreshedToDo', () => {
  it('dispatches items', () => {
    const items = [template.toDoItem()]
    expect(refreshedToDo(items)).toEqual({
      type: 'refreshedToDo',
      payload: { items },
    })
  })
})
