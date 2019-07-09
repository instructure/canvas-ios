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
import { shallow } from 'enzyme'
import React from 'react'
import httpClient, { httpCache } from '../httpClient'
import { fetchPropsFor, type FetchProps } from '../fetch-props-for'

jest.mock('../httpClient')
jest.useFakeTimers()

describe('fetchPropsFor', () => {
  const View = () => {}

  it('always hoists static functions', () => {
    class Test extends React.Component<FetchProps> {
      static electricity = 1
      render () {}
    }
    expect(fetchPropsFor(Test, () => ({})).electricity).toBe(1)
  })

  it('merges passed props, query props, & fetch props', () => {
    const HOC = fetchPropsFor(View, () => ({ b: 'b' }))
    const tree = shallow(<HOC a='a' />)
    expect(tree.find(View).props()).toEqual({
      a: 'a',
      b: 'b',
      api: expect.any(Object),
      isLoading: false,
      isSaving: false,
      loadError: null,
      saveError: null,
      refresh: expect.any(Function),
    })
  })

  it('passes a cache-and-network api to initial query', () => {
    let lastAPI
    const HOC = fetchPropsFor(View, (props: Object, api) => {
      lastAPI = api
      return {}
    })
    shallow(<HOC />)
    expect(lastAPI && lastAPI.options.policy).toBe('cache-and-network')
  })

  it('allows explicit refreshing', () => {
    const query = jest.fn(() => ({ b: 'b' }))
    const HOC = fetchPropsFor(View, query)
    const tree = shallow(<HOC a='a' />)
    expect(query).toHaveBeenCalledTimes(1)
    tree.find(View).prop('refresh')()
    expect(query).toHaveBeenCalledTimes(2)
  })

  it('sets isLoading when an api requests data', () => {
    const HOC = fetchPropsFor(View, (props: Object, api) => ({
      courseColor: api.getCourseColor('1'),
      page: api.getPage('courses', '1', 'test'),
    }))
    const tree = shallow(<HOC />)
    expect(tree.find(View).prop('isLoading')).toBe(true)
  })

  it('unsets isLoading when api requests complete', () => {
    httpClient.get = () => ({ // fake promise
      catch () { return this },
      then: (cb: Function) => setTimeout(cb, 0),
    })
    const HOC = fetchPropsFor(View, (props: Object, api) => ({
      courseColor: api.getCourseColor('1'),
      page: api.getPage('courses', '1', 'test'),
    }))
    const tree = shallow(<HOC />)
    jest.runOnlyPendingTimers()
    tree.update() // make sure rerendered
    expect(tree.find(View).prop('isLoading')).toBe(false)
  })

  it('sends errors in loading data', () => {
    const error = new Error('doh!')
    httpClient.get = () => ({ // fake promise
      catch (cb: Function) { setTimeout(() => cb(error), 0); return this },
      then: (cb: Function) => { cb() },
    })
    const HOC = fetchPropsFor(View, (props: Object, api) => ({
      courseColor: api.getCourseColor('1'),
      page: api.getPage('courses', '1', 'test'),
    }))
    const tree = shallow(<HOC />)
    jest.runOnlyPendingTimers()
    tree.update() // make sure rerendered
    expect(tree.find(View).prop('loadError')).toBe(error)
  })

  it('sets isSaving when an api is called by the view', () => {
    httpClient.get = () => ({ // fake promise
      catch () { return this },
      then: (cb: Function) => setTimeout(cb, 0),
    })
    const HOC = fetchPropsFor(View, () => ({}))
    const tree = shallow(<HOC />)
    expect(tree.find(View).prop('isSaving')).toBe(false)
    const api = tree.find(View).prop('api')
    api.getCourseColor('1')
    api.getCourse('1')
    tree.update()
    expect(tree.find(View).prop('isSaving')).toBe(true)
    jest.runOnlyPendingTimers()
    tree.update()
    expect(tree.find(View).prop('isSaving')).toBe(false)
  })

  it('sends errors in saving data', () => {
    const error = new Error('doh!')
    httpClient.get = () => ({ // fake promise
      catch (cb: Function) { cb(error); return this },
      then: (cb: Function) => setTimeout(cb, 0),
    })
    const HOC = fetchPropsFor(View, () => ({}))
    const tree = shallow(<HOC />)
    expect(tree.find(View).prop('saveError')).toBeNull()
    const api = tree.find(View).prop('api')
    api.getCourseColor('1')
    jest.runOnlyPendingTimers()
    tree.update()
    expect(tree.find(View).prop('saveError')).toBe(error)
  })

  it('refetches invalidated data when httpCache changes', () => {
    const query = jest.fn(() => ({}))
    const HOC = fetchPropsFor(View, query)
    const tree = shallow(<HOC />)
    expect(query).toHaveBeenCalledTimes(1)
    const promise = Promise.resolve()
    tree.instance().saves.add(promise)
    httpCache.handle('GET', 'some/save', '', {}, promise)
    expect(query).toHaveBeenCalledTimes(1) // not called from my save promise

    httpCache.handle('GET', 'unrelated', '')
    expect(clearTimeout).toHaveBeenCalled()
    expect(setTimeout).toHaveBeenCalled()
    jest.runOnlyPendingTimers()
    expect(query).toHaveBeenCalledTimes(2)
  })

  it('cleans up on unmount', () => {
    httpClient.get = () => ({ // fake promise
      catch () { return this },
      then: (cb: Function) => setTimeout(cb, 0),
    })
    const HOC = fetchPropsFor(View, (props: Object, api) => ({
      courseColor: api.getCourseColor('1'),
      page: api.getPage('courses', '1', 'test'),
    }))
    const tree = shallow(<HOC />)
    tree.instance().softRefreshTimer = 1
    const { loads, saves, api, refreshApi, saveApi } = tree.instance()
    loads.clear = saves.clear = jest.fn()
    api.cleanup = refreshApi.cleanup = saveApi.cleanup = jest.fn()
    tree.unmount()
    expect(clearTimeout).toHaveBeenCalledWith(1)
    expect(loads.clear).toHaveBeenCalledTimes(2)
    expect(api.cleanup).toHaveBeenCalledTimes(3)
  })
})
