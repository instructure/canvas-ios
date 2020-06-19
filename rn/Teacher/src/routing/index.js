//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

// @flow

import React from 'react'
import PropTypes from 'prop-types'
import { Store } from 'redux'
import { Provider } from 'react-redux'
import URL from 'url-parse'
import RouteHandler from './RouteHandler'
import { AppRegistry, NativeModules } from 'react-native'
import Navigator from './Navigator'
import { getSession } from '../canvas-api/session'
import ErrorScreen from './ErrorScreen'
import app from '../modules/app'

import { ApolloProvider } from 'react-apollo'
import getClient from '../canvas-api-v2/client'

const { Helm } = NativeModules

export const routes: Map<RouteHandler, RouteConfig> = new Map()
export const routeProps: Map<string, ?Object> = new Map()
export type RouteConfig = {
  canBecomeMaster?: boolean,
  checkRoles?: boolean,
  deepLink?: boolean,
  showInWebView?: boolean,
}
export type RouteOptions = {
  screen: string,
  passProps: Object,
  config: RouteConfig,
}

export function registerScreen (
  path: string,
  ScreenComponent,
  store?: Store,
  options: RouteConfig = { canBecomeMaster: false, checkRoles: false }
): void {
  if (ScreenComponent && store) {
    const generator = wrapComponentInProviders(path, ScreenComponent, store)
    AppRegistry.registerComponent(path, generator)
  }
  const route = new RouteHandler(path)
  routes.set(route, options)
  if (options.showInWebView !== true && options.deepLink) {
    Helm.registerRoute(path)
  }
}

export function wrapComponentInProviders (moduleName: string, ScreenComponent, store: Store): any {
  class Scene extends React.Component<any, any> {
    static displayName = `Scene(${moduleName})`

    state = { hasError: false }

    static propTypes = {
      screenInstanceID: PropTypes.string,
    }

    static childContextTypes = {
      screenInstanceID: PropTypes.string,
    }

    componentDidCatch (error, info) {
      global.crashReporter.setString('screenUrl', moduleName)
      global.crashReporter.setBool('screenError', true)

      let domain = `com.instructure.ios.${app.current().appId}`
      global.crashReporter.recordError({
        domain,
        userInfo: {
          errorMessage: error.message.split('\n')[0],
        },
      })
      this.setState({ hasError: true })
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

      if (this.state.hasError) {
        return <ErrorScreen {...props} navigator={navigator} />
      }

      const session = getSession()

      let client = getClient()

      return (
        <ApolloProvider client={client}>
          <Provider store={store}>
            <ScreenComponent
              testID={moduleName}
              navigator={navigator}
              apollo={client}
              session={session}
              {...props}
              {...routeProps.get(this.props.screenInstanceID)}
            />
          </Provider>
        </ApolloProvider>
      )
    }
  }
  return () => Scene
}

export function route (url: string, additionalProps: Object = {}): ?RouteOptions {
  const baseURL = getSession().baseURL
  const location = new URL(url, baseURL, true)
  if (url.includes('://') && new URL(baseURL).hostname !== location.hostname) {
    return
  }

  try {
    const path = location.pathname
    for (let r of routes.keys()) {
      let params = r.match(path)
      if (additionalProps && typeof params === 'object') {
        params = Object.assign(params, additionalProps)
      }
      if (params) {
        params = { ...params, ...location.query }
        params.location = location
        params.screenInstanceID = Math.random().toString(36).slice(2)
        routeProps.set(params.screenInstanceID, params)
        return {
          screen: r.template,
          passProps: params,
          config: routes.get(r) || {},
        }
      }
    }
  } catch (e) {} // If there is a problem with the url for whatever reason, we'll default to just popping it into a web view

  return
}
