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
import { setSession, compareSessions, getSessionUnsafe, httpCache, getUser } from './src/canvas-api'
import { registerScreens } from './src/routing/register-screens'
import { setupBrandingFromNativeBrandingInfo, type Brand } from './src/common/branding'
import logoutAction from './src/redux/logout-action'
import loginVerify from './src/common/login-verify'
import { hydrateStoreFromPersistedState } from './src/redux/middleware/persist'
import hydrate from './src/redux/hydrate-action'
import { beginUpdatingBadgeCounts, stopUpdatingBadgeCounts, updateBadgeCounts } from './src/modules/tabbar/badge-counts'
import App, { type AppId } from './src/modules/app'
import Navigator from './src/routing/Navigator'
import { featureFlagSetup } from './src/common/feature-flags'
import APIBridge from './src/canvas-api/APIBridge'
import { Crashlytics } from './src/common/CanvasCrashlytics'
import { getLastRoute } from './src/modules/developer-menu/DeveloperMenu'

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
  baseURL,
  branding,
  user,
  actAsUserID,
  skipHydrate,
  countryCode,
  locale,
  wasReload,
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
  wasReload: boolean,
}) => {
  setupI18n(locale || NativeModules.SettingsManager.settings.AppleLocale)
  App.setCurrentApp(appId)
  stopUpdatingBadgeCounts()

  if (!authToken || !baseURL) {
    return logout()
  }

  if (branding) {
    setupBrandingFromNativeBrandingInfo(branding)
  }

  const session = { authToken, baseURL, user, actAsUserID }
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

  setSession(session)

  try {
    await getUser('self')
  } catch (err) {
    if (err.response && err.response.status === 401) {
      return NativeLogin.logout()
    }
  }

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

  if (wasReload) {
    let lastRoute = await getLastRoute()
    let navigator = new Navigator('')
    navigator.show(lastRoute.url, lastRoute.options, lastRoute.props)
  }
}

const emitter = new NativeEventEmitter(NativeLogin)
emitter.addListener('Login', loginHandler)

AppState.addEventListener('change', (nextAppState) => {
  let session = getSessionUnsafe()
  if (session && nextAppState === 'active') {
    loginVerify()
    updateBadgeCounts()
  }
})

APIBridge()

NativeNotificationCenter.addObserver('route')
const notificationCenter = new NativeEventEmitter(NativeNotificationCenter)
notificationCenter.addListener('Notification', (notification) => {
  switch (notification.name) {
    case 'route':
      const userInfo = notification.userInfo
      if (userInfo && userInfo.url) {
        const navigator = new Navigator('')
        navigator.show(userInfo.url)
      }
      break
  }
})
