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
