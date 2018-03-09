/* eslint-disable flowtype/require-valid-file-annotation */
// this file blows up flow because none of the feature flag names
// are in the enum but that's ok cause we need to test some logic here

import { setSession } from '../../canvas-api'
import { featureFlagEnabled, featureFlags } from '../feature-flags'

const templates = {
  ...require('../../__templates__/session'),
}

describe('Feature Flags', () => {
  beforeAll(() => {
    featureFlags['aNewFlag'] = {
      exempt: ['https://www.google.com/'],
    }
  })

  beforeEach(() => {
    global.__DEV__ = false
  })

  it('returns true if in development', () => {
    global.__DEV__ = true
    expect(featureFlagEnabled('someOtherFlag')).toEqual(true)
  })

  it('returns true if the user is from an always on domain', () => {
    // the default domain in tests is https://mobiledev.instructure.com
    expect(featureFlagEnabled('someOtherFlag')).toEqual(true)
  })

  it('returns true when there is no feature flag', () => {
    setSession(templates.session({ baseURL: 'https://mobileqa.instructure.com/' }))
    expect(featureFlagEnabled('someOtherFlag')).toEqual(true)
  })

  it('returns true when the user is on an exempted domain', () => {
    setSession(templates.session({ baseURL: 'https://www.google.com/' }))
    expect(featureFlagEnabled('aNewFlag')).toEqual(true)
  })

  it('returns false if the flag is defined and the user is not from an exempted domain', () => {
    setSession(templates.session({ baseURL: 'https://mobileqa.instructure.com/' }))
    expect(featureFlagEnabled('aNewFlag')).toEqual(false)
  })
})
