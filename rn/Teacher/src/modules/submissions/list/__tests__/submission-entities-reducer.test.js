// @flow

import { submissions } from '../submission-entities-reducer'
import Actions from '../actions'

const { refreshSubmissions } = Actions
const templates = {
  ...require('../../../../api/canvas-api/__templates__/submissions'),
}

test('it captures entities', () => {
  let data = [
    { id: 1 },
    { id: 2 },
  ].map(override => templates.submissionHistory([override]))

  const action = {
    type: refreshSubmissions.toString(),
    payload: { result: { data } },
  }

  expect(submissions({}, action)).toEqual({
    '1': data[0],
    '2': data[1],
  })
})
