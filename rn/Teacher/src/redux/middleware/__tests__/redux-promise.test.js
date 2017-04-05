// @flow

import mockStore from '../../../../test/helpers/mockStore'

test('it does nothing with a "normal" payload', async () => {
  let store = mockStore()
  store.dispatch({ type: 'test', payload: 'plain jane' })

  expect(store.getActions()).toMatchObject([
    { type: 'test', payload: 'plain jane' },
  ])
})

test('it immediately dispatches pending', async () => {
  let promise = new Promise(() => {})

  let store = mockStore()
  store.dispatch({ type: 'test', payload: { promise } })

  expect(store.getActions()).toMatchObject([
    { type: 'test', pending: true },
  ])
})

test('it dispatches on resolution', async () => {
  let _resolve = () => {}
  let promise = new Promise((resolve) => { _resolve = resolve })

  let store = mockStore()
  store.dispatch({ type: 'test', payload: { promise, id: 1 } })

  _resolve('yay')
  await promise // kick the event loop

  expect(store.getActions()).toMatchObject([
    { type: 'test', pending: true, payload: { id: 1 } },
    { type: 'test', payload: { result: 'yay', id: 1 } },
  ])
})

test('it dispatches on rejection', async () => {
  let error = new Error()
  let promise = Promise.reject(error)

  let store = mockStore()
  store.dispatch({ type: 'test', payload: { id: 1, promise } })

  try {
    await promise
  } catch (e) {}

  expect(store.getActions()).toMatchObject([
    {
      type: 'test',
      pending: true,
      payload: {
        id: 1,
        promise,
      },
    },
    {
      type: 'test',
      payload: {
        id: 1,
        error,
      },
      error: true,
    },
  ])
})
