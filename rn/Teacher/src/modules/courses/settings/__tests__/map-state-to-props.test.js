// @flow

import { mapStateToProps } from '../map-state-to-props'
import { appState } from '../../../../redux/__templates__/app-state'

test('finds the correct data', () => {
  let state = appState({
    entities: {
      courses: {
        '1': {
          course: { id: '1' },
          color: '#fff',
        },
        '2': {
          pending: 1,
          course: { id: '2' },
          color: '#333',
          error: 'error',
        },
      },
    },
  })

  let data = mapStateToProps(state, { courseID: '2' })
  expect(data).toMatchObject({
    pending: 1,
    course: { id: '2' },
    color: '#333',
    error: 'error',
  })
})
