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
import Images from './src/images'

registerScreens(store)

const nativeLogin = NativeModules.NativeLogin
nativeLogin.startObserving()

const navigationStyles = {
  navBarBackgroundColor: Colors.canvasBlue,
  navBarTextColor: '#fff',
  navBarButtonColor: '#fff',
  statusBarTextColorScheme: 'light',
}

setupI18n(NativeModules.SettingsManager.settings.AppleLocale)

const emitter = new NativeEventEmitter(nativeLogin)
emitter.addListener('Login', (info: { authToken: string, baseURL: string }) => {
  if (info.authToken) {
    setSession(info)
    Navigation.startTabBasedApp({
      tabs: [
        {
          label: i18n({
            default: 'Courses',
            description: 'Label indicating the user is on the courses tab',
          }),
          title: i18n('Courses'),
          icon: Images.tabbar.courses,
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
          ...route('/profile'),
        },
      ],
      tabsStyle: {
        tabBarSelectedButtonColor: Colors.prettyBlue,
        tabBarButtonColor: Colors.prettyGray,
      },
    })
  } else {
    Navigation.startSingleScreenApp({
      screen: {
        title: i18n('You Should Login'),
        ...route('/default'),
      },
    })
  }
})
