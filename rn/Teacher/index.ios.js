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
} from 'react-native'
import store from './src/redux/store'
import setupI18n from './i18n/setup'
import { setSession, getSession, compareSessions } from './src/canvas-api'
import { registerScreens } from './src/routing/register-screens'
import { setupBrandingFromNativeBrandingInfo } from './src/common/branding'
import logout from './src/redux/logout-action'
import loginVerify from './src/common/login-verify'
import { hydrateStoreFromPersistedState } from './src/redux/middleware/persist'
import hydrate from './src/redux/hydrate-action'
import { beginUpdatingBadgeCounts, stopUpdatingBadgeCounts, updateBadgeCounts } from './src/modules/tabbar/badge-counts'
import App, { type AppId } from './src/modules/app'
import device from 'react-native-device-info'
import { route } from './src/routing'
import i18n from 'format-message'

import { Client, Configuration } from 'bugsnag-react-native'
const configuration = new Configuration()
configuration.notifyReleaseStages = ['testflight', 'production']
configuration.appVersion = `${device.getVersion()}-${device.getBuildNumber()}`
global.crashReporter = new Client(configuration)

// Useful for demos when you don't want that annoying yellow box showing up all over the place
// such as, when demoing
console.disableYellowBox = true
setupI18n(NativeModules.SettingsManager.settings.AppleLocale)
registerScreens(store)

const {
  NativeLogin,
  Helm,
} = NativeModules

const loginHandler = async ({
  appId,
  authToken,
  baseURL,
  branding,
  user,
  actAsUserID,
  skipHydrate,
}: {
  appId: AppId,
  authToken: string,
  baseURL: string,
  branding: Object,
  user: SessionUser,
  actAsUserID: ?string,
  skipHydrate: boolean,
}) => {
  App.setCurrentApp(appId)
  stopUpdatingBadgeCounts()

  if (user) {
    // flow already thinks the id is a string but it's not so coerce ;)
    user.id = user.id.toString()
  }

  if (branding) {
    setupBrandingFromNativeBrandingInfo(branding)
  }

  if (!authToken) {
    setSession(null)
    store.dispatch(logout)
  } else {
    const session = { authToken, baseURL, user, actAsUserID }
    const previous = getSession()
    if (previous && !compareSessions(session, previous)) {
      setSession(null)
      store.dispatch(logout)
    }

    PushNotificationIOS.addEventListener('notification', (notification) => {
      if (notification.getData() && notification.getData().html_url) {
        const isSubmissionComment = notification
          .getAlert()
          .toLowerCase()
          .startsWith(i18n('submission comment'))
        const url = notification.getData().html_url
        try {
          const r = route(url, {
            selectedTabIndex: isSubmissionComment ? 1 : -1,
            forceRefresh: true,
          })
          NativeModules.Helm.present(r.screen, r.passProps, { modal: true })
        } catch (e) {}
      }
      notification.finish(PushNotificationIOS.FetchResult.NewData)
    })

    setSession(session)
    if (!skipHydrate) {
      await hydrateStoreFromPersistedState(store)
    } else {
      store.dispatch(hydrate())
    }
    Helm.loginComplete()
    loginVerify()
    beginUpdatingBadgeCounts()
  }
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
