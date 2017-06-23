/* @flow */

import React from 'react'
import 'react-native'
import renderer from 'react-test-renderer'
import TypeAheadSearch, { type Props } from '../TypeAheadSearch'
import httpClient from '../../api/canvas-api/httpClient'
import explore from '../../../test/helpers/explore'

jest
  .mock('react-native-search-bar', () => 'SearchBar')
  .mock('../../api/canvas-api/httpClient')

describe('TypeAheadSearch', () => {
  let props: Props
  beforeEach(() => {
    jest.resetAllMocks()
    const mock = jest.fn(() => Promise.resolve({ data: [] }))
    httpClient().get = mock

    props = {
      endpoint: '/',
      parameters: jest.fn(() => {}),
      onRequestFinished: jest.fn(),
    }
  })

  it('renders a search bar', () => {
    expect(render(props).toJSON()).toMatchSnapshot()
  })

  it('executes search on mount with default query', () => {
    props.defaultQuery = 'Malfurion'
    props.endpoint = '/defaultQuery'
    props.parameters = (query) => ({ search: query })
    const screen = render(props)
    screen.getInstance().componentDidMount()
    expect(httpClient().get).toHaveBeenCalledWith('/defaultQuery', {
      params: { search: 'Malfurion' },
      cancelToken: expect.anything(),
    })
  })

  it('notifies of text change', () => {
    props.onChangeText = jest.fn()
    const screen = render(props)
    const searchBar: any = explore(screen.toJSON()).selectByType('SearchBar')
    searchBar.props.onChangeText('gather tribute')
    expect(props.onChangeText).toHaveBeenCalledWith('gather tribute')
  })

  it('sends request results', () => {
    props.onRequestFinished = jest.fn()
    const data = [{ id: '1' }]
    httpClient().get = jest.fn(() => ({
      then: (callback) => {
        callback({ data, headers: {} })
        return { catch: jest.fn() }
      },
    }))
    const screen = render(props)
    const searchBar: any = explore(screen.toJSON()).selectByType('SearchBar')
    searchBar.props.onChangeText('uther')
    expect(props.onRequestFinished).toHaveBeenCalledWith(data, null)
  })

  it('sends next request results', () => {
    props.onNextRequestFinished = jest.fn()
    const data = [{ id: '1' }]
    const headers = {
      link: '<https://example.com/items?page=1&per_page=1>; rel="current",\
             <https://example.com/items?page=2&per_page=1>; rel="next",\
             <https://example.com/items?page=1&per_page=1>; rel="first",\
             <https://example.com/items?page=4&per_page=1>; rel="last"',
    }
    httpClient().get = jest.fn(() => ({
      then: (callback) => {
        callback({ data, headers })
        return { catch: jest.fn() }
      },
    }))
    const screen = render(props)
    const searchBar: any = explore(screen.toJSON()).selectByType('SearchBar')
    searchBar.props.onChangeText('uther')
    screen.getInstance().next()
    expect(props.onNextRequestFinished).toHaveBeenCalledWith(data, null)
  })

  it('sends request errors', () => {
    props.onRequestFinished = jest.fn()
    httpClient().get = jest.fn(() => ({
      then: jest.fn(() => ({
        catch: (callback) => { callback({ message: 'uh oh' }) },
      })),
    }))
    const screen = render(props)
    const searchBar: any = explore(screen.toJSON()).selectByType('SearchBar')
    searchBar.props.onChangeText('uther')
    expect(props.onRequestFinished).toHaveBeenCalledWith(null, 'uh oh')
  })

  it('should notify when request starts', () => {
    props.onRequestStarted = jest.fn()
    const screen = render(props)
    const searchBar: any = explore(screen.toJSON()).selectByType('SearchBar')
    searchBar.props.onChangeText('gather tribute')
    expect(props.onRequestStarted).toHaveBeenCalled()
  })

  it('unfocuses searchbar on search button presses', () => {
    const mock = jest.fn()
    const createNodeMock = ({ type }) => {
      if (type === 'SearchBar') {
        return {
          unFocus: mock,
        }
      }
    }
    const screen = render(props, { createNodeMock })
    const searchBar: any = explore(screen.toJSON()).selectByType('SearchBar')
    searchBar.props.onSearchButtonPress()
    expect(mock).toHaveBeenCalled()
  })

  it('unfocuses searchbar on cancel button presses', () => {
    const mock = jest.fn()
    const createNodeMock = ({ type }) => {
      if (type === 'SearchBar') {
        return {
          unFocus: mock,
        }
      }
    }
    const screen = render(props, { createNodeMock })
    const searchBar: any = explore(screen.toJSON()).selectByType('SearchBar')
    searchBar.props.onCancelButtonPress()
    expect(mock).toHaveBeenCalled()
  })

  function render (props: Props, options: Object = {}): any {
    return renderer.create(<TypeAheadSearch {...props} />, options)
  }
})
