/* @flow */

import { createAction } from 'redux-actions'
import canvas from './../../api/canvas-api'
import type { AssignmentListActionProps } from './map-state-to-props'
import { UPDATE_COURSE_DETAILS_SELECTED_TAB_SELECTED_ROW_ACTION } from '../courses/actions'

export let AssignmentListActions: (typeof canvas) => AssignmentListActionProps = (api) => ({
  refreshAssignmentList: createAction('assignmentList.refresh', (courseID: string, gradingPeriodID?: string) => {
    const include = ['assignments', 'all_dates', 'overrides', 'discussion_topic']
    return {
      promise: api.getAssignmentGroups(courseID, gradingPeriodID, include),
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
  refreshAssignmentDetails: createAction('assignment.refreshDetails', (courseID: string, assignmentID: string) => {
    return {
      promise: Promise.all([
        api.getAssignment(courseID, assignmentID),
        api.refreshSubmissionSummary(courseID, assignmentID),
      ]).then(([assignment, dials]) => {
        return Promise.resolve([assignment, dials])
      }),
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
  anonymousGrading: createAction('assignment.anonymous', (courseID: string, assignmentID: string, anonymous: boolean) => ({
    courseID, assignmentID, anonymous,
  })),
})

export default (AssignmentListActions(canvas): AssignmentListActionProps)
