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

import { registerScreens } from './src/modules/registerScreens'
registerScreens()

const nativeLogin = NativeModules.NativeLogin
nativeLogin.startObserving()

const emitter = new NativeEventEmitter(nativeLogin)
emitter.addListener('Login', (info) => {
  if (info.authToken) {
    Navigation.startTabBasedApp({
      tabs: [
        {
          label: 'Courses',
          screen: 'teacher.CourseList',
          title: 'Courses',
        },
        {
          label: 'Inbox',
          screen: 'teacher.Inbox',
          title: 'Inbox',
        },
        {
          label: 'Inbox',
          screen: 'teacher.Profile',
          title: 'Inbox',
        },
      ],
    })
  } else {
    Navigation.startSingleScreenApp({
      screen: {
        screen: 'teacher.DefaultState',
        title: 'You Should Login',
      },
    })
  }
})
