#!/usr/bin/env node
/*
Runs code coverage report for `scheme`.

Depends on node & yarn dependencies, & awcli
 $ brew install yarn awscli
 $ yarn

Run this script from root with yarn
 $ yarn coverage --scheme Core

Run with --test option to run tests first
 $ yarn coverage --scheme Core --test
*/
const program = require('commander')
const { execSync } = require('child_process')
const { existsSync, readFileSync, writeFileSync } = require('fs')
const hljs = require('highlight.js')
const { basename, dirname, extname, join, relative, resolve } = require('path')

const config = require("./config.json")
const ignoreExps = config.ignorePatterns.map(pattern => new RegExp(pattern))

program
  .version(require('../../package.json').version)
  .option('--device [name]', 'Run XCTest on [name]', 'iPhone 8')
  .option('--html', 'Deprecated, html reports are always generated')
  .option('--os [name]', 'Run XCTest on [name]', '12.1')
  .option('--scheme [name]', 'Report coverage for scheme [name]')
  .option('--test', 'Run XCTest for scheme before generating reports')
  .parse(process.argv)

const { device, os, scheme, test } = program
if (!scheme) {
  program.outputHelp()
  process.exit(-1)
}

const coverageFolder = `scripts/coverage/${scheme.toLowerCase()}`

try {
  runTests()
  reportCoverage()
  syncCoverage()
} catch (err) {
  console.error('Coverage reporting failed: ', err)
  process.exit(-2)
}

function runTests() {
  if (!test || !device || !os) { return }
  run(
    `xcodebuild test -scheme ${scheme} -workspace Canvas.xcworkspace \
    -sdk iphonesimulator \
    -destination 'platform=iOS Simulator,name=${device},OS=${os}'`,
    { stdio: 'inherit' }
  )
}

function reportCoverage () {
  console.log('Finding Xcode coverage report')
  let folder = `scripts/coverage/${scheme.toLowerCase()}.xcresult`
  if (!existsSync(folder)) {
    const settings = run(`xcrun xcodebuild -showBuildSettings -workspace AllTheThings.xcworkspace -scheme ${scheme}`)
    folder = join(settings.match(/BUILD_DIR = (.*)/)[1], '../../Logs/Test/*.xcresult')
  }

  console.log('Reading Xcode coverage report')
  const report = JSON.parse(run(`xcrun xccov view --json ${folder}/*Test/*.xccovreport`))

  console.log('Generating html report')
  const cssPath = resolve(`${coverageFolder}/hljs.css`)
  run(`rm -rf "${coverageFolder}"`)
  run(`mkdir -p "${coverageFolder}"`)
  run(`cp node_modules/highlight.js/styles/xcode.css "${cssPath}"`)
  run(`cat scripts/coverage/coverage.css >> "${cssPath}"`)
  let coveredLines = 0
  let executableLines = 0
  const summary = {}
  const folders = {}
  for (const target of report.targets) {
    for (const file of target.files) {
      if (ignoreExps.some(exp => exp.test(file.path))) { continue }
      coveredLines += file.coveredLines
      executableLines += file.executableLines
      summary[relative(process.cwd(), file.path)] = {
        executableLines: file.executableLines,
        coveredLines: file.coveredLines,
      }
      writeFileHTML(file, cssPath)
      updateFolders(folders, file)
    }
  }

  for (const path of Object.keys(folders)) {
    writeFolderHTML(folders[path], cssPath)
  }

  console.log('Generating coverage-summary')
  summary.total = { executableLines, coveredLines }
  writeFileSync(`${coverageFolder}/coverage-summary.json`, JSON.stringify(summary))
}

function run (cmd, opts) {
  return execSync(cmd, opts || { encoding: 'utf8' })
}

