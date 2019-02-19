//
// Copyright (C) 2017-present Instructure, Inc.
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

/* @flow */

import { createAction } from 'redux-actions'
import canvas from '../../canvas-api'
import { UPDATE_COURSE_DETAILS_SELECTED_TAB_SELECTED_ROW_ACTION } from '../courses/actions'

export let AssignmentListActions = (api: CanvasApi): * => ({
  refreshAssignmentList: createAction('assignmentList.refresh', (courseID: string, gradingPeriodID?: string, includeSubmissions?: boolean = false) => {
    const include = ['all_dates', 'overrides', 'discussion_topic', 'observed_users']
    if (includeSubmissions) {
      include.push('submission')
    }
    const promise = Promise.all([
      // TODO: don't include assignments once CNVS-29053 is done
      // must include assignments in order to filter by gradingPeriodID
      api.getAssignmentGroups(courseID, gradingPeriodID, ['assignments']),
      api.getAssignments(courseID, include),
    ]).then(([ groupsResponse, { data: assignments } ]) => {
      for (const group of groupsResponse.data) {
        // TODO: simplify once CNVS-29053 is done
        // Take assignments intersected with group.assignments
        group.assignments = group.assignments.reduce((accum, current) => {
          const assignment = assignments.find(({ id }) => id === current.id)
          if (assignment) {
            if (Array.isArray(assignment.submission)) {
              assignment.submission = assignment.submission[0]
            }
            accum.push(assignment)
          }
          return accum
        }, [])
      }
      return groupsResponse
    })
    return {
      promise,
      courseID,
      gradingPeriodID,
    }
  }),
  refreshAssignment: createAction('assignment.refresh', (courseID: string, assignmentID: string) => {
    return {
      promise: api.getAssignment(courseID, assignmentID),
      courseID,
      assignmentID,
    }
  }),
  refreshAssignmentDetails: createAction('assignment.refreshDetails', (courseID: string, assignmentID: string, getSubmissionStatus?: boolean) => {
    let promises = [api.getAssignment(courseID, assignmentID)]
    if (getSubmissionStatus) {
      promises.push(api.refreshSubmissionSummary(courseID, assignmentID))
    }

    return {
      promise: Promise.all(promises),
      courseID,
      assignmentID,
    }
  }),
  updateAssignment: createAction('assignment.update', (courseID, updatedAssignment, originalAssignment) => {
    return {
      promise: api.updateAssignment(courseID, updatedAssignment),
      courseID,
      updatedAssignment,
      originalAssignment,
      handlesError: true,
    }
  }),
  cancelAssignmentUpdate: createAction('assignment.cancel-update', (originalAssignment) => {
    return { originalAssignment }
  }),
  refreshGradeableStudents: createAction('assignment.gradeable-students', (courseID: string, assignmentID: string) => {
    return {
      promise: api.getAssignmentGradeableStudents(courseID, assignmentID),
      courseID,
      assignmentID,
    }
  }),
  updateCourseDetailsSelectedTabSelectedRow: createAction(UPDATE_COURSE_DETAILS_SELECTED_TAB_SELECTED_ROW_ACTION, (rowID: string) => {
    return { rowID }
  }),
})

export default (AssignmentListActions(canvas): *)
