// @flow

import App from '../'

const template = {
  ...require('../../../__templates__/course'),
}

describe('App', () => {
  let app

  describe('teacher', () => {
    beforeEach(() => {
      App.setCurrentApp('teacher')
      app = App.current()
    })

    describe('filterCourse', () => {
      it('filters courses access restricted by date', () => {
        const restricted = template.course({ access_restricted_by_date: true })
        const available = template.course({ access_restricted_by_date: false })
        const result = [restricted, available].filter(app.filterCourse)
        expect(result).toEqual([available])
      })
    })
  })

  describe('student', () => {
    beforeEach(() => {
      App.setCurrentApp('student')
      app = App.current()
    })

    describe('filterCourse', () => {
      it('filters courses access restricted by date', () => {
        const restricted = template.course({ access_restricted_by_date: true })
        const available = template.course({ access_restricted_by_date: false })
        const result = [restricted, available].filter(app.filterCourse)
        expect(result).toEqual([available])
      })
    })
  })
})
