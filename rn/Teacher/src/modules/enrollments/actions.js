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

export const EnrollmentsActions = (api: CanvasApi): * => ({
  refreshEnrollments: createAction('enrollments.update', (courseID: string) => ({
    promise: api.getCourseEnrollments(courseID),
    courseID,
  })),
  refreshUserEnrollments: createAction('enrollments.user-update', (userID?: string = 'self') => ({
    promise: api.getUserEnrollments(userID),
    userID,
  })),
  acceptEnrollment: createAction('enrollments.accept', (courseID: string, enrollmentID: string) => ({
    promise: api.acceptEnrollment(courseID, enrollmentID),
    courseID,
    enrollmentID,
  })),
  rejectEnrollment: createAction('enrollments.reject', (courseID: string, enrollmentID: string) => ({
    promise: api.rejectEnrollment(courseID, enrollmentID),
    courseID,
    enrollmentID,
  })),
  hideInvite: createAction('enrollments.hide', (enrollmentID: string) => ({
    enrollmentID,
  })),
})

export default (EnrollmentsActions(canvas): *)
