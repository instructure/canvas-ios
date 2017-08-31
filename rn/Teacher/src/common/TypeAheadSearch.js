// @flow

import React, { Component } from 'react'
import SearchBar from 'react-native-search-bar'
import { httpClient } from 'canvas-api'
import { parseNext } from 'canvas-api/utils/pagination'
import axios, { CancelToken } from 'axios'
import i18n from 'format-message'

export type TypeAheadSearchResults = () => { results: ?any[], error: ?string }

export type Props = {
  endpoint: string,
  parameters: (query: string) => { [string]: any },
  onRequestFinished: TypeAheadSearchResults,
  onNextRequestFinished?: TypeAheadSearchResults,
  onRequestStarted?: () => void,
  onChangeText?: (query: string) => void,
  defaultQuery?: string,
}

export default class TypeAheadSearch extends Component<any, Props, any> {
  searchBar: SearchBar
  nextURL: ?string
  cancel: ?(() => void)

  execute = (query: string) => {
    this.props.onChangeText && this.props.onChangeText(query)
    this.fetch(this.props.endpoint, this.props.parameters(query), this.props.onRequestFinished)
  }

  async fetch (url: string, params: { [string]: any } = {}, callback: TypeAheadSearchResults) {
    this.cancel && this.cancel()
    const cancelToken = new CancelToken((c) => { this.cancel = c })
    const options = {
      params,
      cancelToken,
    }

    this.props.onRequestStarted && this.props.onRequestStarted()
    try {
      let response = await httpClient().get(url, options)
      this.nextURL = parseNext(response)
      callback(response.data, null)
    } catch (thrown) {
      if (!axios.isCancel(thrown)) {
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
        placeholder={i18n('Search')}
      />
    )
  }
}
