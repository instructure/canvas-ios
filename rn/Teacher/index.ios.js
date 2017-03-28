/**
 * Teacher
 * https://github.com/instructure/ios/rn/Teacher
 * @flow
 */

import {
  NativeModules,
  NativeEventEmitter,
} from 'react-native'
import { Navigation } from 'react-native-navigation'
import store from './src/redux/store'
import i18n from 'format-message'
import setupI18n from './i18n/setup'
import { setSession } from './src/api/session'
import { registerScreens } from './src/routing/register-screens'
import { route } from './src/routing'
import Colors from './src/common/colors'
import { branding, setupBrandingFromNativeBrandingInfo } from './src/common/branding'
import Images from './src/images'
import logout from './src/redux/logout-action'

// Useful for demos when you don't want that annoying yellow box showing up all over the place
// such as, when demoing
// console.disableYellowBox = true

registerScreens(store)

const { __DEV__ } = global

const nativeLogin = NativeModules.NativeLogin
nativeLogin.startObserving()

let navigationStyles: { [key: string]: any } = {
  navBarBackgroundColor: Colors.navBarBg,
  navBarTextColor: '#fff',
  navBarButtonColor: '#fff',
  statusBarTextColorScheme: 'light',
  navBarImage: require('./src/images/canvas-logo.png'),
}

setupI18n(NativeModules.SettingsManager.settings.AppleLocale)

const emitter = new NativeEventEmitter(nativeLogin)
emitter.addListener('Login', (info: { authToken: string, baseURL: string, branding: Object, user: User }) => {
  if (info.branding) {
    navigationStyles = setupBranding(info.branding)
  }

  if (!info.authToken) {
    store.dispatch(logout)
  } else {
    setSession(info)

    let tabs = [
      {
        label: i18n({
          default: 'Courses',
          description: 'Label indicating the user is on the courses tab',
        }),
        title: i18n('Courses'),
        icon: Images.tabbar.courses,
        selectedIcon: Images.tabbar.courses,
        titleImage: Images.canvasLogo,
        navigatorStyle: navigationStyles,
        ...route('/'),
      },
      {
        label: i18n({
          default: 'Inbox',
          description: 'Label indicating the user is on the inbox tab',
        }),
        navigatorStyle: navigationStyles,
        title: i18n('Inbox'),
        icon: Images.tabbar.inbox,
        selectedIcon: Images.tabbar.inbox,
        ...route('/conversations'),
      },
      {
        label: i18n({
          default: 'Profile',
          description: 'Label indicating the user is on the profile tab',
        }),
        navigatorStyle: navigationStyles,
        title: i18n('Profile'),
        icon: Images.tabbar.profile,
        selectedIcon: Images.tabbar.profile,
        ...route('/profile'),
      },
    ]

    if (__DEV__) {
      tabs.push({
        label: 'Staging',
        navigatorStyle: navigationStyles,
        title: 'Staging',
        icon: Images.tabbar.staging,
        selectedIcon: Images.tabbar.stagingFilled,
        ...route('/staging'),
      })
    }

    Navigation.startTabBasedApp({
      tabs,
      tabsStyle: {
        tabBarSelectedButtonColor: branding.primaryBrandColor,
        tabBarBackgroundColor: Colors.tabBarBg,
        tabBarButtonColor: Colors.tabBarTab,
      },
    })
  }
})

function setupBranding (nativeBranding: Object): Object {
  setupBrandingFromNativeBrandingInfo(nativeBranding)
  let style = Object.assign({}, navigationStyles)
  style.navBarBackgroundColor = branding.navBgColor
  style.navBarButtonColor = branding.navButtonColor
  style.navBarImage = branding.headerImage
  return style
}
