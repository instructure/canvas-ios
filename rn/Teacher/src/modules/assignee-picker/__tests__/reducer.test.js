// @flow

import {
  sections,
} from '../reducer'
import Actions from '../actions'

const { refreshSections } = Actions
const templates = {
  ...require('../../../__templates__/section'),
}

test('captures entities mapped by id', () => {
  const data = [
    templates.section({ id: '3' }),
    templates.section({ id: '5' }),
  ]

  const action = {
    type: refreshSections.toString(),
    payload: {
      result: {
        data,
      },
    },
  }

  expect(sections({}, action)).toEqual({
    '3': data[0],
    '5': data[1],
  })
})
