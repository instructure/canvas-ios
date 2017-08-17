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

export class RefreshableScrollView extends ScrollView {
  props: Props & ScrollView.Props

  render () {
    return (
      <ScrollView
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
