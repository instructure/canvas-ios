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

import { asyncRefsReducer } from '../async-refs-reducer'

describe('refs reducer', () => {
  const refs = asyncRefsReducer(
    'foobar.baz',
    'The quick brown fox fails to jump over the lazy dog',
    payload => payload.things.map(thing => thing.id)
  )

  const pendingState = refs(undefined, { type: 'foobar.baz', pending: true })

  it('should increment pending', () => {
    expect(pendingState).toEqual({ pending: 1, refs: [] })
  })

  it('should capture refs', () => {
    const action = {
      type: 'foobar.baz',
      payload: {
        things: [
          { id: '1' },
          { id: '2' },
        ],
      },
    }
    expect(refs(pendingState, action)).toEqual({
      pending: 0,
      refs: ['1', '2'],
    })
  })

  it('captures next if it exists', () => {
    const next = () => {}
    const action = {
      type: 'foobar.baz',
      payload: {
        things: [
          { id: '1' },
          { id: '2' },
        ],
        result: {
          next,
        },
      },
    }

    expect(refs(pendingState, action).next).toEqual(next)
  })

  it('appends to refs rather than replace when usedNext is in the payload', () => {
    let action = {
      type: 'foobar.baz',
      payload: {
        things: [
          { id: '1' },
          { id: '2' },
        ],
      },
    }
    let state = refs(pendingState, action)

    action = {
      type: 'foobar.baz',
      payload: {
        things: [
          { id: '3' },
          { id: '4' },
        ],
        usedNext: true,
      },
    }
    expect(refs(state, action).refs).toEqual([
      '1', '2', '3', '4',
    ])
  })

  it('captures error', () => {
    const action = {
      type: 'foobar.baz',
      error: true,
      payload: {
        error: {
          data: {
            errors: [{ message: 'Some wires got crossed' }],
          },
        },
      },
    }
    expect(refs(pendingState, action)).toEqual({
      pending: 0,
      error: `The quick brown fox fails to jump over the lazy dog

Some wires got crossed`,
      refs: [],
    })
  })
})
