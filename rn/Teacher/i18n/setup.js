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

/* @flow */

import i18n from 'format-message'
import translations from './locales/index'

// Some crashing happening because a locale is not returned, so I've made this an optional
// and if we can't get a locale, default to english
export function sanitizeLocale (locale: ?string): string {
  if (!locale) return 'en'
  // Found some crash reports with this causing issues.
  // Apparently apple uses that locale sometimes and it just means english.
  if (locale === 'en-US_POSIX') return 'en'
  if (locale.indexOf('@') !== -1) {
    const index = locale.indexOf('@')
    locale = locale.substr(0, index)
  }
  return locale.replace('_', '-')
}

export default function (locale: ?string): void {
  const sanitizedLocale = sanitizeLocale(locale)
  i18n.setup({
    // generateId underscored_crc32 done via babel transform
    locale: sanitizedLocale,
    translations,
    missingTranslation: 'ignore',
    formats: {
      number: {
        default: {
          style: 'decimal',
          minimumFractionDigits: 0,
          maximumFractionDigits: 2,
        },
        percent: {
          style: 'percent',
          minimumFractionDigits: 0,
          maximumFractionDigits: 2,
        },
      },
      date: {
        'MMMM d': { month: 'long', day: 'numeric' },
        'MMM d': { month: 'short', day: 'numeric' },
        'M/d/yyyy': { day: 'numeric', month: 'numeric', year: 'numeric' },
      },
    },
  })
}
