import Actions from './actions'
import { asyncRefsReducer } from '../../redux/async-refs-reducer'
import i18n from 'format-message'

const { refreshGradeableStudents } = Actions

function refsForResponse ({ result }: Response): EntityRefs {
  return result.data.map(submission => submission.id)
}

export const gradeableStudentsRefs: Reducer<AsyncRefs, any> = asyncRefsReducer(
  refreshGradeableStudents.toString(),
  i18n('There was a problem loading the assignment submissions.'),
  refsForResponse
)

export default gradeableStudentsRefs
