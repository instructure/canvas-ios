/* @flow */

import template from '../../utils/template'

export const session: Template<Session> = template({
  authToken: 'iamanauthtoken',
  baseURL: 'http://mobiledev.instructure.com',
  user: {
    name: 'Key and Peele',
    avatar_url: 'https://farm3.staticflickr.com/2926/14690771011_945f91045a.jpg',
    primary_email: 'keyandpeele@instructure.com',
  },
})
