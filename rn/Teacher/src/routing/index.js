// @flow

import React from 'react'
import PropTypes from 'prop-types'
import { Store } from 'redux'
import { Provider } from 'react-redux'
import URL from 'url-parse'
import Route from 'route-parser'
import { AppRegistry } from 'react-native'
import Navigator from './Navigator'
import PropRegistry from './PropRegistry'

export const routes: Map<Route, RouteConfig> = new Map()
export type RouteConfig = {
  canBecomeMaster: boolean,
}
export type RouteOptions = {
    screen: string,
    passProps: Object,
    config: ?RouteConfig,
}

export function screenID (path: string): string {
  return '(/api/v1)' + path
}

export function registerScreen (path: string, componentGenerator: () => any, store: Store, options: RouteConfig = { canBecomeMaster: false }): void {
  const generator = wrapComponentInReduxProvider(path, wrapScreenWithContext(path, componentGenerator), store)
  AppRegistry.registerComponent(path, generator)
  const route = new Route(screenID(path))
  routes.set(route, options)
}

export function wrapScreenWithContext (moduleName: string, generator: () => any): any {
  const generatorWrapper = () => {
    class WrappedScreen extends React.Component {
      getChildContext () {
        return {
          screenInstanceID: this.props.screenInstanceID,
        }
      }

      render () {
        const ScreenComponent = generator()
        return <ScreenComponent { ...this.props } />
      }
    }

    WrappedScreen.displayName = `Scene(${moduleName})`

    WrappedScreen.propTypes = {
      screenInstanceID: PropTypes.string,
    }

    WrappedScreen.childContextTypes = {
      screenInstanceID: PropTypes.string,
    }

    return WrappedScreen
  }
  return generatorWrapper
}

export function wrapComponentInReduxProvider (screenID: string, generator: () => any, store: Store): any {
  const generatorWrapper = () => {
    const InternalComponent = generator()
    return class extends React.Component<any, any, any> {
      constructor (props) {
        super(props)
        this.state = {
          internalProps: { ...props, ...PropRegistry.load(props.screenInstanceID) },
        }
      }

      componentWillReceiveProps (nextProps) {
        this.setState({
          internalProps: { ...PropRegistry.load(this.props.screenInstanceID), ...nextProps },
        })
      }

      render () {
        let navigator = new Navigator(screenID)
        return (
          <Provider store={store}>
            <InternalComponent testID={screenID} navigator={navigator} {...this.state.internalProps} />
          </Provider>
        )
      }
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
      return {
        screen: r.spec.replace('(/api/v1)', ''),
        passProps: params,
        config: routes.get(r),
      }
    }
  }

  throw new URIError('Cannot route to ' + url)
}
