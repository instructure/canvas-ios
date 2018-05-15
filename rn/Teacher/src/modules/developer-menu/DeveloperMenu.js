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

import React, { Component } from 'react'
import {
  View,
  TextInput,
  StyleSheet,
  ScrollView,
  Alert,
  AsyncStorage,
  NativeModules,
  SegmentedControlIOS,
} from 'react-native'
import { route, type RouteOptions } from '../../routing'
import Navigator from '../../routing/Navigator'
import Screen from '../../routing/Screen'
import Row from '../../common/components/rows/Row'
import SectionHeader from '../../common/components/rows/SectionHeader'
import RowSeparator from '../../common/components/rows/RowSeparator'
import RowWithSwitch from '../../common/components/rows/RowWithSwitch'
import { featureFlagKey } from '../../common/feature-flags'
import { formattedDueDate } from '../../common/formatters'
const { NativeNotificationCenter, Helm } = NativeModules

const stagingKey = 'teacher.developermenu.path'
const routeHistoryKey = 'teacher.developermenu.route-history'

type DeveloperMenuProps = {
  navigator: Navigator,
}

var routes
export async function recordRoute (url: string, options: any, props: any) {
  const ignore = ['/dev-menu']
  if (ignore.includes(url)) { return }

  if (!routes) {
    let json = await AsyncStorage.getItem(routeHistoryKey)
    if (json) {
      routes = JSON.parse(json)
    } else {
      routes = []
    }
  }

  const timestamp = (new Date()).toISOString()
  routes.unshift({ url, options, props, timestamp })
  routes = routes.slice(0, 50)
  await AsyncStorage.setItem(routeHistoryKey, JSON.stringify(routes))
}
export default class DeveloperMenu extends Component<DeveloperMenuProps, any> {
  constructor (props: DeveloperMenuProps) {
    super(props)
    this.state = {}
  }

  componentDidMount = async () => {
    let path = await AsyncStorage.getItem(stagingKey)
    let featureFlagEnabled = Boolean(await AsyncStorage.getItem(featureFlagKey))
    this.setState({
      path,
      featureFlagEnabled,
      selectedRouteMethod: 'Modal',
    })
  }

  navigate = (nav: (route: RouteOptions) => any) => {
    let path = this.state && this.state.path || ''
    try {
      let r = route(path)
      if (r) nav(r)
      AsyncStorage.setItem(stagingKey, path)
    } catch (e) {
      Alert.alert(
        'Route Not Found',
        `No route was found matching '${path}'`,
        [
          { text: 'Dismiss' },
        ],
      )
    }
  }

  purgeStorage = async () => {
    await AsyncStorage.clear()
    await this.restartApp()
  }

  forceCrash = () => {
    // $FlowFixMe
    this.fakeFunction()
  }

  forceNativeCrash = () => {
    NativeNotificationCenter.postNotification('FakeCrash', {})
  }

  go = async () => {
    await this.props.navigator.dismiss()

    switch (this.state.selectedRouteMethod) {
      case 'Modal': {
        this.navigate(route => this.props.navigator.show(route.screen, { modal: true }, route.passProps))
        break
      }
      case 'Push': {
        this.navigate(route => this.props.navigator.show(route.screen, {}, route.passProps))
        break
      }
      case 'Deep Link': {
        this.navigate(route => this.props.navigator.show(route.screen, {
          modal: true,
          embedInNavigationController: true,
          deepLink: true,
        }, route.passProps))
        break
      }
    }
  }

  close = () => {
    this.props.navigator.dismiss()
  }

  viewPushNotifications = () => {
    this.props.navigator.show('/push-notifications')
  }

  viewPageViews = () => {
    this.props.navigator.show('/page-view-events')
  }

  viewFeatureFlags = () => {
    this.props.navigator.show('/feature-flags')
  }

  viewRouteHistory = () => {
    this.props.navigator.show('/route-history')
  }

  toggleExperimentalFeatures = async () => {
    if (this.state.featureFlagEnabled) {
      this.setState({
        featureFlagEnabled: false,
      })
      await AsyncStorage.removeItem(featureFlagKey)
      this.restartApp()
    } else {
      this.setState({
        featureFlagEnabled: true,
      })
      await AsyncStorage.setItem(featureFlagKey, 'enabled')
      Alert.alert(
        '',
        'The app will now restart. If you do not see the features enabled that you expected, you may need to force close the app and open it again.',
        [
          { text: 'OK', onPress: this.restartApp },
        ],
        { cancelable: false },
      )
    }
  }

  restartApp = async () => {
    await this.props.navigator.dismiss()
    Helm.reload()
  }

  route = async (route: any) => {
    await this.props.navigator.dismiss()
    this.props.navigator.show(route.url, route.options, route.props)
  }

  render () {
    const path = this.state.path || ''
    const featureFlagEnabled = Boolean(this.state.featureFlagEnabled)
    const routeHistory = routes && routes.length && routes.reduce((accumulator, route) => {
      const subtitle = formattedDueDate(new Date(route.timestamp))
      accumulator.push(<Row title={route.url} subtitle={subtitle} key={`${route.url}-${route.timestamp}`}disclosureIndicator onPress={() => this.route(route) } />)
      accumulator.push(<RowSeparator />)
      return accumulator
    }, [<SectionHeader title='Route History' key={'route-history-section-header'} />])
    return (
      <Screen title='Developer Menu'>
        <ScrollView style={styles.mainContainer} >
          <View style={{ marginTop: 16 }}>
            <TextInput
              value={ path }
              placeholder='enter a route'
              ref='url'
              keyboardType='url'
              returnKeyLabel='Go!'
              returnKeyType='go'
              onChangeText={(path) => {
                this.setState({ path })
              }}
              onSubmitEditing={ this.go }
              style={styles.urlInput} />
            <SegmentedControlIOS
              style={{ margin: 16 }}
              values={['Modal', 'Push', 'Deep Link']}
              selectedIndex={0}
              onChange={(event) => {
                console.log(event.nativeEvent)
                this.setState({ selectedRouteMethod: event.nativeEvent.value })
              }}
            />
          </View>
          <View style={{ flex: 1, flexDirection: 'column' }}>
            <RowSeparator />
            <RowWithSwitch title='Enable Experimental Features' onValueChange={this.toggleExperimentalFeatures} value={featureFlagEnabled} />
            <RowSeparator />
            <Row title='View Push Notifications' disclosureIndicator onPress={this.viewPushNotifications} />
            <RowSeparator />
            <Row title='View Page Views' disclosureIndicator onPress={this.viewPageViews} />
            <RowSeparator />
            <Row title='View Feature Flags' disclosureIndicator onPress={this.viewFeatureFlags} />
            <RowSeparator />
            <Row title='Purge Local Storage' disclosureIndicator onPress={this.purgeStorage} />
            <RowSeparator />
            <Row title='Force Crash' disclosureIndicator onPress={this.forceCrash} />
            <RowSeparator />
            <Row title='Force Native Crash' disclosureIndicator onPress={this.forceNativeCrash} />
            <RowSeparator />
            { routeHistory }
          </View>
        </ScrollView>
      </Screen>
    )
  }
}

let styles = StyleSheet.create({
  mainContainer: {
    flex: 1,
    backgroundColor: 'white',
  },
  urlInput: {
    paddingLeft: 16,
    paddingRight: 16,
    fontSize: 20,
  },
})
