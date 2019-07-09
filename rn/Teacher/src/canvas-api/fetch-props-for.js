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
import hoistStatics from 'hoist-non-react-statics'
import * as React from 'react'
import { API, httpCache as cache } from './model-api'

export type FetchProps = {
  api: API,
  isLoading: boolean,
  isSaving: boolean,
  loadError: ?Error,
  saveError: ?Error,
  refresh: () => void,
}

export function fetchPropsFor<AllProps: Object, Statics: Object, HocProps: Object> (
  View: React.ComponentType<AllProps> & Statics,
  query: (HocProps, API) => $Diff<$Diff<AllProps, FetchProps>, HocProps>
): React.ComponentType<HocProps> & Statics {
  type State = $Diff<$Diff<AllProps, FetchProps>, HocProps> & FetchProps
  class Wrapper extends React.PureComponent<HocProps, State> {
    loads: Set<ApiPromise<any>> = new Set()
    saves: Set<ApiPromise<any>> = new Set()
    softRefreshTimer: TimeoutID | void
    isReady: boolean = false

    update (state: $Shape<State>) {
      if (this.isReady) {
        this.setState(state)
      } else {
        // $FlowFixMe
        this.state = { ...this.state, ...state }
      }
    }

    refresh = () => {
      this.update(query(this.props, this.refreshApi))
    }

    handleLoadStart = (request: ApiPromise<any>) => {
      if (this.loads.size === 0) {
        this.update({ isLoading: true, loadError: null })
      }
      this.loads.add(request)
    }

    handleLoadComplete = (request: ApiPromise<any>) => {
      this.loads.delete(request)
      this.update(query(this.props, this.cachedApi))
      if (this.loads.size === 0) {
        this.update({ isLoading: false })
      }
    }

    handleLoadError = (loadError: Error) => {
      this.update({ loadError })
    }

    handleSaveStart = (request: ApiPromise<any>) => {
      if (this.saves.size === 0) {
        this.update({ isSaving: true, saveError: null })
      }
      this.saves.add(request)
    }

    handleSaveComplete = (request: ApiPromise<any>) => {
      this.saves.delete(request)
      this.update(query(this.props, this.cachedApi))
      if (this.saves.size === 0) {
        this.update({ isSaving: false })
      }
    }

    handleSaveError = (saveError: Error) => {
      this.update({ saveError })
    }

    unsubscribe = cache.subscribe((request: ?ApiPromise<any>) => {
      if (request && (this.loads.has(request) || this.saves.has(request))) return
      clearTimeout(this.softRefreshTimer)
      this.softRefreshTimer = setTimeout(() => {
        this.softRefreshTimer = undefined
        this.update(query(this.props, this.api)) // refetch if invalidated
      }, 1000)
    })

    api = new API({
      policy: 'cache-and-network',
      onStart: this.handleLoadStart,
      onComplete: this.handleLoadComplete,
      onError: this.handleLoadError,
    })

    refreshApi = new API({
      policy: 'network-only',
      onStart: this.handleLoadStart,
      onComplete: this.handleLoadComplete,
      onError: this.handleLoadError,
    })

    saveApi = new API({
      policy: 'network-only',
      onStart: this.handleSaveStart,
      onComplete: this.handleSaveComplete,
      onError: this.handleSaveError,
    })

    cachedApi = new API({
      policy: 'cache-only',
    })

    state = {
      ...query(this.props, this.api),
      api: this.saveApi,
      isLoading: this.loads.size > 0,
      isSaving: this.saves.size > 0,
      loadError: null,
      saveError: null,
      refresh: this.refresh,
    }

    componentWillUnmount () {
      // prevent calling setState on unmounted component
      this.isReady = false
      this.unsubscribe()
      this.api.cleanup()
      this.refreshApi.cleanup()
      this.saveApi.cleanup()
      this.loads.clear()
      this.saves.clear()
      clearTimeout(this.softRefreshTimer)
      this.softRefreshTimer = undefined
    }

    render () {
      this.isReady = true // start using setState
      return <View {...this.props} {...this.state} />
    }
  }
  Wrapper.displayName = View.displayName || View.name
  // $FlowFixMe Mixing spread and intersection prop types causes confusion
  return hoistStatics(Wrapper, View)
}
