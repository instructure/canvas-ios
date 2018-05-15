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
import hoistStatics from 'hoist-non-react-statics'

export type RefreshFunction = (*) => *
export type ShouldRefresh = (*) => boolean
export type IsFetchingData = (*) => boolean
export type TtlKeyExtractor = (*) => string

const DEFAULT_TTL_KEY = 'default'

export default function refresh (
  refreshFunction: RefreshFunction,
  shouldRefresh: ShouldRefresh,
  isFetchingData: IsFetchingData,
  ttl: ?number = 1000 * 60 * 60, // 1 hour
  ttlKeyExtractor: TtlKeyExtractor = (props) => DEFAULT_TTL_KEY,
) {
  let updates = {}

  return function (TheirComponent: React$ElementType) {
    class Refreshed extends Component<*, RefreshState> {
      state: RefreshState = { refreshing: false }

      refreshFunction = refreshFunction
      shouldRefresh = shouldRefresh
      isFetchingData = isFetchingData

      componentWillReceiveProps (nextProps) {
        this.setState({
          refreshing: this.state.refreshing
            ? isFetchingData(nextProps)
            : false,
        })
      }

      componentWillMount () {
        if (this.props.forceRefresh || shouldRefresh(this.props)) {
          this.setLastUpdate(Date.now())
          refreshFunction(this.props)
        } else if (!this.getLastUpdate() || Date.now() > this.getLastUpdate() + ttl) {
          this.refresh()
        }
      }

      refresh = () => {
        this.setState({ refreshing: true }, () => {
          this.setLastUpdate(Date.now())
          refreshFunction(this.props)
        })
      }

      setLastUpdate = (date: number) => {
        updates[ttlKeyExtractor(this.props)] = date
      }

      getLastUpdate = () => updates[ttlKeyExtractor(this.props)]

      render = () => <TheirComponent {...this.props} refresh={this.refresh} refreshing={this.state.refreshing} />
    }

    return hoistStatics(Refreshed, TheirComponent)
  }
}
