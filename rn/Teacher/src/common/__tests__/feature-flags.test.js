//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

/* eslint-disable flowtype/require-valid-file-annotation */
// this file blows up flow because none of the feature flag names
// are in the enum but that's ok cause we need to test some logic here

import { setSession } from '../../canvas-api'
import {
  featureFlagEnabled,
  featureFlags,
  enableAllFeaturesFlagsForTesting,
  disableAllFeatureFlagsForTesting,
  enabledFeatureFlags,
} from '../feature-flags'
import * as templates from '../../__templates__'

describe('Feature Flags', () => {
  beforeAll(() => {
    disableAllFeatureFlagsForTesting()
    featureFlags['aNewFlag'] = {
      exempt: { domains: ['https://www.google.com/'] },
    }
  })

  afterAll(() => {
    enableAllFeaturesFlagsForTesting()
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

  it('returns true when enabled', () => {
    featureFlags['testEnabled'] = { enabled: true }
    expect(featureFlagEnabled('testEnabled')).toEqual(true)
    delete featureFlags['testEnabled']
  })

  it('returns enabled feature flags', () => {
    expect(enabledFeatureFlags().length).toEqual(0)
    enableAllFeaturesFlagsForTesting()
    expect(enabledFeatureFlags().length).toBeGreaterThan(1)
    disableAllFeatureFlagsForTesting()
    featureFlags['not a flag yo'] = { enabled: true }
    expect(enabledFeatureFlags().length).toEqual(1)
  })
})
