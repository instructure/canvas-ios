//
// Copyright (C) 2016-present Instructure, Inc.
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

/**
 * Teacher
 * https://github.com/instructure/ios/rn/Teacher
 * @flow
 */

import './src/common/global-style'
import {
  NativeModules,
  NativeEventEmitter,
  AppState,
  PushNotificationIOS,
  Linking,
} from 'react-native'
import store from './src/redux/store'
import setupI18n from './i18n/setup'
import { setSession, compareSessions, getSessionUnsafe, httpCache } from './src/canvas-api'
import { registerScreens } from './src/routing/register-screens'
import { setupBrandingFromNativeBrandingInfo } from './src/common/branding'
import logoutAction from './src/redux/logout-action'
import loginVerify from './src/common/login-verify'
import { hydrateStoreFromPersistedState } from './src/redux/middleware/persist'
import hydrate from './src/redux/hydrate-action'
import { beginUpdatingBadgeCounts, stopUpdatingBadgeCounts, updateBadgeCounts } from './src/modules/tabbar/badge-counts'
import App, { type AppId } from './src/modules/app'
import device from 'react-native-device-info'
import Navigator from './src/routing/Navigator'
import { featureFlagSetup } from './src/common/feature-flags'
import APIBridge from './src/canvas-api/APIBridge'

import { Client, Configuration } from 'bugsnag-react-native'
let shouldLogUserInfo = false
const configuration = new Configuration()
configuration.notifyReleaseStages = ['testflight', 'production']
configuration.appVersion = `${device.getVersion()}-${device.getBuildNumber()}`

configuration.beforeSendCallbacks.push((report) => {
  const session = getSessionUnsafe()
  if (shouldLogUserInfo && session) {
    report.addMetadata('user', 'id', session.user.id)
    report.addMetadata('user', 'baseURL', session.baseURL)
  }
  return true
})

global.crashReporter = new Client(configuration)

// Useful for demos when you don't want that annoying yellow box showing up all over the place
// such as, when demoing
console.disableYellowBox = true
setupI18n(NativeModules.SettingsManager.settings.AppleLocale)

const {
  NativeLogin,
  Helm,
} = NativeModules

function logout () {
  setSession(null)
  httpCache.clear()
  store.dispatch(logoutAction)
}

const loginHandler = async ({
  appId,
  authToken,
  baseURL,
  branding,
  user,
  actAsUserID,
  skipHydrate,
  countryCode,
}: {
  appId: AppId,
  authToken: string,
  baseURL: string,
  branding: Object,
  user: SessionUser,
  actAsUserID: ?string,
  skipHydrate: boolean,
  countryCode: string,
}) => {
  App.setCurrentApp(appId)
  stopUpdatingBadgeCounts()

  if (!authToken || !baseURL) {
    return logout()
  }

  if (user) {
    // flow already thinks the id is a string but it's not so coerce ;)
    user.id = user.id.toString()
  }

  if (branding) {
    setupBrandingFromNativeBrandingInfo(branding)
  }

  const session = { authToken, baseURL, user, actAsUserID }
  const previous = getSessionUnsafe()
  if (previous && !compareSessions(session, previous)) {
    logout()
  }

  if (countryCode !== 'CA') {
    global.crashReporter.setUser(user.id)
    shouldLogUserInfo = true
  }

  PushNotificationIOS.addEventListener('notification', (notification) => {
    const navigator = new Navigator('')
    navigator.showNotification(notification)
    notification.finish(PushNotificationIOS.FetchResult.NewData)
  })

  Linking.addEventListener('url', (event) => {
    const navigator = new Navigator('')
    navigator.show(event.url, {
      modal: true,
      embedInNavigationController: true,
      deepLink: true,
    })
  })

  setSession(session)
  if (!skipHydrate) {
    await hydrateStoreFromPersistedState(store)
    await httpCache.hydrate()
  } else {
    store.dispatch(hydrate())
  }
  await featureFlagSetup()
  registerScreens(store)
  Helm.loginComplete()
  loginVerify()
  beginUpdatingBadgeCounts()
}

if (NativeLogin.isTesting) {
  const loginInfo = NativeLogin.loginInformation()
  if (loginInfo) {
    loginHandler(loginInfo)
  }
}

const emitter = new NativeEventEmitter(NativeLogin)
emitter.addListener('Login', loginHandler)

AppState.addEventListener('change', (nextAppState) => {
  if (nextAppState === 'active') {
    loginVerify()
    updateBadgeCounts()
  }
})

APIBridge()
