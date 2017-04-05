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

  it('captures error', () => {
    const action = {
      type: 'foobar.baz',
      error: true,
      payload: {
        data: {
          errors: [{ message: 'Some wires got crossed' }],
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
