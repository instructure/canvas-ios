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
import generateId from 'format-message-generate-id/underscored_crc32'
import translations from './locales/index'

export function sanitizeLocale (locale: string): string {
  if (locale.indexOf('@') !== -1) {
    const index = locale.indexOf('@')
    locale = locale.substr(0, index)
  }
  return locale.replace('_', '-')
}

export default function (locale: string): void {
  const sanitizedLocale = sanitizeLocale(locale)
  i18n.setup({
    locale: sanitizedLocale,
    generateId,
    translations,
    formats: {
      date: {
        'MMMM d': { month: 'long', day: 'numeric' },
        'MMM d': { month: 'short', day: 'numeric' },
        'M/d/yyyy': { day: 'numeric', month: 'numeric', year: 'numeric' },
      },
    },
  })
}
