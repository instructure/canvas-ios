#!/usr/bin/env node
//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

/*
Runs code coverage report.

Depends on node & yarn dependencies, & awcli
 $ brew install yarn awscli
 $ yarn

Run this script from root with yarn
 $ yarn coverage

Run with --test option to run tests first
 $ yarn coverage --test
*/
const program = require('commander')
const { execSync } = require('child_process')
const { existsSync, readFileSync, writeFileSync } = require('fs')
const hljs = require('highlight.js')
const { basename, dirname, extname, join, relative, resolve } = require('path')
const d3 = require('d3')
const jsdom = require('jsdom').JSDOM

const config = require("./config.json")
const ignoreExps = config.ignorePatterns.map(pattern => new RegExp(pattern))
const ignoreContent = config.ignoreContent

program
  .version(require('../../package.json').version)
  .option('--device [name]', 'Run XCTest on [name]', 'iPhone SE (2nd generation)')
  .option('--html', 'Deprecated, html reports are always generated')
  .option('--os [name]', 'Run XCTest on [name]', '14.0')
  .option('--scheme [name]', 'Report coverage for scheme [name]', 'CITests')
  .option('--test', 'Run XCTest for scheme before generating reports')
  .option('--skip-sync', "Don't upload/download to S3")
  .parse(process.argv)

const { device, os, scheme, test, skipSync } = program
if (!scheme) {
  program.outputHelp()
  process.exit(-1)
}

const coverageFolder = `scripts/coverage/${scheme.toLowerCase()}`
const resultBundlePath = `scripts/coverage/${scheme.toLowerCase()}.xcresult`
const naturalCompare = new Intl.Collator('en', {
  sensitivity: 'base', numeric: true,
}).compare

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
  run(`rm -rf ${resultBundlePath}`)
  run(
    `xcodebuild test -scheme ${scheme} -workspace Canvas.xcworkspace \
    -sdk iphonesimulator \
    -destination 'platform=iOS Simulator,name=${device},OS=${os}' \
    -resultBundlePath ${resultBundlePath}`,
    { stdio: 'inherit' }
  )
}

function reportCoverage () {
  console.log('Finding Xcode coverage report')
  let folder = resultBundlePath
  if (!existsSync(folder)) {
    const settings = run(`xcrun xcodebuild -showBuildSettings -workspace Canvas.xcworkspace -scheme ${scheme}`)
    folder = join(settings.match(/BUILD_DIR = (.*)/)[1], '../../Logs/Test/*.xcresult')
  }

  console.log(`Reading Xcode coverage report ${folder}`)
  run(`xcrun xccov view --report --json ${folder} > scripts/coverage/tmp.json`)
  const report = JSON.parse(readFileSync('scripts/coverage/tmp.json'))

  console.log('Generating html report')
  const cssPath = resolve(`${coverageFolder}/hljs.css`)
  run(`rm -rf "${coverageFolder}"`)
  run(`cp node_modules/highlight.js/styles/xcode.css "${cssPath}"`)
  run(`cat scripts/coverage/coverage.css >> "${cssPath}"`)
  let coveredLines = 0
  let executableLines = 0
  const summary = {}
  const folders = {}
  for (const target of report.targets) {
    for (const file of target.files) {
      const content = readFileSync(file.path, 'utf8')
      if (!ignoreExps.some(exp => exp.test(file.path)) && !ignoreContent.some(needle => content.includes(needle))) {
        coveredLines += file.coveredLines
        executableLines += file.executableLines
        summary[relative(process.cwd(), file.path)] = {
          executableLines: file.executableLines,
          coveredLines: file.coveredLines,
        }
      }
      writeFileHTML(file, content, cssPath)
      updateFolders(folders, file)
    }
  }

  for (const path of Object.keys(folders)) {
    writeFolderHTML(folders[path], cssPath)
  }

  console.log('Generating coverage-summary')
  summary.total = { executableLines, coveredLines }
  writeFileSync(`${coverageFolder}/coverage-summary.json`, JSON.stringify(summary))
  writeFileSync(`${coverageFolder}/coverage-final.json`, JSON.stringify(report))
}

function run (cmd, opts) {
  return execSync(cmd, opts || { encoding: 'utf8' })
}

function writeFileHTML (file, content, cssPath) {
  const relPath = relative(process.cwd(), file.path)
  const ext = extname(file.path).replace('.', '')
  const htmlPath = resolve(`${coverageFolder}/${relPath}.html`)
  run(`mkdir -p "${dirname(htmlPath)}"`)

  const source = hljs.highlight(ext, content).value
  writeFileSync(htmlPath, `<!doctype html>
    <link rel="stylesheet" href="${relative(dirname(htmlPath), cssPath)}" />
    <h1>${header(relPath)}</h1>
    <h2>${percent(file)}%
      (${file.coveredLines}/${file.executableLines}) Lines Covered</h2>
    <div class="source">
      <div class="coverage">${lineCoverage(file.functions)}</div>
      <pre class="numbers">${lineNumbers(source.split('\n').length)}</pre>
      <pre class="code"><code class="hljs ${ext}">${source}</code></pre>
    </div>
  `)
}

function percent(file) {
  if (!file.executableLines) { return (100).toFixed(2) }
  return (file.coveredLines / file.executableLines * 100).toFixed(2)
}

