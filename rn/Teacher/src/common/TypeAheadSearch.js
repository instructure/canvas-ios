// @flow

import axios from 'axios'

type TypeAheadSearchRefresh = () => { promise: Promise<*>, cancel: Function }
type TypeAheadSearchResults = () => { results: ?any[], error: ?string }

export default class TypeAheadSearch {
  refresh: TypeAheadSearchRefresh
  results: TypeAheadSearchResults
  cancelSearch: ?Function

  constructor (refresh: TypeAheadSearchRefresh, results: TypeAheadSearchResults) {
    this.refresh = refresh
    this.results = results
  }

  // Call this whenever the criteria for the search has changed
  execute = () => {
    this.cancel()
    const search = this.refresh()
    const promise = search.promise
    this.cancelSearch = search.cancel

    promise.then((response) => {
      this.results(response.data, null)
    }).catch((thrown) => {
      if (!axios.isCancel(thrown)) {
        this.results(null, thrown.message)
      }
    })
  }

  // Call to cancel the current search
  cancel = () => {
    if (this.cancelSearch) {
      this.cancelSearch()
    }
  }
}
