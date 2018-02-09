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
  props: Props & React$ElementProps<typeof ListView>

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

// $FlowFixMe
export class RefreshableScrollView extends ScrollView {
  props: Props & React$ElementProps<typeof ScrollView>

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