function writeFileHTML (file, cssPath) {
  const relPath = relative(process.cwd(), file.path)
  const ext = extname(file.path).replace('.', '')
  const htmlPath = resolve(`${coverageFolder}/${relPath}.html`)
  run(`mkdir -p "${dirname(htmlPath)}"`)

  const source = hljs.highlight(ext, readFileSync(file.path, 'utf8')).value
  writeFileSync(htmlPath, `<!doctype html>
    <link rel="stylesheet" href="${relative(dirname(htmlPath), cssPath)}" />
    <h1>${header(relPath)}</h1>
    <h2>${(file.coveredLines / file.executableLines * 100).toFixed(2)}%
      (${file.coveredLines}/${file.executableLines}) Lines Covered</h2>
    <div class="source">
      <div class="coverage">${lineCoverage(file.functions)}</div>
      <pre class="numbers">${lineNumbers(source.split('\n').length)}</pre>
      <pre class="code"><code class="hljs ${ext}">${source}</code></pre>
    </div>
  `)
}

function header (path, offset = 1) {
  if (!path) return `${scheme} Scheme`
  const parts = path.split('/')
  const root = `<a href="${'../'.repeat(parts.length - offset)}index.html">${scheme} Scheme</a> `
  return root + parts.map((part, i, a) => {
    if (i === a.length - 1) return part
    return `<a href="${'../'.repeat(a.length - i - offset)}${part}/index.html">${part}/</a>`
  }).join('')
}

function lineNumbers (count) {
  let str = ""
  for (let i = 1; i < count; ++i) {
    str += i + '\n'
  }
  return str
}

function lineCoverage (blocks) {
  let value = ""
  for (const block of blocks) {
    const cls = block.executionCount ? "covered" : "notcovered"
    value += `<div class="covblock">
      <pre>${"\n".repeat(block.lineNumber)}</pre>
      <div class="${cls}">
        <pre>${block.executionCount}${"\n".repeat(block.executableLines)}</pre>
      </div>
    </div>`
  }
  return value
}

function updateFolders (folders, file) {
  const relPath = relative(process.cwd(), file.path)
  let parts = relPath.split('/')
  parts.pop()
  const path = parts.join('/')
  const folder = folders[path] || (folders[path] = {
    get coveredLines() {
      return Array.from(this.files)
        .map(f => f.coveredLines)
        .reduce((a, b) => a + b)
    },
    get executableLines() {
      return Array.from(this.files)
        .map(f => f.executableLines)
        .reduce((a, b) => a + b)
    },
    files: new Set(),
    path: path
  })
  folder.files.add(file)
  if (parts.length) {
    updateFolders(folders, folder)
  }
}

async function writeFolderHTML (folder, cssPath) {
  const htmlPath = resolve(`${coverageFolder}/${folder.path || '.'}/index.html`)
  run(`mkdir -p "${dirname(htmlPath)}"`)
  writeFileSync(htmlPath, `<!doctype html>
    <h1>${header(folder.path, 0)}</h1>
    <h2>${(folder.coveredLines / folder.executableLines * 100).toFixed(2)}%
      (${folder.coveredLines}/${folder.executableLines}) Lines Covered</h2>
    <table>
      <thead>
        <tr>
          <th>File</th>
          <th>Line %</th>
          <th>Lines</th>
        </tr>
      </thead>
      <tbody>
      ${Array.from(folder.files).map(file => {
        const name = basename(file.path)
        const path = name.includes('.') ? `${name}.html` : `${name}/index.html`
        return `<tr>
          <td><a href="./${path}">${name}</a></td>
          <td>${(file.coveredLines / file.executableLines * 100).toFixed(2)}%</td>
          <td>${file.coveredLines}/${file.executableLines}</td>
        </tr>`
      }).join('')}
      </tbody>
    </table>
  `)
}

function syncCoverage () {
  if (!process.env.AWS_ACCESS_KEY_ID || !process.env.AWS_SECRET_ACCESS_KEY) {
    console.log('Missing AWS environment variables, skipping coverage sync')
    return
  }
  const s3folder = scheme.toLowerCase()
  if (process.env.BITRISEIO_GIT_BRANCH_DEST) { // This is a PR, pull master coverage
    console.log('Pulling master coverage summary from s3')
    run(`aws s3 cp "s3://inseng-code-coverage/ios/coverage/${s3folder}/coverage-summary.json" "${coverageFolder}/coverage-summary-master.json"`)
  } else { // This is a master run, push to s3
    console.log('Pushing all coverage files to s3')
    run(`aws s3 sync "${coverageFolder}" "s3://inseng-code-coverage/ios/coverage/${s3folder}"`)
  }
}
