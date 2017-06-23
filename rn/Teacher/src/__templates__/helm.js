// @flow

import template, { type Template } from '../utils/template'

export const navigator: Template<any> = template({
  show: jest.fn(),
  dismiss: jest.fn(),
  dismissAllModals: jest.fn(),
  traitCollection: jest.fn(),
  pop: jest.fn(),
})
