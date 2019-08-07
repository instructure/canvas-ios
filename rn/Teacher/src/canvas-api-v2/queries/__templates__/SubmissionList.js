// @flow
import template, { type Template } from '../../../utils/template'
import * as templates from '../../__templates__'

export const submissionListResult: Template<any> = template({
  assignment: templates.assignment({
    course: templates.course({
      groupSet: templates.groupSet(),
      groups: {
        edges: [{ group: templates.group() }],
      },
      sections: {
        edges: [{ section: templates.section() }],
      },
    }),
    submissions: {
      edges: [{ submission: templates.submission({
        user: templates.user(),
      }) }],
    },
    groupedSubmissions: {
      edges: [{ submission: templates.submission({
        user: templates.user(),
      }) }],
    },
  }),
})
