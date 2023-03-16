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

const content = window.content = document.querySelector('#content')
const editor = window.editor = {
    isDragging: false,
    currentSelection: null,
    currentEditingImage: null,
    currentEditingLink: null,
    enabledItems: {},
    featureFlags: [],

    backupRange () {
        const selection = getSelection()
        const range = selection.rangeCount > 0 ? selection.getRangeAt(0) : document.createRange()
        editor.currentSelection = {
            startContainer: range.startContainer,
            startOffset: range.startOffset,
            endContainer: range.endContainer,
            endOffset: range.endOffset,
        }
    },

    restoreRange () {
        const selection = getSelection()
        selection.removeAllRanges()
        const range = document.createRange()
        range.setStart(editor.currentSelection.startContainer, editor.currentSelection.startOffset)
        range.setEnd(editor.currentSelection.endContainer, editor.currentSelection.endOffset)
        selection.addRange(range)
    },

    getSelectedNode () {
        const selection = getSelection()
        let node = selection.focusNode
        return node && (node.nodeName == '#text' ? node.parentNode : node)
    },

    execCommand (command, value = null) {
        document.execCommand('styleWithCSS', false, 'foreColor' === command)
        document.execCommand(command, false, value)
        editor.postState()
    },

    updateLink (href, text) {
        editor.restoreRange()
        if (editor.currentEditingLink) {
            editor.currentEditingLink.href = href
            editor.currentEditingLink.textContent = text
        } else if (getSelection().toString() == text) {
            document.execCommand('createLink', false, href)
        } else {
            document.execCommand('insertHTML', false, `<a href="${escapeHTML(href)}">${escapeHTML(text)}</a>`)
        }
        editor.postState()
        content.focus()
    },

    updateImage (src, alt) {
        editor.restoreRange()
        if (editor.currentEditingImage) {
            editor.currentEditingImage.src = src
            editor.currentEditingImage.alt = alt
            editor.postState()
        } else {
            editor.insertHTML(`<img src="${escapeHTML(src)}" alt="${escapeHTML(alt)}" />`)
        }
    },

    insertImagePlaceholder (url, placeholder) {
        editor.restoreRange()
        editor.insertHTML(`<img src="${escapeHTML(placeholder)}" alt="" data-uploading="${escapeHTML(url)}" />`)
    },

    insertVideoPlaceholder (url) {
        editor.restoreRange()
        editor.insertHTML(`<img src='${videoUploadURL}' alt="" data-uploading="${escapeHTML(url)}" data-media_comment_id />`)
    },

    updateUploadProgress (files) {
        for (const file of files) {
            const img = document.querySelector(`[data-uploading="${file.localFileURL}"]`)
            if (!img) continue
            const overlay = img.overlay || (img.overlay = imgOverlay(img))
            if (file.uploadError) {
                overlay.progressSVG.classList.add('is-hidden')
                overlay.removeButton.classList.remove('is-hidden')
                overlay.uploadErrorTitle.textContent = file.uploadErrorTitle
                overlay.uploadErrorMessage.textContent = file.uploadError
                overlay.uploadError.classList.remove('is-hidden')
            } else if (file.mediaEntryID) {
                img.src = videoPreviewURL
                img.dataset.media_comment_id = file.mediaEntryID
                delete img.dataset.uploading
                overlay.progressSVG.classList.add('is-hidden')
                overlay.removeButton.classList.remove('is-hidden')
                overlay.uploadError.classList.add('is-hidden')
            } else if (file.url) {
                img.src = file.url
                delete img.dataset.uploading
                overlay.progressSVG.classList.add('is-hidden')
                overlay.removeButton.classList.remove('is-hidden')
                overlay.uploadError.classList.add('is-hidden')
            } else {
                overlay.progressSVG.classList.remove('is-hidden')
                overlay.removeButton.classList.add('is-hidden')
                overlay.uploadError.classList.add('is-hidden')
                const fill = overlay.querySelector('.progress-fill')
                const circum = 2 * fill.r.baseVal.value * Math.PI
                fill.style.strokeDashoffset = 1000 - (((file.bytesSent / file.size) || 0) * circum)
            }
        }
        editor.updateOverlays()
        editor.postState()
    },

    updateOverlays () {
        for (const overlay of document.querySelectorAll('.image-overlay')) {
            if (!overlay.image.parentNode) { overlay.remove() }
        }
        for (const img of content.querySelectorAll('img')) {
            if (img.complete) {
                const bounds = img.getBoundingClientRect()
                const overlay = img.overlay || (img.overlay = imgOverlay(img))
                overlay.style.height = `${bounds.height}px`
                overlay.style.left = `${scrollX + bounds.left}px`
                overlay.style.top = `${scrollY + bounds.top}px`
                overlay.style.width = `${bounds.width}px`
                if (!overlay.parentNode) { document.body.appendChild(overlay) }
            }
        }
    },

    setHTML (html) {
        content.innerHTML = html
        for (let video of document.querySelectorAll('video')) {
            let mediaID = video.dataset.media_comment_id
            video.outerHTML = `<img src='${videoPreviewURL}' alt="" data-media_comment_id="${mediaID}" />`
        }

        for (let mediaEmbed of document.querySelectorAll('div[id^="media_object_"]')) {
            let mediaID = mediaEmbed.id.replace('media_object_', '')
            mediaEmbed.outerHTML = `<img src='${videoPreviewURL}' alt="" data-media_comment_id="${mediaID}" />`
        }
    },

    insertHTML (html) {
        document.execCommand('insertHTML', false, html)
        editor.postState()
    },

    getHTML () {
        // Get the contents
        const clone = content.cloneNode(true)
        for (let styled of clone.querySelectorAll('[style]')) {
            // Replace rgb with hex because Canvas will remove rgb styles
            styled.setAttribute('style', rgbToHex(styled.style.cssText))
        }
        for (let remove of clone.querySelectorAll('[data-uploading]')) {
            remove.remove() // There shouldn't be any, but just in case.
        }
        for (let img of clone.querySelectorAll('[data-media_comment_id]')) {
            let mediaID = img.dataset.media_comment_id
            if (editor.featureFlags.includes('rce_enhancements')) {
                img.outerHTML = `<div id="media_object_${mediaID}" style="width: 768px; height: 432px;"><iframe src="/media_objects_iframe/${mediaID}" width="100%" height="100%"></iframe></div>`
            } else {
                img.outerHTML = `<a id="media_comment_${mediaID}" class="instructure_inline_media_comment video_comment" href="/media_objects/${mediaID}">this is a media comment</a>`
            }
        }
        let html = clone.innerHTML
        // backspaces can leave behind empty line breaks
        if (['<br>', '<div><br></div>'].includes(html)) {
            html = ''
        }
        return html
    },

    postState: throttle((e) => {
        const node = (e && e.target) || editor.getSelectedNode()

        let foreColor = document.queryCommandValue('foreColor') || (node && getComputedStyle(node).color)
        foreColor = rgbToHex(foreColor || '') || null

        let linkHref, linkText, imageSrc, imageAlt
        if (node) {
            let a = node.closest && node.closest('a')
            if (a) {
                editor.currentEditingLink = a
                linkHref = a.href
                linkText = a.textContent
            } else {
                linkText = getSelection().toString()
                editor.currentEditingLink = null
            }

            if (node instanceof HTMLImageElement) {
                editor.currentEditingImage = node
                imageSrc = node.src
                imageAlt = node.alt
            } else {
                editor.currentEditingImage = null
            }
        }

        const hasImages = content.querySelector('img') != null
        const text = content.textContent
        const showPlaceholder = !hasImages && !text
        content.classList.toggle('show-placeholder', showPlaceholder)

        webkit.messageHandlers.state.postMessage({
            undo: document.queryCommandEnabled('undo'),
            redo: document.queryCommandEnabled('redo'),
            bold: document.queryCommandState('bold'),
            italic: document.queryCommandState('italic'),
            orderedList: document.queryCommandState('insertOrderedList'),
            unorderedList: document.queryCommandState('insertUnorderedList'),
            isUploading: content.querySelector('[data-uploading]') != null,
            isEmpty: !hasImages && !text.trim(),
            foreColor, linkHref, linkText, imageSrc, imageAlt,
            selection: editor.getSelectionBoundingRect(),
        })
    }),

    focus () {
        let range = document.createRange()
        range.selectNodeContents(content)
        range.collapse(false) // move to end
        let selection = getSelection()
        selection.removeAllRanges()
        selection.addRange(range)
        content.focus()
    },

    getSelectionBoundingRect () {
        const selection = getSelection()
        if (selection.rangeCount <= 0) return
        let { x, y, width, height } = selection.getRangeAt(0).getBoundingClientRect()
        if (x === 0 && y === 0 && width === 0 && height === 0) {
            const span = document.createElement('span')
            const range = selection.getRangeAt(0).cloneRange()
            range.collapse(false)
            range.insertNode(span)
            ;({ x, y, width, height } = span.getBoundingClientRect())
            span.remove()
        }
        return { x: x + scrollX, y: y + scrollY, width, height }
    },

    get contentHeight () { return content.scrollHeight }
}

