const { danger, warn } = require('danger')
const fs = require('fs')
const path = require('path')
const { checkCoverage } = require('./dangerfile-utils')

// Takes a list of file paths, and converts it into clickable links
function linkableFiles (paths) {
  const repoURL = danger.github.pr.head.repo.html_url
  const ref = danger.github.pr.head.ref
  const links = paths.map((path) =>
    `[${path}](${repoURL}/blob/${ref}${path})`
  )
  return toSentence(links)
}

// ["1", "2", "3"] to "1, 2, and 3"
function toSentence (array) {
  if (array.length === 1) { return array[0] }
  return array.slice(0, -1).join(', ') + ', and ' + array.slice(-1)[0]
}

// New js files should have `@flow` at the top
function annotations () {
  const newJSFiles = danger.git.created_files.filter((path) => path.startsWith('rn/') && path.endsWith('js'))
  const unFlowedFiles = newJSFiles.filter((filepath) => {
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
      exclude.every(e => !path.includes(e))
  })

  const untestedFiles = sourcePaths.filter(path => !logicalTestPaths.includes(path))
  if (untestedFiles.length > 0) {
    warn('Please add tests for these files: ' + linkableFiles(untestedFiles))
  }
}

// Checks code coverage
function teacherCoverage () {
  const master = require('../../rn/Teacher/coverage/coverage-summary-master.json')
  const pr = require('../../rn/Teacher/coverage/coverage-summary.json')
  checkCoverage('React Native', convertCoverage(master), convertCoverage(pr))
}

// Convert to `xcrun xccov view --json` format
function convertCoverage (jest) {
  const xccov = {}
  for (const key of Object.keys(jest)) {
    xccov[key] = {
      executableLines: jest[key].lines.total,
      coveredLines: jest[key].lines.covered,
    }
  }
  return xccov
}

annotations()
untestedFiles()
teacherCoverage()
