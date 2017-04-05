// @flow
export type EnrollmentType =
  'StudentEnrollment' |
  'TeacherEnrollment' |
  'TaEnrollment' |
  'DesignerEnrollment' |
  'ObserverEnrollment'

export type Enrollment = {
  +id: string,
  +user_id: string,
  +user: User,
  +type: EnrollmentType,
}
