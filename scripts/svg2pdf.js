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
Converts a SVG to a PDF file.

Depends on node
 brew install node

Run this script from the repo root directory
 yarn svg2pdf file.svg out.pdf 24x24
*/

const fs = require('fs')
const jsdom = require('jsdom').JSDOM
const PDFDocument = require('pdfkit')

if (require.main == module) {
  const [ , , svg, pdf, size, pad ] = process.argv
  convert(svg, pdf, size ? size.split(/\D+/).map(n => +n) : null, +pad || 0)
}

function convert(svgPath, pdfPath, size, pad = 0) {
  const svg = new jsdom(fs.readFileSync(svgPath, 'utf8')).window.document.querySelector('svg')
  const pdf = new PDFDocument({ autoFirstPage: false })
  pdf._id = Buffer.from([ 0 ]) // consistent, small id
  pdf.pipe(fs.createWriteStream(pdfPath))
  pdf.info = {} // remove metadata
  const viewBox = (
    svg.getAttribute('viewBox')
    || `0 0 ${+svg.getAttribute('width')} ${+svg.getAttribute('height')}`
  ).split(/\s+/).map(n => +n)
  pdf.addPage({ size: size || viewBox.slice(2).map(n => n + pad * 2) })
  if (pad) {
    pdf.translate(pad, pad)
  }
  if (size) {
    pdf.scale(Math.min((size[0] - pad * 2) / viewBox[2], (size[1] - pad * 2) / viewBox[3]))
  }
  for (const path of svg.querySelectorAll('path')) {
    pdf.path(path.getAttribute('d').trim())
    const opacity = parseFloat(path.getAttribute('opacity') || '1')
    if (opacity !== 1) {
      pdf.fillOpacity(opacity)
    }
    pdf.fill(path.getAttribute('fill-rule') || 'evenodd')
  }
  pdf.end()
}

module.exports = convert
