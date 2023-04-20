//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

import React, { Component } from 'react'
import {
  View,
  TextInput,
  ScrollView,
  Alert,
  NativeModules,
} from 'react-native'
import AsyncStorage from '@react-native-community/async-storage'
import SegmentedControl from '@react-native-community/segmented-control'
import { route, type RouteOptions } from '../../routing'
import Navigator from '../../routing/Navigator'
import Screen from '../../routing/Screen'
import Row from '../../common/components/rows/Row'
import SectionHeader from '../../common/components/rows/SectionHeader'
import RowSeparator from '../../common/components/rows/RowSeparator'
import { formattedDueDate } from '../../common/formatters'
import { createStyleSheet } from '../../common/stylesheet'
const { NativeNotificationCenter, Helm } = NativeModules

const stagingKey = 'teacher.developermenu.path'
const routeHistoryKey = 'teacher.developermenu.route-history'

type DeveloperMenuProps = {
  navigator: Navigator,
}

var routes

async function getRoutes () {
  if (!routes) {
    let json = await AsyncStorage.getItem(routeHistoryKey)
    if (json) {
      routes = JSON.parse(json)
    } else {
      routes = []
    }
  }

  return routes
}

export async function recordRoute (url: string, options: any, props: any) {
  const ignore = ['/dev-menu']
  if (ignore.includes(url)) { return }

  await getRoutes()

  const timestamp = (new Date()).toISOString()
  routes.unshift({ url, options, props, timestamp })
  routes = routes.slice(0, 50)
  await AsyncStorage.setItem(routeHistoryKey, JSON.stringify(routes))
}

export async function getLastRoute () {
  let routes = await getRoutes()
  return routes[0]
}

export default class DeveloperMenu extends Component<DeveloperMenuProps, any> {
  state = {}

  componentDidMount = async () => {
    let path = await AsyncStorage.getItem(stagingKey)
    this.setState({
      path,
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

  viewLogs = () => {
    this.props.navigator.show('/logs')
  }

  viewExperimentalFeatures = () => {
    this.props.navigator.show('/dev-menu/experimental-features', undefined, {
      restartApp: this.restartApp,
    })
  }

  viewRouteHistory = () => {
    this.props.navigator.show('/route-history')
  }

  viewPandaGallery = () => {
    this.props.navigator.show('/dev-menu/pandas')
  }

  viewSnackBarTest = () => {
    this.props.navigator.show('/dev-menu/snackbar', { modal: true, modalPresentationStyle: 'fullscreen', embedInNavigationController: true })
  }

  viewWebSitePreview = async () => {
    await this.props.navigator.dismiss()
    this.props.navigator.show('/dev-menu/website-preview', { modal: true, modalPresentationStyle: 'fullscreen', embedInNavigationController: true })
  }

  manageRatingRequest = () => {
    this.props.navigator.show('/rating-request')
  }

  restartApp = async () => {
    await this.props.navigator.dismiss()
    Helm.reload()
  }

  route = async (route: any) => {
    await this.props.navigator.dismiss()
    const modal = this.state.selectedRouteMethod === 'Modal'
    this.props.navigator.show(route.url, { ...route.options, modal }, route.props)
  }

  render () {
    const path = this.state.path || ''
    const routeHistory = routes && routes.length && routes.reduce((accumulator, route) => {
      const subtitle = formattedDueDate(new Date(route.timestamp))
      accumulator.push(<Row title={route.url} subtitle={subtitle} key={`${route.url}-${route.timestamp}`}disclosureIndicator onPress={() => this.route(route) } />)
      accumulator.push(<RowSeparator />)
      return accumulator
    }, [<SectionHeader title='Route History' key={'route-history-section-header'} />])
    return (
      <Screen title='Developer Menu' rightBarButtons={[{
        title: 'Done',
        action: () => this.props.navigator.dismiss(),
      }]}>
        <ScrollView style={styles.mainContainer} >
          <View>
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
            <SegmentedControl
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
            <Row title='View Experimental Features' disclosureIndicator onPress={this.viewExperimentalFeatures} />
            <RowSeparator />
            <Row title='WebSite Preview' disclosureIndicator onPress={this.viewWebSitePreview} />
            <RowSeparator />
            <Row title='Panda Gallery' disclosureIndicator onPress={this.viewPandaGallery} />
            <RowSeparator />
            <Row title='SnackBar Test' disclosureIndicator onPress={this.viewSnackBarTest} />
            <RowSeparator />
            <Row title='View Push Notifications' disclosureIndicator onPress={this.viewPushNotifications} />
            <RowSeparator />
            <Row title='View Page Views' disclosureIndicator onPress={this.viewPageViews} />
            <RowSeparator />
            <Row title='View Logs' disclosureIndicator onPress={this.viewLogs} />
            <RowSeparator />
            <Row title='Manage Rating Request' disclosureIndicator onPress={this.manageRatingRequest} />
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

const styles = createStyleSheet((colors, vars) => ({
  mainContainer: {
    flex: 1,
    backgroundColor: colors.backgroundLightest,
  },
  urlInput: {
    paddingHorizontal: 16,
    paddingVertical: 12,
    borderBottomWidth: vars.hairlineWidth,
    borderColor: colors.borderMedium,
    borderTopWidth: vars.hairlineWidth,
    fontSize: 20,
  },
}))
