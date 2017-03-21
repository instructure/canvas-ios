// @flow

import type { EditFavoritesProps } from './prop-types'
import localeSort from '../../../utils/locale-sort'

export default function mapStateToProps (state: CoursesAppState): EditFavoritesProps {
  let courses = Object.keys(state.entities.courses)
    .map(id => state.entities.courses[id])
    .map(({ course }) => course)
    .sort((c1, c2) => localeSort(c1.name, c2.name))

  return {
    courses,
    favorites: state.favoriteCourses.courseRefs,
  }
}
