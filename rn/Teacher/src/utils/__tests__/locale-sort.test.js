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
