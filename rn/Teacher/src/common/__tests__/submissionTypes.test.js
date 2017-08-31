//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

/**
 * @flow
 */

import 'react-native'
import { submissionTypes } from '../submissionTypes'

test('test submission types', () => {
  expect(submissionTypes()).toEqual(
    {
      'discussion_topic': 'Discussion Topic',
      'external_tool': 'External Tool',
      'media_recording': 'Media Recording',
      'none': 'None',
      'on_paper': 'On Paper',
      'online_quiz': 'Online Quiz',
      'online_text_entry': 'Online Text Entry',
      'online_upload': 'Online Upload',
      'online_url': 'Online URL',
    }
  )
})
