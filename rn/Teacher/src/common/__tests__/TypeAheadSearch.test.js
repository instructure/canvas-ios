/* @flow */

import React from 'react'
import 'react-native'
import renderer from 'react-test-renderer'
import TypeAheadSearch, { type Props } from '../TypeAheadSearch'
import { httpClient } from 'canvas-api'
import explore from '../../../test/helpers/explore'

jest
  .mock('react-native-search-bar', () => 'SearchBar')
  .mock('canvas-api')

describe('TypeAheadSearch', () => {
  let props: Props = {
    endpoint: '/',
    parameters: jest.fn(() => {}),
    onRequestFinished: jest.fn(),
    onRequestStarted: jest.fn(),
    onNextRequestFinished: jest.fn(),
  }
  beforeEach(() => {
    jest.resetAllMocks()
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

  it('sends request results', async () => {
    const data = [{ id: '1' }]
    let p = Promise.resolve({ data, headers: {} })
    httpClient().get.mockReturnValueOnce(p)

    const screen = render(props)
    const searchBar: any = explore(screen.toJSON()).selectByType('SearchBar')
    searchBar.props.onChangeText('uther')

    await p
    expect(props.onRequestFinished).toHaveBeenCalledWith(data, null)
  })

  it('sends next request results', async () => {
    const data = [{ id: '1' }]
    const headers = {
      link: '<https://example.com/items?page=1&per_page=1>; rel="current",\
             <https://example.com/items?page=2&per_page=1>; rel="next",\
             <https://example.com/items?page=1&per_page=1>; rel="first",\
             <https://example.com/items?page=4&per_page=1>; rel="last"',
    }
    let p1 = Promise.resolve({ data, headers })
    httpClient().get.mockReturnValueOnce(p1)

    const screen = render(props)
    const searchBar: any = explore(screen.toJSON()).selectByType('SearchBar')
    searchBar.props.onChangeText('uther')
    await p1
    expect(props.onRequestFinished).toHaveBeenCalled()

    let p2 = Promise.resolve({ data, headers: {} })
    httpClient().get.mockReturnValueOnce(p2)
    screen.getInstance().next()

    await p2
    expect(props.onNextRequestFinished).toHaveBeenCalledWith(data, null)
  })

  it('sends request errors', () => {
    let rejectedPromise = Promise.reject({ message: 'uh oh' })
    httpClient().get.mockReturnValueOnce(rejectedPromise)

    const screen = render(props)
    const searchBar: any = explore(screen.toJSON()).selectByType('SearchBar')
    searchBar.props.onChangeText('uther')

    rejectedPromise.catch(() => {
      expect(props.onRequestFinished).toHaveBeenCalledWith(null, 'uh oh')
    })
  })

  it('should notify when request starts', () => {
    httpClient().get.mockReturnValueOnce(Promise.resolve())
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
