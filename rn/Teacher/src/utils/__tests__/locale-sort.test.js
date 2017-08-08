// @flow

import { NativeModules } from 'react-native'
import localeSort from '../locale-sort'

test('local sort should work', () => {
  const words = ['zebra', 'alphabet', 'candle']
  const sorted = words.sort((a, b) => localeSort(a, b))
  expect(sorted).toEqual(['alphabet', 'candle', 'zebra'])
})

test('local sort should work with an invalid locale', () => {
  const words = ['zebra', 'alphabet', 'candle']
  const sorted = words.sort((a, b) => localeSort(a, b, 'en-AF@calendar=gregorian'))
  expect(sorted).toEqual(['alphabet', 'candle', 'zebra'])
})

test('local sort should work with a really really invalid locale', () => {
  const words = ['zebra', 'alphabet', 'candle']
  const sorted = words.sort((a, b) => localeSort(a, b, 'this is garbage'))
  expect(sorted).toEqual(['alphabet', 'candle', 'zebra'])
})

test('local sort should work when settings from the device are set', () => {
  NativeModules.SettingsManager = {}
  NativeModules.SettingsManager.settings = {}
  NativeModules.SettingsManager.settings.AppleLocale = 'en_US'
  const words = ['zebra', 'alphabet', 'candle']
  const sorted = words.sort((a, b) => localeSort(a, b))
  expect(sorted).toEqual(['alphabet', 'candle', 'zebra'])
})

test('local sort should work when settings from the device are set', () => {
  const words = ['zebra', 'alphabet', 'candle']
  const sorted = words.sort((a, b) => localeSort(a, b, 'en-GB'))
  expect(sorted).toEqual(['alphabet', 'candle', 'zebra'])
})
