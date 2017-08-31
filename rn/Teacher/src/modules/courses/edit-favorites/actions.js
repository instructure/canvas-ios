// @flow

import { createAction } from 'redux-actions'
import canvas from 'canvas-api'

export let FavoritesActions = (api: CanvasApi): * => ({
  toggleFavorite: createAction('courses.toggleFavorite', (courseID: string, markAsFavorite: boolean) => {
    return {
      promise: markAsFavorite ? api.favoriteCourse(courseID) : api.unfavoriteCourse(courseID),
      courseID,
      markAsFavorite,
    }
  }),
})

export default (FavoritesActions(canvas): *)
