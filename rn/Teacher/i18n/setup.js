/* @flow */

import i18n from 'format-message'
import generateId from 'format-message-generate-id/underscored_crc32'
import translations from './locales/index'

export function sanitizeLocale (locale: string): string {
  return locale.replace('_', '-')
}

export default function (locale: string): void {
  const sanitizedLocale = sanitizeLocale(locale)
  i18n.setup({
    locale: sanitizedLocale,
    generateId,
    translations,
  })
}
