// @flow

import moment from 'moment'

export function formattedDate (dateString?: ?string, momentFormat: string = 'LLL'): string {
  if (!dateString) return ''
  return moment(new Date(dateString)).format(momentFormat)
}
