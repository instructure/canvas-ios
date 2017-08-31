//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

// @flow
import { NativeModules } from 'react-native'

declare var Intl: any

export default function localeSort (first: any, second: any, locale?: string): number {
  // Apple gives us the locale/region using an underscore instead of a dash. Silly.
  if (!locale) {
    locale = NativeModules.SettingsManager ? NativeModules.SettingsManager.settings.AppleLocale.replace('_', '-') : 'en'
  }

  // Found a weird case where we were getting a locale back that looked like this en-AF@calendar=gregorian
  if (locale.indexOf('@') !== -1) {
    const index = locale.indexOf('@')
    locale = locale.substr(0, index)
  }
  let collator
  try {
    collator = new Intl.Collator(locale)
  } catch (e) {
    collator = new Intl.Collator('en')
  }
  return collator.compare(first, second)
}

/*
 This can't be tested in our test environment right now.
 Node does not include all of the language data needed
 to do proper sorting. There is a module `full-icu` that
 you can use to give node access to all the language
 data but it will not install with yarn as per this issue
 https://github.com/unicode-org/full-icu-npm/issues/9
 Another alternative would be to use the Intl polyfill
 but that does not include support for Collators. Thus
 there is no way to test this yet
*/
