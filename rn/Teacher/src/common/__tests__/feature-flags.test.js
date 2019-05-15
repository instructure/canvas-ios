//
// Copyright (C) 2018-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

/* eslint-disable flowtype/require-valid-file-annotation */
// this file blows up flow because none of the feature flag names
// are in the enum but that's ok cause we need to test some logic here

import { setSession } from '../../canvas-api'
import { featureFlagEnabled, featureFlags, enableAllFeaturesFlagsForTesting, disableAllFeatureFlagsForTesting } from '../feature-flags'
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
})
