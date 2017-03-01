/* @flow */

import i18n from 'format-message'
import generateId from 'format-message-generate-id/underscored_crc32'
import translations from './locales/index'

export default function (locale: string) {
  i18n.setup({
    locale,
    generateId,
    translations,
  })
}
