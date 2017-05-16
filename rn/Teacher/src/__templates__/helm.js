// @flow

import template, { type Template } from '../utils/template'
import Navigator from '../routing/Navigator'

export const navigator: Template<Navigator> = template({
  show: jest.fn(),
  dismiss: jest.fn(),
  dismissAllModals: jest.fn(),
  traitCollection: jest.fn(),
})
