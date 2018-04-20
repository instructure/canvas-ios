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

export function submissionTypeIsOnline (submissionType: SubmissionType): boolean {
  return submissionType !== 'on_paper' && submissionType !== 'none'
}

