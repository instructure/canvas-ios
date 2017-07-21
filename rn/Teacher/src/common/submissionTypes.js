/**
 * @flow
 */

import i18n from 'format-message'

export function submissionTypes (): { [string]: string } {
  return {
    'discussion_topic': i18n('Discussion Topic'),
    'online_quiz': i18n('Online Quiz'),
    'on_paper': i18n('On Paper'),
    'external_tool': i18n('External Tool'),
    'online_text_entry': i18n('Online Text Entry'),
    'online_url': i18n('Online URL'),
    'online_upload': i18n('Online Upload'),
    'media_recording': i18n('Media Recording'),
    'none': i18n('None'),
  }
}
