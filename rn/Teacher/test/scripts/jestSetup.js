/* @flow */

jest.mock('NetInfo', () => ({
  addEventListener: jest.fn(),
}))

// Fixes network calls in tests env.
global.XMLHttpRequest = require('xhr2').XMLHttpRequest
import './../../src/common/global-style'

global.V02 = true
global.V03 = true
global.V04 = true
global.V05 = true
global.V06 = true
global.V07 = true
