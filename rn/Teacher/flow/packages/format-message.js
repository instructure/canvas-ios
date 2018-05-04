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
type FormatMessage = {
  (message: MessageInfo, params?: Object, locale?: string): string,
  number (value: number, style?: string): string,
  date (value: number | Date, style?: string): string,
  time (value: number | Date, style?: string): string,
  select<T> (value: number, options?: { [id: string]: T }): T,
  selectordinal<T> (value: number, options?: { [id: string]: T }): T,
  plural<T> (value: number, options?: { [id: string]: T }): T,
  setup (options?: FormatMessageOptions): FormatMessageOptions,
  namespace (): FormatMessage,
}

type MessageInfo = string | {|
  id?: string,
  default?: string,
  description?: string,
|}

type FormatMessageOptions = {
  locale?: string,
  translations?: {
    [locale: string]: {
      [id: string]: {
        message: string,
        description?: string,
      },
    },
  },
  generateId?: (message: string) => string,
  missingReplacement?: string | (pattern?: string, id?: string, locale?: string) => string,
  missingTranslation?: 'ignore' | 'warning' | 'error',
  formats?: {
    number?: {
      [style: string]: {
        localeMatcher?: 'lookup' | 'best fit',
        style?: 'decimal' | 'currency' | 'percent',
        currency?: string,
        currencyDisplay?: 'symbol' | 'code' | 'name',
        useGrouping?: boolean,
        minimumIntegerDigits?: number,
        minimumFractionDigits?: number,
        maximumFractionDigits?: number,
        minimumSignificantDigits?: number,
        maximumSignificantDigits?: number,
      },
    },
    date?: {
      [style: string]: {
        localeMatcher?: 'lookup' | 'best fit',
        timeZone?: string,
        formatMatcher?: 'basic' | 'best fit',
        weekday?: 'narrow' | 'short' | 'long',
        era?: 'narrow' | 'short' | 'long',
        year?: 'numeric' | '2-digit',
        month?: 'numeric' | '2-digit' | 'narrow' | 'short' | 'long',
        day?: 'numeric' | '2-digit',
        hour?: 'numeric' | '2-digit',
        minute?: 'numeric' | '2-digit',
        second?: 'numeric' | '2-digit',
        timeZoneName?: 'short' | 'long',
      },
    },
    time?: {
      [style: string]: {
        localeMatcher?: 'lookup' | 'best fit',
        timeZone?: string,
        hour12?: boolean,
        formatMatcher?: 'basic' | 'best fit',
        hour?: 'numeric' | '2-digit',
        minute?: 'numeric' | '2-digit',
        second?: 'numeric' | '2-digit',
        timeZoneName?: 'short' | 'long',
      },
    },
  },
}

declare module 'format-message' {
  declare module.exports: FormatMessage
}
