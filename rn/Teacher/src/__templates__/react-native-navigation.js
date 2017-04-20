// @flow

import template, { type Template } from '../utils/template'

export const navigator: Template<ReactNavigator> = template({
  push: jest.fn(),
  showModal: jest.fn(),
  dismissModal: jest.fn(),
  setOnNavigatorEvent: jest.fn(),
  pop: jest.fn(),
  setTitle: jest.fn(),
  setStyle: jest.fn(),
})
