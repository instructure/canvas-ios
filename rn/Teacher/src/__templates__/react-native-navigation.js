// @flow

import template from '../utils/template'

export const navigator: Template<ReactNavigator> = template({
  push: jest.fn(),
  showModal: jest.fn(),
  dismissModal: jest.fn(),
  setOnNavigatorEvent: jest.fn(),
  pop: jest.fn(),
})
