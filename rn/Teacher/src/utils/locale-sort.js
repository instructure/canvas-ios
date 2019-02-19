//
// Copyright (C) 2017-present Instructure, Inc.
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
import { getLocale } from '../../i18n/setup'

let collator: Intl.Collator
export default function localeSort (first: any, second: any): number {
  if (!collator) {
    try {
      collator = new Intl.Collator(getLocale(), { numeric: true })
    } catch (e) {
      collator = new Intl.Collator('en', { numeric: true })
    }
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
