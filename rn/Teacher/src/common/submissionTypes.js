/**
 * @flow
 */

import i18n from 'format-message'

export const SUBMISSION_TYPES: { [string]: string } = {
  'discussion_topic': i18n({ default: 'discussion topic', description: 'assignment submission type' }),
  'online_quiz': i18n({ default: 'online quiz', description: 'assignment submission type' }),
  'on_paper': i18n({ default: 'on paper', description: 'assignment submission type' }),
  'external_tool': i18n({ default: 'external tool', description: 'assignment submission type' }),
  'online_text_entry': i18n({ default: 'online text entry', description: 'assignment submission type' }),
  'online_url': i18n({ default: 'online url', description: 'assignment submission type' }),
  'online_upload': i18n({ default: 'online upload', description: 'assignment submission type' }),
  'media_recording': i18n({ default: 'media recording', description: 'assignment submission type' }),
  'none': i18n({ default: 'none', description: 'assignment submission type' }),
}
