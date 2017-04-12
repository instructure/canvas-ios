// @flow

import { Navigation } from 'react-native-navigation'
import { Store } from 'redux'
import { Provider } from 'react-redux'

import URL from 'url-parse'
import Route from 'route-parser'

export const routes: Route[] = []

export function screenID (path: string): string {
  return '(/api/v1)' + path
}

export function registerScreen<Screen> (path: string, component: () => Screen, store: Store): void {
  const id = screenID(path)
  Navigation.registerComponent(id, component, store, Provider)
  routes.push(new Route(id))
}

export function route (url: string, additionalProps: Object = {}): RouteOptions {
  const path = new URL(url).pathname
  for (let r of routes) {
    let params = r.match(path)
    if (additionalProps && typeof params === 'object') {
      params = Object.assign(params, additionalProps)
    }
    if (params) {
      return {
        screen: r.spec,
        passProps: params,
      }
    }
  }

  throw new URIError('Cannot route to ' + url)
}
