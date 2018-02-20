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

import { createAction } from 'redux-actions'
import canvas from '../../canvas-api'

export const SpeedGraderActions = (api: CanvasApi): * => ({
  excuseAssignment: createAction('submission.excuse', (courseID: string, assignmentID: string, userID: string, submissionID: ?string) => ({
    promise: api.gradeSubmission(courseID, assignmentID, userID, {
      excuse: true,
    }),
    submissionID,
    assignmentID,
  })),
  selectSubmissionFromHistory: createAction('submission.selectFromHistory', (submissionID: string, index: number) => ({
    submissionID,
    index,
  })),
  selectFile: createAction('submission.selectFile', (submissionID: string, index: number) => ({
    submissionID,
    index,
  })),
  gradeSubmission: createAction('submission.grade', (courseID: string, assignmentID: string, userID: string, submissionID: ?string, grade: string) => ({
    promise: api.gradeSubmission(courseID, assignmentID, userID, {
      posted_grade: grade,
    }),
    submissionID,
    assignmentID,
    handlesError: true,
  })),
  gradeSubmissionWithRubric: createAction('submission.gradeWithRubric', (courseID: string, assignmentID: string, userID: string, submissionID: ?string, rubricParams: { [string]: RubricAssessment }) => ({
    promise: api.gradeSubmissionWithRubric(courseID, assignmentID, userID, rubricParams),
    submissionID,
    assignmentID,
    rubricAssessment: rubricParams,
  })),
})

export default (SpeedGraderActions(canvas): *)
