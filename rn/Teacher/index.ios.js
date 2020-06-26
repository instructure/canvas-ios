//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
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

/**
 * Teacher
 * https://github.com/instructure/ios/rn/Teacher
 * @flow
 */

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
import { setupBranding } from './src/common/stylesheet'
import logoutAction from './src/redux/logout-action'
import loginVerify from './src/common/login-verify'
import { hydrateStoreFromPersistedState } from './src/redux/middleware/persist'
import hydrate from './src/redux/hydrate-action'
import { beginUpdatingBadgeCounts, stopUpdatingBadgeCounts } from './src/modules/tabbar/badge-counts'
import App, { type AppId } from './src/modules/app'
import Navigator from './src/routing/Navigator'
import APIBridge from './src/canvas-api/APIBridge'
import { Crashlytics } from './src/common/CanvasCrashlytics'
import { clearClient } from './src/canvas-api-v2/client'

global.crashReporter = Crashlytics

// Useful for demos when you don't want that annoying yellow box showing up all over the place
// such as, when demoing
console.disableYellowBox = true

const {
  NativeLogin,
  Helm,
  NativeNotificationCenter,
} = NativeModules

function logout () {
  setSession(null)
  httpCache.clear()
  store.dispatch(logoutAction)
}

const loginHandler = async ({
  appId,
  authToken,
  refreshToken,
  clientID,
  clientSecret,
  baseURL,
  branding,
  user,
  actAsUserID,
  skipHydrate,
  countryCode,
  locale,
  isFakeStudent,
}: {
  appId: AppId,
  authToken: string,
  baseURL: string,
  branding: Brand,
  user: SessionUser,
  actAsUserID: ?string,
  skipHydrate: boolean,
  countryCode: string,
  locale: string,
  isFakeStudent: boolean,
}) => {
  setupI18n(locale || NativeModules.SettingsManager.settings.AppleLocale)
  App.setCurrentApp(appId)
  stopUpdatingBadgeCounts()

  if (!authToken || !baseURL) {
    return logout()
  }

  if (branding) {
    setupBranding(branding)
  }

  const session = { authToken, baseURL, user, actAsUserID, refreshToken, clientID, clientSecret, isFakeStudent }
  const previous = getSessionUnsafe()
  if (previous && !compareSessions(session, previous)) {
    logout()
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

  clearClient()
  setSession(session)

  if (await loginVerify()) { return }

  if (!skipHydrate) {
    await hydrateStoreFromPersistedState(store)
    await httpCache.hydrate()
  } else {
    store.dispatch(hydrate())
  }
  registerScreens(store)
  Helm.loginComplete()
  beginUpdatingBadgeCounts()
}

const emitter = new NativeEventEmitter(NativeLogin)
emitter.addListener('Login', loginHandler)

AppState.addEventListener('change', (nextAppState) => {
  let session = getSessionUnsafe()
  if (session && nextAppState === 'active') {
    loginVerify()
    beginUpdatingBadgeCounts()
  } else if (nextAppState.match(/inactive|background/)) {
    stopUpdatingBadgeCounts()
  }
})

APIBridge()

const notificationCenter = new NativeEventEmitter(NativeNotificationCenter)
NativeNotificationCenter.addObserver('redux-action')
notificationCenter.addListener('redux-action', (notification) => {
  const userInfo = notification.userInfo
  if (userInfo && userInfo.type && userInfo.payload) {
    store.dispatch(userInfo)
  }
})
NativeNotificationCenter.addObserver('route')
notificationCenter.addListener('route', (notification) => {
  const userInfo = notification.userInfo
  if (userInfo && userInfo.url) {
    const navigator = new Navigator('')
    navigator.show(userInfo.url, {
      modal: userInfo.modal === true,
      detail: userInfo.detail === true,
    }, userInfo.props)
  }
})
