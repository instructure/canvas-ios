// @flow
export type EnrollmentType =
  'StudentEnrollment' |
  'TeacherEnrollment' |
  'TaEnrollment' |
  'DesignerEnrollment' |
  'ObserverEnrollment'

export type EnrollmentState = 'active' | 'invited' | 'inactive'

export type Enrollment = {
  +id: string,
  +user_id: string,
  +user: User,
  +type: EnrollmentType,
  +enrollment_state: EnrollmentState,
  +course_id: string,
}
