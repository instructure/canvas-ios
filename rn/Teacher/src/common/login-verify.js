// @flow

import { NativeModules } from 'react-native'
import canvas from '../api/canvas-api'

// if the user has an invalid login, the promise will send `true`. Otherwise it will send `false`
export default async function loginVerify (): Promise<boolean> {
  return new Promise((resolve, reject) => {
    canvas.getUserProfile('self')
    .then(() => resolve(false))
    .catch((e) => {
      if (e.response && e.response.status === 401) {
        resolve(true)
        NativeModules.NativeLogin.logout()
      } else {
        resolve(false)
      }
    })
  })
}
