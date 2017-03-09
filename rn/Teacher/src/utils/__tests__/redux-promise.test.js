import promiseMiddleware from '../redux-promise'
import configureMockStore from 'redux-mock-store'

let mockStore = configureMockStore([promiseMiddleware])

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
  store.dispatch({ type: 'test', payload: promise })

  expect(store.getActions()).toMatchObject([
    { type: 'test', pending: true },
  ])
})

test('it dispatches on resolution', async () => {
  let _resolve = () => {}
  let promise = new Promise((resolve) => { _resolve = resolve })

  let store = mockStore()
  store.dispatch({ type: 'test', payload: promise })

  _resolve('yay')
  await promise // kick the event loop

  expect(store.getActions()).toMatchObject([
    { type: 'test', pending: true },
    { type: 'test', payload: 'yay' },
  ])
})

test('it dispatches on rejection', async () => {
  let _reject = () => {}
  let promise = new Promise((resolve, reject) => { _reject = reject })

  let store = mockStore()
  store.dispatch({ type: 'test', payload: promise })

  let e = new Error('boooo!')
  _reject(e)
  try {
    await promise // kick the event loop
  } catch (e) {}

  expect(store.getActions()).toMatchObject([
    { type: 'test', pending: true },
    { type: 'test', payload: e, error: true },
  ])
})

test('it also checks payload.promise', async () => {
  let _resolve = () => {}
  let promise = new Promise((resolve) => { _resolve = resolve })

  let store = mockStore()
  store.dispatch({ type: 'test', payload: { promise } })

  _resolve('yay')
  await promise // kick the event loop

  expect(store.getActions()).toMatchObject([
    { type: 'test', pending: true },
    { type: 'test', payload: 'yay' },
  ])
})
