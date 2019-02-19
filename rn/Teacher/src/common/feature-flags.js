//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

// @flow

import { getSession } from '../canvas-api/session'
import { NativeModules, AsyncStorage } from 'react-native'
import app, { type AppId } from '../modules/app'

type Exemption = {
  domains?: Array<string>,
  apps?: Array<AppId>,
}

type FeatureFlag = {
  exempt?: Exemption,
}

export const featureFlagKey = 'teacher.developermenu.featureflagkey'

const { FeatureFlagsManager } = NativeModules

// You must add the name of the feature flag both here and in
// ./CanvasCore/CanvasCore/FeatureFlags/FeatureFlags.swift
// This will help when we go to remove a flag we can remove it
// from here and see where flow tells us we are still trying to use it
// This should be an enum so when adding more feature flags it should look like
// type FeatureFlagName = 'someFeatureFlag' | 'otherFeatureFlag'
export type FeatureFlagName = 'favoriteGroups' |
                              'newGroupNavigation' |
                              'simpleDiscussionRenderer' |
                              'newStudentAssignmentView' |
                              'conferences'

// if a feature is listed here it will be turned off
// unless in development, the current user is on a domain
// that should always have every feature flag turned on
// or the domain has been added as an exceptions
export const featureFlags: { [FeatureFlagName]: FeatureFlag } = {
  favoriteGroups: {},
  newGroupNavigation: {},
  simpleDiscussionRenderer: {},
  newStudentAssignmentView: {},
  conferences: {},
}

var enableAllFeatureFlags = false

// if you ever have to change the logic here you must also update
// CanvasCore/CanvasCore/FeatureFlags/FeatureFlags.swift as the logic
// is duplicated there for native
export function featureFlagEnabled (flagName: FeatureFlagName): boolean {
  if (enableAllFeatureFlags) {
    return true
  }

  let session = getSession()

  let flag = featureFlags[flagName]
  if (!flag) {
    return true
  }

  if (flag.exempt && flag.exempt.apps && flag.exempt.apps.includes(app.current().appId)) {
    return true
  }

  if (flag.exempt && flag.exempt.domains && flag.exempt.domains.includes(session.baseURL)) {
    return true
  }

  return false
}

export async function featureFlagSetup (): Promise<*> {
  enableAllFeatureFlags = Boolean(await AsyncStorage.getItem(featureFlagKey))
  if (enableAllFeatureFlags) {
    return FeatureFlagsManager.syncFeatureFlags({})
  }

  return FeatureFlagsManager.syncFeatureFlags(featureFlags)
}

export function enableAllFeaturesFlagsForTesting () {
  enableAllFeatureFlags = true
}

export function disableAllFeatureFlagsForTesting () {
  enableAllFeatureFlags = false
}
