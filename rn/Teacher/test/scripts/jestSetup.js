/* @flow */

jest.mock('NetInfo', () => ({
  addEventListener: jest.fn(),
}))

// Fixes network calls in tests env.
global.XMLHttpRequest = require('xhr2').XMLHttpRequest
import './../../src/common/global-style'
