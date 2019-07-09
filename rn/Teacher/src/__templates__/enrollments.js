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

import template, { type Template } from '../utils/template'
import { user } from './users'

export const enrollment: Template<Enrollment> = template({
  id: '32',
  course_id: '1',
  role: '',
  role_id: '',
  user_id: '5123',
  user: user(),
  type: 'StudentEnrollment',
  enrollment_state: 'active',
  last_activity_at: '2017-04-05T15:12:45Z',
  course_section_id: '1',
  grades: {
    html_url: 'https://mobiledev.instructure.com/courses/1/grades/5123',
    current_score: 99,
    override_score: null,
    final_score: 99,
    current_grade: null,
    override_grade: null,
    final_grade: null,
  },
})
