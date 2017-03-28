/**
 * @flow
 */

import 'react-native'
import { SUBMISSION_TYPES } from '../submissionTypes'

test('test submission types', () => {
  expect(SUBMISSION_TYPES).toEqual(
    {
      'discussion_topic': 'discussion topic',
      'external_tool': 'external tool',
      'media_recording': 'media recording',
      'none': 'none',
      'on_paper': 'on paper',
      'online_quiz': 'online quiz',
      'online_text_entry': 'online text entry',
      'online_upload': 'online upload',
      'online_url': 'online url',
    }
  )
})
