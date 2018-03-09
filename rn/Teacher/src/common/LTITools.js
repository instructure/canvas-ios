// @flow

import { NativeModules } from 'react-native'

export function launchExternalTool (url: string): Promise<*> {
  return NativeModules.LTITools.launchExternalTool(url)
}
