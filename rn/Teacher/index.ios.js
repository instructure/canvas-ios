/**
 * Teacher
 * https://github.com/instructure/ios/rn/Teacher
 * @flow
 */

import {
  NativeModules,
  NativeEventEmitter,
} from 'react-native'

import i18n from 'format-message'

import { Navigation } from 'react-native-navigation'

import setupI18n from './i18n/setup'
import { registerScreens } from './src/modules/registerScreens'
registerScreens()

const nativeLogin = NativeModules.NativeLogin
nativeLogin.startObserving()

setupI18n(NativeModules.SettingsManager.settings.AppleLocale)

const emitter = new NativeEventEmitter(nativeLogin)
emitter.addListener('Login', (info) => {
  if (info.authToken) {
    Navigation.startTabBasedApp({
      tabs: [
        {
          label: i18n({
            default: 'Courses',
            description: 'Label indicating the user is on the courses tab',
          }),
          screen: 'teacher.CourseList',
          title: i18n('Courses'),
        },
        {
          label: i18n({
            default: 'Inbox',
            description: 'Label indicating the user is on the inbox tab',
          }),
          screen: 'teacher.Inbox',
          title: i18n('Inbox'),
        },
        {
          label: i18n({
            default: 'Profile',
            description: 'Label indicating the user is on the profile tab',
          }),
          screen: 'teacher.Profile',
          title: i18n('Profile'),
        },
      ],
    })
  } else {
    Navigation.startSingleScreenApp({
      screen: {
        screen: 'teacher.DefaultState',
        title: i18n('You Should Login'),
      },
    })
  }
})
