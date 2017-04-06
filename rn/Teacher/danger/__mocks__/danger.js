/* @flow */

// $FlowFixMe
const danger = require.requireActual('danger')

function __setGit (git: any): void {
  danger.git = git
}

function __setGithub (github: any): void {
  danger.github = github
}

danger.__setGithub = __setGithub
danger.__setGit = __setGit
danger.__TEST__ = true

const warn: Function = jest.fn()

module.exports = { danger, warn }
