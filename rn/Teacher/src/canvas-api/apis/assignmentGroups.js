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

import { paginate, exhaust } from '../utils/pagination'

export function getAssignmentGroups (courseID: string, gradingPeriodID?: string, include?: string[]): ApiPromise<AssignmentGroup[]> {
  const url = `courses/${courseID}/assignment_groups`
  let options = {
    params: {
      include: include ?? [],
      per_page: 100,
      grading_period_id: gradingPeriodID ?? [],
    },
  }

  const groups = paginate(url, options)

  return exhaust(groups)
}
