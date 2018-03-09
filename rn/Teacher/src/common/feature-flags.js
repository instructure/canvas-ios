// @flow

import { getSession } from '../canvas-api/session'
import { NativeModules } from 'react-native'

type FeatureFlag = {
  exempt: string[],
}

const { FeatureFlagsManager } = NativeModules

// You must add the name of the feature flag both here and in
// ./CanvasCore/CanvasCore/FeatureFlags/FeatureFlags.swift
// This will help when we go to remove a flag we can remove it
// from here and see where flow tells us we are still trying to use it
// This should be an enum so when adding more feature flags it should look like
// type FeatureFlagName = 'someFeatureFlag' | 'otherFeatureFlag'
type FeatureFlagName = 'userFilesFeatureFlag' | 'newAssignmentsList'

// if a feature is listed here it will be turned off
// unless in development, the current user is on a domain
// that should always have every feature flag turned on
// or the domain has been added as an exceptions
export const featureFlags: { [FeatureFlagName]: FeatureFlag } = {
  userFilesFeatureFlag: {
    exempt: [
      'https://msessions.instructure.com/',
    ],
  },
  newAssignmentsList: { exempt: [] },
}

export const exemptDomains = [
  'https://mobiledev.instructure.com/',
  'https://twilson.instructure.com/',
  'https://lmoseley.instructure.com/',
]

// if you ever have to change the logic here you must also update
// CanvasCore/CanvasCore/FeatureFlags/FeatureFlags.swift as the logic
// is duplicated there for native
export function featureFlagEnabled (flagName: FeatureFlagName): boolean {
  // All features on in development
  if (global.__DEV__) {
    return true
  }

  let session = getSession()
  // certain domains should always have the flags on
  if (exemptDomains.includes(session.baseURL)) {
    return true
  }

  let flag = featureFlags[flagName]
  if (!flag) {
    return true
  }

  if (flag.exempt.includes(session.baseURL)) {
    return true
  }

  return false
}

export function syncFeatureFlags (): Promise<*> {
  return FeatureFlagsManager.syncFeatureFlags(featureFlags, exemptDomains)
}
