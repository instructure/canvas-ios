//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

// @flow

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

export default ({
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
}: *)
