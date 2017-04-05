// @flow
import * as onlineStatus from '../online-status'

afterAll(() => onlineStatus.updateStatus('wifi'))

test('updateStatus', () => {
  onlineStatus.updateStatus('wifi')
  expect(onlineStatus.getOnlineStatus()).toEqual('wifi')
  onlineStatus.updateStatus('mobile')
  expect(onlineStatus.getOnlineStatus()).toEqual('mobile')
})

test('isOnline', () => {
  onlineStatus.updateStatus('wifi')
  expect(onlineStatus.isOnline()).toBeTruthy()
  onlineStatus.updateStatus('none')
  expect(onlineStatus.isOnline()).toBeFalsy()
})
