// @flow
export type EnrollmentType =
  'StudentEnrollment' |
  // I believe `StudentViewEnrollment` is a legacy thing which
  // teachers could use to view their course as a student.
  'StudentViewEnrollment' |
  'TeacherEnrollment' |
  'TaEnrollment' |
  'DesignerEnrollment' |
  'ObserverEnrollment'

export type EnrollmentState = 'active' | 'invited' | 'inactive'

export type Enrollment = {
  id: string,
  user_id: string,
  user: User,
  type: EnrollmentType,
  enrollment_state: EnrollmentState,
  course_id: string,
  last_activity_at: string,
  course_section_id: string,
}
