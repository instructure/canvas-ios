/* @flow */

const template = require('../canvas-api/__templates__/session')

export function getSession (): ?Session {
  return template.session()
}
