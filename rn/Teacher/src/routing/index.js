//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

// @flow

import React from 'react'
import PropTypes from 'prop-types'
import { Store } from 'redux'
import { Provider } from 'react-redux'
import URL from 'url-parse'
import Route from 'route-parser'
import { AppRegistry } from 'react-native'
import Navigator from './Navigator'

export const routes: Map<Route, RouteConfig> = new Map()
export const routeProps: Map<string, ?Object> = new Map()
export type RouteConfig = {
  canBecomeMaster?: boolean,
  checkRoles?: boolean,
  deepLink?: boolean,
}
export type RouteOptions = {
    screen: string,
    passProps: Object,
    config: RouteConfig,
}

export function screenID (path: string): string {
  return '(/api/v1)' + path
}

export function registerScreen (
  path: string,
  componentGenerator?: () => any,
  store?: Store,
  options: RouteConfig = { canBecomeMaster: false, checkRoles: false }
): void {
  if (componentGenerator && store) {
    const generator = wrapComponentInReduxProvider(path, componentGenerator, store)
    AppRegistry.registerComponent(path, generator)
  }
  const route = new Route(screenID(path))
  routes.set(route, options)
}

export function wrapComponentInReduxProvider (moduleName: string, generator: () => any, store: Store): any {
  const generatorWrapper = () =>
    class extends React.Component<any, any> {
      static displayName = `Scene(${moduleName})`

      static propTypes = {
        screenInstanceID: PropTypes.string,
      }

      static childContextTypes = {
        screenInstanceID: PropTypes.string,
      }

      getChildContext () {
        return {
          screenInstanceID: this.props.screenInstanceID,
        }
      }

      render () {
        let {
          navigatorOptions,
          ...props
         } = this.props
        const navigator = new Navigator(moduleName, navigatorOptions)
        const ScreenComponent = generator()
        return (
          <Provider store={store}>
            <ScreenComponent
              testID={moduleName}
              navigator={navigator}
              {...props}
              {...routeProps.get(this.props.screenInstanceID)}
            />
          </Provider>
        )
      }
    }
  return generatorWrapper
}

export function route (url: string, additionalProps: Object = {}): RouteOptions {
  const path = new URL(url).pathname
  for (let r of routes.keys()) {
    let params = r.match(path)
    if (additionalProps && typeof params === 'object') {
      params = Object.assign(params, additionalProps)
    }
    if (params) {
      params.screenInstanceID = Math.random().toString(36).slice(2)
      routeProps.set(params.screenInstanceID, params)
      return {
        screen: r.spec.replace('(/api/v1)', ''),
        passProps: params,
        config: routes.get(r) || {},
      }
    }
  }

  throw new URIError('Cannot route to ' + url)
}
