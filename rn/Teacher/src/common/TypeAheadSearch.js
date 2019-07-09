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

import React, { Component } from 'react'
import SearchBar from 'react-native-search-bar'
import { httpClient, isAbort } from '../canvas-api'
import { parseNext } from '../canvas-api/utils/pagination'
import i18n from 'format-message'

export type TypeAheadSearchResults = (results: ?any[], error: ?string) => void

export type Props = {
  endpoint: string,
  parameters: (query: string) => { [string]: any },
  onRequestFinished: TypeAheadSearchResults,
  onNextRequestFinished?: TypeAheadSearchResults,
  onRequestStarted?: () => void,
  onChangeText?: (query: string) => void,
  defaultQuery?: string,
  minimumQueryLength: number,
  placeholder: string,
}

export default class TypeAheadSearch extends Component<Props> {
  searchBar: SearchBar
  nextURL: ?string
  cancel: ?(() => void)

  static defaultProps = {
    minimumQueryLength: 0,
    placeholder: i18n('Search'),
  }

  execute = (query: string) => {
    this.props.onChangeText && this.props.onChangeText(query)
    if (query.length < this.props.minimumQueryLength) {
      return
    }
    this.fetch(this.props.endpoint, this.props.parameters(query), this.props.onRequestFinished)
  }

  async fetch (url: string, params: { [string]: any } = {}, callback: TypeAheadSearchResults) {
    this.cancel && this.cancel()

    this.props.onRequestStarted && this.props.onRequestStarted()
    try {
      const fetching = httpClient.get(url, { params })
      if (fetching.request) {
        this.cancel = () => fetching.request && fetching.request.abort()
      }
      let response = await fetching
      this.nextURL = parseNext(response)
      callback(response.data, null)
    } catch (thrown) {
      if (!isAbort(thrown)) {
        callback(null, thrown.message)
      }
    }
  }

  next () {
    this.nextURL && this.props.onNextRequestFinished && this.fetch(this.nextURL, {}, this.props.onNextRequestFinished)
  }

  componentDidMount () {
    if (this.props.defaultQuery != null) {
      this.execute(this.props.defaultQuery)
    }
  }

  render () {
    return (
      <SearchBar
        ref={ (r) => { this.searchBar = r }}
        onChangeText={this.execute}
        onSearchButtonPress={() => this.searchBar.unFocus()}
        onCancelButtonPress={() => this.searchBar.unFocus()}
        placeholder={this.props.placeholder}
        hideBackground
        textFieldBackgroundColor='#F1F1F2'
      />
    )
  }
}
