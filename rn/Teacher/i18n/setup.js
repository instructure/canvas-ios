//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

/* @flow */

import {
  NativeModules,
} from 'react-native'
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

let currentLocale: string = ''
export function getLocale (): string {
  if (!currentLocale) {
    console.warn('You have accessed the locale before it has been set. Are you positive you want to do this?')
    return NativeModules.SettingsManager.settings.AppleLocale
  }

  return currentLocale
}

export default function (locale: ?string): void {
  const sanitizedLocale = sanitizeLocale(locale)
  currentLocale = sanitizedLocale
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
        grade: {
          style: 'decimal',
          minimumFractionDigits: 0,
          maximumFractionDigits: 2,
        },
      },
      date: {
        'MMMM d': { month: 'long', day: 'numeric' },
        'MMM d': { month: 'short', day: 'numeric' },
        'M/d/yyyy': { day: 'numeric', month: 'numeric', year: 'numeric' },
        'MMM d, YYYY': { day: 'numeric', month: 'short', year: 'numeric' },
      },
    },
  })
}
