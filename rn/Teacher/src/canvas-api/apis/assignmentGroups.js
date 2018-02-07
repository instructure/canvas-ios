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

// @flow

import { paginate, exhaust } from '../utils/pagination'

export function getAssignmentGroups (courseID: string, gradingPeriodID?: string, include?: string[]): ApiPromise<AssignmentGroup[]> {
  const url = `courses/${courseID}/assignment_groups`
  let options = {
    params: {
      include: include,
      per_page: 99,
      grading_period_id: gradingPeriodID,
    },
  }

  const groups = paginate(url, options)

  return exhaust(groups)
}
