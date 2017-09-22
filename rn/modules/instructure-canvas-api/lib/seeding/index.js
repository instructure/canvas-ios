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
import faker from 'faker'
import api, { setSession, getSession } from '../'

export async function createTeacher () {
  let courseData: CreateCourse = {
    course: {
      name: faker.lorem.words(3),
      course_code: faker.lorem.word()
    },
    offer: true
  }

  let firstName = faker.name.firstName()
  let lastName = faker.name.lastName()
  let email = `${Date.now()}@${faker.random.uuid()}.com`
  let password = faker.internet.password()

  let userData = {
    user: {
      name: `${firstName} ${lastName}`,
      short_name: `${firstName}`,
      sortable_name: `${lastName}, ${firstName}`,
      terms_of_use: true,
      skip_registration: true
    },
    pseudonym: {
      unique_id: email,
      password: password,
      send_confirmation: false,
    }
  }

  let [{ data: course }, { data: user }] = await Promise.all([
    api.createCourse(courseData),
    api.createUser(userData)
  ])

  let enrollmentData = {
    user_id: user.id,
    type: 'TeacherEnrollment',
    enrollment_state: 'active',
    notify: false,
  }

  await api.enrollUser(course.id, enrollmentData)

  return { email, password }
}