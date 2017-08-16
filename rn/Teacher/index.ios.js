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
} from 'react-native'
import store from './src/redux/store'
import setupI18n from './i18n/setup'
import { setSession } from './src/api/session'
import { registerScreens } from './src/routing/register-screens'
import { setupBrandingFromNativeBrandingInfo } from './src/common/branding'
import logout from './src/redux/logout-action'
import loginVerify from './src/common/login-verify'
import { hydrateStoreFromPersistedState } from './src/redux/middleware/persist'
import hydrate from './src/redux/hydrate-action'

import { Client, Configuration } from 'bugsnag-react-native'
const configuration = new Configuration()
configuration.notifyReleaseStages = ['testflight', 'production']
global.crashReporter = new Client(configuration)

const PushNotifications = NativeModules.PushNotifications

// Useful for demos when you don't want that annoying yellow box showing up all over the place
// such as, when demoing
console.disableYellowBox = true
setupI18n(NativeModules.SettingsManager.settings.AppleLocale)
registerScreens(store)

global.V11 = false

const NativeLogin = NativeModules.NativeLogin
const Helm = NativeModules.Helm

Helm.initLoadingStateIfRequired()

const loginHandler = async (info: {
  authToken: string,
  baseURL: string,
  branding: Object,
  user: SessionUser,
  skipHydrate: boolean,
}) => {
  if (info.user) {
    // flow already thinks the id is a string but it's not so coerce ;)
    info.user.id = info.user.id.toString()
  }

  if (info.branding) {
    setupBrandingFromNativeBrandingInfo(info.branding)
  }

  if (!info.authToken) {
    setSession(null)
    store.dispatch(logout)
  } else {
    PushNotifications.requestPermissions()
    setSession(info)
    if (!info.skipHydrate) {
      await hydrateStoreFromPersistedState(store)
    } else {
      store.dispatch(hydrate())
    }
    Helm.initTabs()
    loginVerify()
  }
}

// Bug in rn .45 when trying to use sync methods in debug mode
if (global.nativeCallSyncHook) {
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
  }
})