const rgbToHex = (rgb) => {
    return rgb.replace(/\brgba?\s*\(\s*(\d+)\D+(\d+)\D+(\d+)\D*(\d+)?\D*\)/g, (s, r, g, b, a) => {
        return '#' + [a || 255, r, g, b]
            .map(n => (+n).toString(16).padStart(2, '0'))
            .join('')
            .replace(/^ff/i, '')
    })
}

const escapeHTML = (html) => {
    return html
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/'/g, '&#039;')
        .replace(/"/g, '&quot;')
}

const imgOverlay = img => {
    const overlay = document.createElement('div')
    overlay.setAttribute('aria-hidden', '')
    overlay.className = 'image-overlay'
    overlay.innerHTML = `
        <button class="remove-image">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1920 1920" width="18" height="18">
                <path d="M771.55 960.11L319 1412.66l188.56 188.56 452.55-452.55 452.55 452.55 188.56-188.56-452.55-452.55 452.55-452.55L1412.66 319 960.1 771.55 507.56 319 319 507.56z"/>
            </svg>
        </button>
        <svg class="progress is-hidden" xmlns="http://www.w3.org/2000/svg">
            <circle class="progress-track" stroke-width="4" cx="22" cy="22" r="20"/>
            <circle class="progress-fill" stroke-width="4" cx="22" cy="22" r="20"/>
        </svg>
        <div class="upload-error is-hidden">
            <svg class="upload-error-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1920 1920" width="20" height="20">
                <path d="M960 1920C429.8 1920 0 1490.2 0 960S429.8 0 960 0s960 429.8 960 960-429.8 960-960 960zm-9.84-577.32c-84.47 0-153.19 68.73-153.19 153.2 0 84.46 68.72 153.19 153.2 153.19s153.18-68.72 153.18-153.2-68.72-153.18-153.19-153.18zM1153.66 320h-407l99.13 898.62h208.75L1153.66 320z"/>
            </svg>
            <div class="upload-error-text">
                <div class="upload-error-title"></div>
                <div class="upload-error-message"></div>
            </div>
            <button class="retry-upload">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1920 1920" width="20" height="20">
                    <path d="M960 0v112.94c467.13 0 847.06 379.94 847.06 847.06 0 467.13-379.94 847.06-847.06 847.06-467.13 0-847.06-379.94-847.06-847.06 0-267.1 126.6-515.91 338.83-675.73v393.38H564.7v-564.7H0v112.93h342.89C127.06 407.38 0 674.71 0 960c0 529.36 430.64 960 960 960s960-430.64 960-960S1489.36 0 960 0"/>
                </svg>
            </button>
        </div>
    `.replace(/>\s+</g, '><').trim()
    overlay.image = img
    overlay.progressSVG = overlay.querySelector('.progress')
    overlay.removeButton = overlay.querySelector('.remove-image')
    overlay.removeButton.onclick = () => {
        const range = document.createRange()
        range.selectNode(overlay.image)
        const selection = getSelection()
        selection.removeAllRanges()
        selection.addRange(range)
        editor.execCommand('delete')
    }
    overlay.retryButton = overlay.querySelector('.retry-upload')
    overlay.retryButton.onclick = () => {
        webkit.messageHandlers.retryUpload.postMessage(overlay.image.dataset.uploading)
    }
    overlay.uploadError = overlay.querySelector('.upload-error')
    overlay.uploadErrorTitle = overlay.querySelector('.upload-error-title')
    overlay.uploadErrorMessage = overlay.querySelector('.upload-error-message')
    return overlay
}

const videoUploadURL = `data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg"></svg>`
const videoPreviewURL = `data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 192 111">
  <circle fill="none" stroke="white" stroke-width="3" cx="96" cy="55" r="25"/>
  <path fill="white" d="M90 45 l18 11-18 11z"/>
</svg>`.replace(/\r?\n\s*/g, '')

function throttle (fn, ms = 200) {
  let timer, last
  return function () {
    const context = this, args = arguments
    const now = performance.now()
    if (now < last + ms) {
        clearTimeout(timer)
        timer = setTimeout(() => {
            last = now
            fn.apply(context, args)
        }, ms)
    } else {
        last = now
        fn.apply(context, args)
    }
  }
}

document.addEventListener('selectionchange', e => {
    editor.postState()
}, { passive: true })

new MutationObserver(() => {
    editor.updateOverlays()
}).observe(content, { attributes: true, characterData: true, childList: true, subtree: true })

window.addEventListener('touchstart', e => {
    editor.isDragging = false
}, { passive: true })
window.addEventListener('touchmove', e => {
    editor.isDragging = true
    editor.postState(e)
}, { passive: true })
window.addEventListener('touchend', e => {
    editor.postState(e)
    if (editor.currentEditingLink) {
        webkit.messageHandlers.link.postMessage('')
        e.preventDefault()
    }
    if (!editor.isDragging && e.target.nodeName.toLowerCase() === 'html') {
        editor.focus()
    }
})

content.addEventListener('paste', e => {
    if (e.clipboardData.files.length) {
        e.preventDefault() // don't allow default pasting of a blob url for the file
        const uris = e.clipboardData.getData('text/uri-list').split('\r\n')
        for (let i = 0; i < e.clipboardData.files.length; ++i) {
            const file = e.clipboardData.files[i]
            const uri = uris[i]
            if (file.type.startsWith('image/') && uri) {
                document.execCommand('insertHTML', false, `<img src="${escapeHTML(uri)}" alt="${escapeHTML(file.name)}" />`)
            } else if (uri) {
                document.execCommand('insertHTML', false, `<a href="${escapeHTML(uri)}">${escapeHTML(uri)}</a>`)
            }
        }
    }
    editor.postState(e)
})

webkit.messageHandlers.ready.postMessage('')
