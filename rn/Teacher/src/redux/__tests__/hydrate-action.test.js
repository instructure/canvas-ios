// @flow

import hydrate, { HYDRATE_ACTION } from '../hydrate-action'
import * as template from '../__templates__/app-state'

test('it returns payload as whatever was passed in', () => {
  let payload = {
    expires: new Date(),
    state: template.appState(),
  }
  let action = hydrate(payload)
  expect(action).toMatchObject({
    type: HYDRATE_ACTION,
    payload,
  })
})
