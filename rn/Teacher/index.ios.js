/**
 * Teacher
 * https://github.com/instructure/ios/rn/Teacher
 * @flow
 */

import './src/common/global-style'
import {
  NativeModules,
  NativeEventEmitter,
} from 'react-native'
import store from './src/redux/store'
import setupI18n from './i18n/setup'
import { setSession } from './src/api/session'
import { registerScreens } from './src/routing/register-screens'
import { setupBrandingFromNativeBrandingInfo } from './src/common/branding'
import logout from './src/redux/logout-action'
import { hydrateStoreFromPersistedState } from './src/redux/middleware/persist'

// Useful for demos when you don't want that annoying yellow box showing up all over the place
// such as, when demoing
console.disableYellowBox = true

registerScreens(store)

global.V02 = true
global.V03 = true
global.V04 = true
global.V05 = true
global.V06 = true
global.V07 = true

const nativeLogin = NativeModules.NativeLogin

setupI18n(NativeModules.SettingsManager.settings.AppleLocale)

const emitter = new NativeEventEmitter(nativeLogin)
emitter.addListener('Login', async (info: {
  authToken: string,
  baseURL: string,
  branding: Object,
  user: SessionUser,
}) => {
  if (info.user) {
    // flow already thinks the id is a string but it's not so coerce ;)
    info.user.id = info.user.id.toString()
  }

  if (info.branding) {
    setupBrandingFromNativeBrandingInfo(info.branding)
  }

  if (!info.authToken) {
    store.dispatch(logout)
  } else {
    setSession(info)
    hydrateStoreFromPersistedState(store)
  }
})
