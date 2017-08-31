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

// @flow

import explore from '../explore'

let {
  describe,
  it,
  expect,
} = global

describe('ComponentExplorer', () => {
  it('should find object by prop', () => {
    const obj = {
      props: {
        text: 'foo',
      },
    }

    expect(explore(obj).selectByProp('text', 'foo')[0]).toEqual(obj)
  })

  it('should find object in array by prop', () => {
    const obj = {
      children: [
        { props: { text: 'foo' } },
      ],
    }

    expect(explore(obj).selectByProp('text', 'foo')).toEqual([obj.children[0]])
  })

  it('should be empty if prop does not exist', () => {
    let obj = {}
    expect(explore(obj).selectByProp('foo', 'bar')).toHaveLength(0)

    obj = { children: [{}] }
    expect(explore(obj).selectByProp('foo', 'bar')).toHaveLength(0)
  })

  it('should find object with query', () => {
    let obj = {}
    const query = (item) => item.foo === 'bar'
    expect(explore(obj).query(query)).toHaveLength(0)

    obj.foo = 'bar'
    expect(explore(obj).query(query)[0]).toEqual(obj)
  })

  it('should find children with query', () => {
    const obj = {
      children: [
        { type: 'bar' },
        { type: 'foo' },
        { type: 'foo' },
      ],
    }
    const query = (item) => {
      return item.type === 'foo'
    }

    const results = explore(obj).query(query)
    expect(results).toHaveLength(2)
    expect(results).toMatchObject([{ type: 'foo' }, { type: 'foo' }])
  })

  it('should select by type', () => {
    const obj = {
      children: [
        { type: 'bar' },
        { type: 'foo' },
        { type: 'foo' },
      ],
    }
    expect(explore(obj).selectByType('bar')).toEqual({ type: 'bar' })
    expect(explore(obj).selectByType('foo')).toEqual({ type: 'foo' })
  })
})
