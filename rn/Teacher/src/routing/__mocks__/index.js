/* @flow */

export function route (url: string): NavigatorPushOptions {
  return { screen: url }
}
