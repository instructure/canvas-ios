const { danger, warn, markdown } = require('danger')
const fs = require('fs')
const _ = require('lodash')
const path = require('path')

// Takes a list of file paths, and converts it into clickable links
function linkableFiles (paths) {
  const repoURL = danger.github.pr.head.repo.html_url
  const ref = danger.github.pr.head.ref
  const links = paths.map((path) => {
    const href = `${repoURL}/blob/${ref}${path}`
    return createLink(href, path)
  })
  return toSentence(links)
}

// ["1", "2", "3"] to "1, 2 and 3"
function toSentence (array) {
  if (array.length === 1) { return array[0] }
  return array.slice(0, array.length - 1).join(', ') + ' and ' + array.pop()
}

// ("/href/thing", "name") to "<a href="/href/thing">name</a>"
function createLink (href, text) {
  return `<a href='${href}'>${text}</a>`
}

// New js files should have `@flow` at the top
function annotations () {
  const newJSFiles = danger.git.created_files.filter((path) => path.startsWith('rn/') && path.endsWith('js'))
  const unFlowedFiles = newJSFiles.filter((filepath) => {
    // Navigating up two directories cuz this dangerfile isn't at the project root
    const content = fs.readFileSync(filepath)
    if (!content) return false
    return !content.includes('@flow')
  })

  if (unFlowedFiles.length > 0) {
    warn(`Please add @flow to these files: ${linkableFiles(unFlowedFiles)}`)
  }
}

// Checks for corresponding tests to js files in the commit's modified files
function untestedFiles () {
  const testFiles = danger.git.created_files.filter((path) => {
    return path.includes('__tests__/') && !path.includes('__snapshots__/')
  })

  const logicalTestPaths = testFiles.map((path) => {
    return path.replace(/__tests__\//, '').replace(/.test.js/, '.js')
  })

  const sourcePaths = danger.git.created_files.filter((path) => {
    const exclude = ['__tests__/', '__snapshots__/', '__mocks__/', '__templates__/', 'flow/']
    return path.includes('src/') &&
      path.includes('js') &&
      exclude.reduce((accl, e) => accl && !path.includes(e), true)
  })

  const untestedFiles = _.difference(sourcePaths, logicalTestPaths)
  if (untestedFiles.length > 0) {
    warn('Please add tests for these files: ' + linkableFiles(untestedFiles))
  }
}

// Checks code coverage
function teacherCoverage () {
  const pr = require('../../rn/Teacher/coverage/coverage-summary.json')
  const master = require('../../rn/Teacher/coverage/coverage-summary-master.json')
  const delta = pr.total.lines.pct - master.total.lines.pct
  markdown(`
    Coverage | New % | Master % | Delta
    -------- | ----- | -------- | -----
    **Teacher** | ${pr.total.lines.pct}% | ${master.total.lines.pct}% | ${delta.toFixed(2)}%
  `.trim().replace(/\n\s+/g, '\n'))
}

annotations()
untestedFiles()
teacherCoverage()
