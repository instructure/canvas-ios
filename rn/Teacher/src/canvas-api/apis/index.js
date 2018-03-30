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

import * as accountApi from './account'
import * as coursesApi from './courses'
import * as usersApi from './users'
import * as enrollmentsApi from './enrollments'
import * as submissionsApi from './submissions'
import * as assignmentsApi from './assignments'
import * as quizzesApi from './quizzes'
import * as assignmentGroupsApi from './assignmentGroups'
import * as discussionsApi from './discussions'
import * as conversationApi from './conversations'
import * as groupsApi from './groups'
import * as loginApi from './login'
import * as externalTools from './external-tools'
import * as mediaComments from './media-comments'
import * as fileUploads from './file-uploads'
import * as files from './files'
import * as accounts from './accounts'
import * as userCustomData from './user-custom-data'

export default {
  ...accountApi,
  ...coursesApi,
  ...usersApi,
  ...enrollmentsApi,
  ...groupsApi,
  ...submissionsApi,
  ...assignmentsApi,
  ...quizzesApi,
  ...assignmentGroupsApi,
  ...discussionsApi,
  ...conversationApi,
  ...loginApi,
  ...externalTools,
  ...mediaComments,
  ...fileUploads,
  ...files,
  ...accounts,
  ...userCustomData,
}
