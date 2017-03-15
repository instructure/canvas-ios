// @flow

import { createAction } from 'redux-actions'
import * as coursesApi from './../../api/canvas-api/courses'

type FavoritesActionsType = {
  toggleFavorite: (courseId: string, favorite: boolean) => {
    promise: Promise<any>,
    courseId: string,
  },
}

export let FavoritesActions: (CoursesApi: any) => any = (api) => ({
  toggleFavorite: createAction('courses.toggleFavorite', (courseId: string, favorite: boolean) => {
    return {
      promise: favorite ? api.favoriteCourse(courseId) : api.unfavoriteCourse(courseId),
      courseId,
    }
  }),
})

export default (FavoritesActions(coursesApi): FavoritesActionsType)
