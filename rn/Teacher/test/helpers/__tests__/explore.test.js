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
