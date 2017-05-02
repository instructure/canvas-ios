/* @flow */

export function route (url: string, props?: Object): RouteOptions {
  if (props) {
    return { screen: url, passProps: props }
  }

  return { screen: url }
}
