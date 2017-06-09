// @flow

import React from 'react'
import {
  ScrollView,
  ListView,
  RefreshControl,
} from 'react-native'

type Props = {
  refreshing: boolean,
  onRefresh: Function,
}

// $FlowFixMe We will be removing this at some point soon
export class RefreshableListView extends ListView {
  props: Props & ListView.Props

  render () {
    return (
      <ListView
        {...this.props}
        refreshControl={
          <RefreshControl
            refreshing={this.props.refreshing}
            onRefresh={this.props.onRefresh}
          />
        }
      />
    )
  }
}

// $FlowFixMe We will be removing this at some point soon
export class RefreshableScrollView extends ScrollView {
  props: Props & ScrollView.Props

  render () {
    return (
      <ScrollView
        {...this.props}
        contentInset={{ bottom: global.tabBarHeight }}
        refreshControl={
          <RefreshControl
            refreshing={this.props.refreshing}
            onRefresh={this.props.onRefresh}
          />
        }
      />
    )
  }
}
