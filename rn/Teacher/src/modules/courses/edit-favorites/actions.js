// @flow

import { createAction } from 'redux-actions'
import * as coursesApi from './../../../api/canvas-api/courses'

type FavoritesActionsType = {
  toggleFavorite: (courseID: string, markAsFavorite: boolean) => {
    promise: Promise<any>,
    courseID: string,
    markAsFavorite: boolean,
  },
}

export let FavoritesActions: (CoursesApi: any) => any = (api) => ({
  toggleFavorite: createAction('courses.toggleFavorite', (courseID: string, markAsFavorite: boolean) => {
    return {
      promise: markAsFavorite ? api.favoriteCourse(courseID) : api.unfavoriteCourse(courseID),
      courseID,
      markAsFavorite,
    }
  }),
})

export default (FavoritesActions(coursesApi): FavoritesActionsType)
