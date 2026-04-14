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

const program = require('commander')
const { spawn } = require('child_process')
const path = require('path')
const { createReadStream, readFileSync, writeFileSync } = require('fs')
const S3 = require('aws-sdk/clients/s3')
const localizables = require('./localizables.json')

program
  .version(require('../../package.json').version)
  .option('-s, --skipPush', 'Skip pushing to S3')
  .option('-v, --verbose', 'Print all outputs to console')

program.on('--help', () => {
  console.log(`
  Environment Variables:

    AWS_ACCESS_KEY_ID      AWS key, required to sync to instructure-translations S3 bucket
    AWS_SECRET_ACCESS_KEY  AWS secret, required to sync to instructure-translations S3 bucket
  \n`)
})
program.parse(process.argv)

if (
  !program.skipPush &&
  (!process.env.AWS_ACCESS_KEY_ID || !process.env.AWS_SECRET_ACCESS_KEY)
) {
  program.outputHelp()
  process.exit(1)
}

exportTranslations().catch(err => {
  console.error('Export translations failed: ', err)
  process.exit(2)
})

function run(cmd, args, opts) {
  return new Promise((resolve, reject) => {
    const command = spawn(cmd, args, opts)
    // If we don't read these xcodebuild just hangs
    command.stdout.on('data', (data) => {
      if (program.verbose) {
	    console.log(`${data}`)
      }
	})
    command.stderr.on('data', (data) => {
      if (program.verbose) {
	    console.log(`${data}`)
      }
	})
    command.on('error', reject)
    command.on('exit', code => {
      if (code === 0) return resolve()
      reject(`${cmd} failed with code ${code}.`)
    })
  })
}

async function exportTranslations() {
  const toUpload = []
  await processNativeLocalizations(toUpload)
  await pushToS3(toUpload)
  console.log('Finished!')
}

async function processNativeLocalizations(toUpload) {
  const outputPath = 'scripts/translations/source/all/'
  const projects = [
    'Student/Student.xcodeproj',
    'Teacher/Teacher.xcodeproj',
    'Parent/Parent.xcodeproj',
  ]

  const xliffContents = []
  for (const project of projects) {
    const projectOutputPath = `${outputPath}${path.basename(project, '.xcodeproj')}/`
    await exportLocalizations(project, projectOutputPath)
    const xliffFile = `${projectOutputPath}en.xcloc/Localized Contents/en.xliff`
    xliffContents.push({
      xml: readFileSync(xliffFile, 'utf8'),
      projectDir: path.dirname(project),
    })
  }

  const mergedXml = mergeXliffs(xliffContents)
  let xml = removeNonLocalizedFiles(mergedXml)
  xml = removeNonLocalizedKeys(xml)

  const outputFile = `${outputPath}en.xcloc/Localized Contents/en.xliff`
  const outputDir = path.dirname(outputFile)
  require('fs').mkdirSync(outputDir, { recursive: true })
  writeFileSync(outputFile, xml, 'utf8')
  toUpload.push({ from: outputFile, to: `all.xliff` })
}

async function pushToS3(toUpload) {
  if (program.skipPush) {
    console.log(`Skipping S3 push of these entries:`)
    for (const entry of toUpload) {
	  console.log(`${entry.from} -> ${entry.to}`)
    }
    return
  }
  
  const Bucket = 'instructure-translations'
  const s3 = new S3({ region: 'us-east-1' })
  await Promise.all(toUpload.map(({ from, to }) => {
    console.log(`Uploading ${from} to s3://instructure-translations/sources/canvas-ios/en/${to}`)
    return s3.putObject({ Bucket, Key: `sources/canvas-ios/en/${to}`, Body: createReadStream(from) })
      .promise()
  }))
}

async function exportLocalizations(project, outputPath) {
  await run('xcodebuild', [
    '-exportLocalizations',
    '-project',
    project,
    '-localizationPath',
    outputPath,
    'SDKROOT=iphonesimulator',
  ])
}

function mergeXliffs(xliffContents) {
  // Use the first xliff as the base, extract <file> elements from all others
  const filePattern = new RegExp(`<file\\s+original="([^"]+)"[^>]*>[\\s\\S]*?<\\/file>`, 'g')

  const seenOriginals = new Set()
  const allFiles = []

  for (const { xml, projectDir } of xliffContents) {
    let match
    while ((match = filePattern.exec(xml)) !== null) {
      const rawOriginal = match[1]
      // Normalize path: resolve relative to project dir, then make relative to repo root
      const normalized = path.normalize(path.join(projectDir, rawOriginal))
      if (!seenOriginals.has(normalized)) {
        seenOriginals.add(normalized)
        // Replace the original attribute with the normalized path
        const normalizedFile = match[0].replace(
          `original="${rawOriginal}"`,
          `original="${normalized}"`
        )
        allFiles.push(normalizedFile)
      }
    }
  }

  // Build a valid xliff document from the first content's header
  const firstXml = xliffContents[0].xml
  const headerMatch = firstXml.match(/^[\s\S]*?(?=<file\s)/)
  const header = headerMatch ? headerMatch[0] : '<?xml version="1.0" encoding="UTF-8"?>\n<xliff xmlns="urn:oasis:names:tc:xliff:document:1.2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="1.2" xsi:schemaLocation="urn:oasis:names:tc:xliff:document:1.2 http://docs.oasis-open.org/xliff/v1.2/os/xliff-core-1.2-strict.xsd">\n'
  const footer = '\n</xliff>\n'

  return header + allFiles.join('\n') + footer
}

function removeNonLocalizedFiles(xml) {
  // Matches file tags with original attribute
  const pattern = new RegExp(`<file\\s+original="([^"]+)"[^>]*>[\\s\\S]*?<\\/file>`, 'g')

  // Replace non-matching files with an empty string
  let result = xml.replace(pattern, (match, p1) => {
    return localizables.includes(p1) ? match : ''
  })
  
  // Remove empty lines
  result = result.replace(/^(?:[\t ]*(?:\r?\n|\r))+/gm, '');

  return result
}

function removeNonLocalizedKeys(xml) {
  const keysToSkip = ['CFBundleName']
  let result = xml
  keysToSkip.forEach((key) => {
    const regex = new RegExp(`<trans-unit id=\"${key}\"[\\\s\\\S]*?<\/trans-unit>\\s`, 'g')
    result = result.replace(regex, '')
  })
  return result
}
