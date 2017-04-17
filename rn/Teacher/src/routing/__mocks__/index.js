/* @flow */

export function route (url: string, props?: Object): NavigatorPushOptions {
  if (props) {
    return { screen: url, passProps: props }
  }

  return { screen: url }
}
