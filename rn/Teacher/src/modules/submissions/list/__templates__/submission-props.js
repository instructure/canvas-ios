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

// @flow

import template, { type Template } from '../../../../utils/template'
import type { SubmissionDataProps } from '../submission-prop-types'

const templates = {
  ...require('../../../../__templates__/submissions'),
}

const submissionWithHistory = templates.submissionHistory()

// $FlowFixMe
export const submissionProps: Template<SubmissionDataProps> = template({
  grade: 'B-',
  name: submissionWithHistory.user.name,
  status: 'submitted',
  userID: submissionWithHistory.user.id,
  avatarURL: submissionWithHistory.user.avatar_url,
  sectionID: '1',
})
