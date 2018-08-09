// @flow

import template, { type Template } from '../utils/template'

export const helpLink: Template<HelpLink> = template({
  id: '1',
  text: 'Custom Link!',
  type: 'custom',
  available_to: ['user', 'student'],
  url: 'https://google.com',
})

export const helpLinks: Template<HelpLinks> = template({
  help_link_name: 'Help and Policies',
  help_link_icon: 'help',
  default_help_links: [],
  custom_help_links: [helpLink()],
})