function header (path, offset = 1) {
  if (!path) return 'Code Coverage canvas-ios'
  const parts = path.split('/')
  const root = `Code Coverage <a href="${'../'.repeat(parts.length - offset)}index.html">canvas-ios</a>/`
  return root + parts.map((part, i, a) => {
    if (i === a.length - 1) return part
    return `<a href="${'../'.repeat(a.length - i - offset)}${part}/index.html">${part}</a>`
  }).join('/')
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
  const name = parts.pop()
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
    get hasOwnFiles() {
      return Array.from(this.files).some(file => !file.files)
    },
    files: new Set(),
    path: path,
    name
  })
  folder.files.add(file)
  if (parts.length) {
    updateFolders(folders, folder)
  }
}

// based on https://observablehq.com/@d3/zoomable-sunburst
function makeSunburst(folder) {
  const width = 600
  const height = width + 40
  const layers = 3
  const radius = width / (2 * layers + 1)

  const hierarchy = d3.hierarchy(folder, d => Array.from(d.files || []))
        .sum(d => d.files ? d.value : d.executableLines)
        .sort((a, b) => b.value - a.value)
  const root = d3.partition().size([2 * Math.PI, hierarchy.height + 1])(hierarchy)

  const arc = d3.arc()
    .startAngle(d => d.x0)
    .endAngle(d => d.x1)
    .padAngle(d => Math.min((d.x1 - d.x0) / 2, 0.005))
    .padRadius(radius * 1.5)
    .innerRadius(d => (d.y0 - 0.5) * radius)
    .outerRadius(d => Math.max((d.y0 - 0.5) * radius, (d.y1 - 0.5) * radius - 1))

  const color = d3.interpolateHsl("red", "green")

  const path = file => {
    const name = relative(folder.path, file.path)
    let link, display
    if (name === "") {
      link = file.path ? "../index.html" : null
      display = ""
    } else {
      link = file.files ? `${name}/index.html` : `${name}.html`
      display = `${name}` + (file.files ? "/" : "")
    }
    return { link, display }
  }

  const visible = root.descendants().filter(d => d.depth <= layers)

  const svg = d3.select(new jsdom().window.document.body).append('svg');

  const g = svg.append("g")
    .selectAll("path")
    .data(visible)
    .join("g")

  g.append("a")
    .attr("href", d => path(d.data).link)
    .attr("class", "tooltip")
    .append("path")
    .attr("fill-opacity", 0.8)
    .attr("fill", d => color(percent(d.data) / 100))
    .attr("d", arc)

  g.append("g")
    .attr("class", "hide")
    .append("text")
    .attr("y", width / 2 + 15)
    .attr("text-anchor", "middle")
    .text(d => path(d.data).display)
    .clone()
    .attr("dy", 20)
    .text(d => `${percent(d.data)}% (${d.data.coveredLines}/${d.data.executableLines})`)

  return svg
    .attr("viewBox", [-width / 2, -width / 2, width, height])
    .attr("width", width)
    .attr("height", height)
    .node()
    .outerHTML
}

async function writeFolderHTML (folder, cssPath) {
  const htmlPath = resolve(`${coverageFolder}/${folder.path || '.'}/index.html`)
  run(`mkdir -p "${dirname(htmlPath)}"`)
  let files = []
  const flatFiles = (set, depth) => {
    for (const file of set) {
      if (file.hasOwnFiles || (!depth && !file.files)) {
        files.push(file)
      }
      if (file.files) {
        flatFiles(file.files, depth + 1)
      }
    }
  }
  flatFiles(folder.files, 0)
  files.sort((a, b) => naturalCompare(a.path, b.path))
  writeFileSync(htmlPath, `<!doctype html>
    <link rel="stylesheet" href="${relative(dirname(htmlPath), cssPath)}" />
    <h1>${header(folder.path, 0)}</h1>
    <h2>${percent(folder)}%
      (${folder.coveredLines}/${folder.executableLines}) Lines Covered</h2>
    ${makeSunburst(folder)}
    <table style="text-align:right">
      <thead>
        <tr>
          <th style="text-align:left">File</th>
          <th>Line %</th>
          <th>Lines</th>
        </tr>
      </thead>
      <tbody>
      ${files.map(file => {
        const name = relative(folder.path, file.path)
        const path = file.files ? `${name}/index.html` : `${name}.html`
        return `<tr>
          <td style="text-align:left"><a href="./${path}">${name}</a></td>
          <td>${percent(file)}%</td>
          <td>${file.coveredLines}/${file.executableLines}</td>
        </tr>`
      }).join('')}
      </tbody>
    </table>
  `)
}

function syncCoverage () {
  if (skipSync) { return }
  if (!process.env.AWS_ACCESS_KEY_ID || !process.env.AWS_SECRET_ACCESS_KEY) {
    console.log('Missing AWS environment variables, skipping coverage sync')
    return
  }
  const s3folder = scheme.toLowerCase()
  if (process.env.BITRISE_GIT_BRANCH == "master") { // This is a master run, push to s3
    console.log('Pushing all coverage files to s3')
    run(`aws s3 sync "${coverageFolder}" "s3://inseng-code-coverage/ios/coverage/${s3folder}"`)
  } else { // This is a PR (or manual trigger), pull master coverage
    console.log('Pulling master coverage summary from s3')
    try {
      run(`aws s3 cp "s3://inseng-code-coverage/ios/coverage/${s3folder}/coverage-summary.json" "${coverageFolder}/coverage-summary-master.json"`)
    } catch (err) {
      writeFileSync(`${coverageFolder}/coverage-summary-master.json`, JSON.stringify({
        total: { executableLines: 0, coveredLines: 0 },
      }))
      console.log('Failed to pull prior code coverage. Creating empty coverage for master.')
    }
  }
}
