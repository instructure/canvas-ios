//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

/* eslint-disable flowtype/require-valid-file-annotation */

import React from 'react'
import 'react-native'
import { shallow } from 'enzyme'
import TypeAheadSearch, { type Props } from '../TypeAheadSearch'
import { httpClient } from '../../canvas-api'

jest.mock('../../canvas-api/httpClient')

describe('TypeAheadSearch', () => {
  let props: Props = {
    endpoint: '/',
    parameters: jest.fn(() => {}),
    onRequestFinished: jest.fn(),
    onRequestStarted: jest.fn(),
    onNextRequestFinished: jest.fn(),
  }
  beforeEach(() => {
    jest.clearAllMocks()
  })

  it('renders a search bar', () => {
    expect(shallow(<TypeAheadSearch {...props} />)).toMatchSnapshot()
  })

  it('executes search on mount with default query', () => {
    props.defaultQuery = 'Malfurion'
    props.endpoint = '/defaultQuery'
    props.parameters = (query) => ({ search: query })
    shallow(<TypeAheadSearch {...props} />)
    expect(httpClient().get).toHaveBeenCalledWith('/defaultQuery', {
      params: { search: 'Malfurion' },
    })
  })

  it('notifies of text change', () => {
    props.onChangeText = jest.fn()
    const screen = shallow(<TypeAheadSearch {...props} />)
    screen.find('SearchBar').simulate('ChangeText', 'gather tribute')
    expect(props.onChangeText).toHaveBeenCalledWith('gather tribute')
  })

  it('sends request results', async () => {
    const data = [{ id: '1' }]
    let p = Promise.resolve({ data, headers: {} })
    httpClient().get.mockReturnValueOnce(p)

    const screen = shallow(<TypeAheadSearch {...props} />)
    screen.find('SearchBar').simulate('ChangeText', 'uther')
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

    const screen = shallow(<TypeAheadSearch {...props} />)
    screen.find('SearchBar').simulate('ChangeText', 'uther')
    await p1
    expect(props.onRequestFinished).toHaveBeenCalled()

    let p2 = Promise.resolve({ data, headers: {} })
    httpClient().get.mockReturnValueOnce(p2)
    screen.instance().next()

    await p2
    expect(props.onNextRequestFinished).toHaveBeenCalledWith(data, null)
  })

  it('sends request errors', () => {
    let rejectedPromise = Promise.reject({ message: 'uh oh' })
    httpClient().get.mockReturnValueOnce(rejectedPromise)

    const screen = shallow(<TypeAheadSearch {...props} />)
    screen.find('SearchBar').simulate('ChangeText', 'uther')

    rejectedPromise.catch(() => {
      expect(props.onRequestFinished).toHaveBeenCalledWith(null, 'uh oh')
    })
  })

  it('should notify when request starts', () => {
    httpClient().get.mockReturnValueOnce(Promise.resolve())
    const screen = shallow(<TypeAheadSearch {...props} />)
    screen.find('SearchBar').simulate('ChangeText', 'gather tribute')
    expect(props.onRequestStarted).toHaveBeenCalled()
  })

  it('unfocuses searchbar on search button presses', () => {
    const unFocus = jest.fn()
    const screen = shallow(<TypeAheadSearch {...props} />)
    screen.find('SearchBar').getElement().ref({ unFocus })
    screen.find('SearchBar').simulate('SearchButtonPress')
    expect(unFocus).toHaveBeenCalled()
  })

  it('unfocuses searchbar on cancel button presses', () => {
    const unFocus = jest.fn()
    const screen = shallow(<TypeAheadSearch {...props} />)
    screen.find('SearchBar').getElement().ref({ unFocus })
    screen.find('SearchBar').simulate('CancelButtonPress')
    expect(unFocus).toHaveBeenCalled()
  })
})
