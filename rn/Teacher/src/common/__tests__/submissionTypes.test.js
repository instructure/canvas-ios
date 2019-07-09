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
