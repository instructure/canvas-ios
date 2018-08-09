// @flow

type AvailableTo = 'user' | 'student' | 'teacher' | 'admin' | 'observer' | 'unenrolled'

export type HelpLinks = {
  help_link_name: string,
  help_link_icon: string,
  default_help_links: HelpLink[],
  custom_help_links: HelpLink[],
}

export type HelpLink = {
  id: string,
  text: string,
  type: 'default' | 'custom',
  available_to: AvailableTo[],
  url: string,
}
