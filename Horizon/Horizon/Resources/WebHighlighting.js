//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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
 * ATTENTION: The "eval" devtool has been used (maybe by default in mode: "development").
 * This devtool is neither made for production nor for readable output files.
 * It uses "eval()" calls to create a separate source file in the browser devtools.
 * If you are trying to read the output file, select a different devtool (https://webpack.js.org/configuration/devtool/)
 * or disable the default devtool with "devtool: false".
 * If you are looking for production-ready output files, see mode: "production" (https://webpack.js.org/configuration/mode/).
 */
/******/ (() => { // webpackBootstrap
/******/ 	"use strict";
/******/ 	var __webpack_modules__ = ({

/***/ "./dist/main.js":
/*!**********************!*\
  !*** ./dist/main.js ***!
  \**********************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

eval("\n//\n// This file is part of Canvas.\n// Copyright (C) 2025-present  Instructure, Inc.\n//\n// This program is free software: you can redistribute it and/or modify\n// it under the terms of the GNU Affero General Public License as\n// published by the Free Software Foundation, either version 3 of the\n// License, or (at your option) any later version.\n//\n// This program is distributed in the hope that it will be useful,\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n// GNU Affero General Public License for more details.\n//\n// You should have received a copy of the GNU Affero General Public License\n// along with this program.  If not, see <https://www.gnu.org/licenses/>.\n//\nvar __importDefault = (this && this.__importDefault) || function (mod) {\n    return (mod && mod.__esModule) ? mod : { \"default\": mod };\n};\nObject.defineProperty(exports, \"__esModule\", ({ value: true }));\nconst ApplyHighlights_1 = __importDefault(__webpack_require__(/*! ./use_case/ApplyHighlights */ \"./dist/use_case/ApplyHighlights.js\"));\nconst GetCurrentTextSelection_1 = __importDefault(__webpack_require__(/*! ./use_case/GetCurrentTextSelection */ \"./dist/use_case/GetCurrentTextSelection.js\"));\nconst NotifyTextSelectionChange_1 = __importDefault(__webpack_require__(/*! ./use_case/NotifyTextSelectionChange */ \"./dist/use_case/NotifyTextSelectionChange.js\"));\n//This file is just an interface. No implementation details here!\nwindow.applyHighlights = ApplyHighlights_1.default;\nwindow.getCurrentTextSelection = GetCurrentTextSelection_1.default;\n(0, NotifyTextSelectionChange_1.default)();\n\n\n//# sourceURL=webpack:///./dist/main.js?");

/***/ }),

/***/ "./dist/use_case/ApplyHighlights.js":
/*!******************************************!*\
  !*** ./dist/use_case/ApplyHighlights.js ***!
  \******************************************/
/***/ ((__unused_webpack_module, exports, __webpack_require__) => {

eval("\nObject.defineProperty(exports, \"__esModule\", ({ value: true }));\nexports.buildHighlightStyle = exports.addHighlight = void 0;\nexports[\"default\"] = applyHighlights;\nconst RangeAnchor_1 = __webpack_require__(/*! ../util/RangeAnchor */ \"./dist/util/RangeAnchor.js\");\nfunction applyHighlights(highlights) {\n    clearHighlights();\n    highlights.forEach(exports.addHighlight);\n}\n// *********************** Private *********************** //\nconst highlightClassName = \"notebook-highlight\";\nconst addHighlight = (notebookTextSelection) => {\n    var _a;\n    let parent = document.getElementById(\"parent-container\");\n    if (!parent)\n        return;\n    let range = (_a = RangeAnchor_1.RangeAnchor.fromSelector(parent, notebookTextSelection.range)) === null || _a === void 0 ? void 0 : _a.toRange();\n    if (!range)\n        return;\n    const textNodeSpans = getHighlightRange(range);\n    for (const textNode of textNodeSpans) {\n        const parent = textNode.parentNode;\n        const highlightElement = createHighlightElement({\n            textContent: textNode.textContent,\n            notebookTextSelection,\n        });\n        if (!highlightElement)\n            return;\n        parent.replaceChild(highlightElement, textNode);\n    }\n};\nexports.addHighlight = addHighlight;\nfunction clearHighlights() {\n    const elements = document.getElementsByClassName(highlightClassName);\n    while (elements.length) {\n        const element = elements[0];\n        element.replaceWith(...element.childNodes);\n    }\n}\n// Find all of the text nodes in the range and group them into spans\nconst getHighlightRange = (range) => {\n    const textNodes = wholeTextNodesInRange(range);\n    const whitespace = /^\\s*$/;\n    // Filter out text nodes that consist only of whitespace\n    return textNodes.filter((node) => {\n        const parentElement = node.parentElement;\n        return (((parentElement === null || parentElement === void 0 ? void 0 : parentElement.childNodes.length) === 1 &&\n            (parentElement === null || parentElement === void 0 ? void 0 : parentElement.tagName) === \"SPAN\") ||\n            !whitespace.test(node.data));\n    });\n};\nconst wholeTextNodesInRange = (range) => {\n    var _a;\n    if (range.collapsed) {\n        return [];\n    }\n    let root = range.commonAncestorContainer;\n    if (root && root.nodeType !== Node.ELEMENT_NODE) {\n        root = root.parentElement;\n    }\n    if (!root) {\n        return [];\n    }\n    const textNodes = [];\n    const nodeIter = (_a = root === null || root === void 0 ? void 0 : root.ownerDocument) === null || _a === void 0 ? void 0 : _a.createNodeIterator(root, NodeFilter.SHOW_TEXT // Only return `Text` nodes.\n    );\n    let node = (nodeIter === null || nodeIter === void 0 ? void 0 : nodeIter.nextNode()) || null;\n    while (node) {\n        if (!isNodeInRange(range, node)) {\n            node = (nodeIter === null || nodeIter === void 0 ? void 0 : nodeIter.nextNode()) || null;\n            continue;\n        }\n        const text = node;\n        if (text === range.startContainer && range.startOffset > 0) {\n            text.splitText(range.startOffset);\n            node = (nodeIter === null || nodeIter === void 0 ? void 0 : nodeIter.nextNode()) || null;\n            continue;\n        }\n        if (text === range.endContainer && range.endOffset < text.data.length) {\n            text.splitText(range.endOffset);\n        }\n        textNodes.push(text);\n        node = (nodeIter === null || nodeIter === void 0 ? void 0 : nodeIter.nextNode()) || null;\n    }\n    return textNodes;\n};\nconst isNodeInRange = (range, node) => {\n    var _a, _b;\n    try {\n        const length = (_b = (_a = node.nodeValue) === null || _a === void 0 ? void 0 : _a.length) !== null && _b !== void 0 ? _b : node.childNodes.length;\n        return (range.comparePoint(node, 0) <= 0 && range.comparePoint(node, length) >= 0);\n    }\n    catch (_c) {\n        return false;\n    }\n};\n// Notify the native code that a highlight has been tapped\nconst notifyiOSOfHighlightTap = (notebookTextSelection) => {\n    var _a;\n    const messageHandlers = (_a = window.webkit) === null || _a === void 0 ? void 0 : _a.messageHandlers;\n    if (!messageHandlers)\n        return;\n    messageHandlers.notebookHighlightTap.postMessage(JSON.stringify(notebookTextSelection));\n};\n// Given our text to wrap and the notebookTextSelection object, wrap the text in a span with the appropriate styles\n// Applies an onclick handler to call when a highlight is tapped\nconst createHighlightElement = ({ textContent, notebookTextSelection, }) => {\n    if (!textContent)\n        return null;\n    const span = document.createElement(\"span\");\n    span.classList.add(highlightClassName);\n    span.onclick = () => notifyiOSOfHighlightTap(notebookTextSelection);\n    span.style.cssText = (0, exports.buildHighlightStyle)(notebookTextSelection);\n    span.textContent = textContent;\n    return span;\n};\n// Given the NotebookTextSelection, build the CSS to apply to the highlights\nconst buildHighlightStyle = (notebookTextSelection) => `position: relative;\n   padding: 0px;\n   border-top: none;\n   border-right: none;\n   border-bottom: 1px solid ${notebookTextSelection.borderColor};\n   background-color: ${notebookTextSelection.backgroundColor};`;\nexports.buildHighlightStyle = buildHighlightStyle;\n\n\n//# sourceURL=webpack:///./dist/use_case/ApplyHighlights.js?");

/***/ }),

/***/ "./dist/use_case/GetCurrentTextSelection.js":
/*!**************************************************!*\
  !*** ./dist/use_case/GetCurrentTextSelection.js ***!
  \**************************************************/
/***/ ((__unused_webpack_module, exports, __webpack_require__) => {

eval("\nObject.defineProperty(exports, \"__esModule\", ({ value: true }));\nexports[\"default\"] = getCurrentTextSelection;\nconst RangeAnchor_1 = __webpack_require__(/*! ../util/RangeAnchor */ \"./dist/util/RangeAnchor.js\");\nconst TextPositionAnchor_1 = __webpack_require__(/*! ../util/TextPositionAnchor */ \"./dist/util/TextPositionAnchor.js\");\nfunction getCurrentTextSelection() {\n    const selection = window.getSelection();\n    const range = selection === null || selection === void 0 ? void 0 : selection.getRangeAt(0);\n    const parentRef = document.getElementById(\"parent-container\");\n    const rangeAnchor = parentRef && range ? RangeAnchor_1.RangeAnchor.fromRange(parentRef, range) : null;\n    const textAnchor = parentRef && range ? TextPositionAnchor_1.TextPositionAnchor.fromRange(parentRef, range) : null;\n    return {\n        selectedText: selection === null || selection === void 0 ? void 0 : selection.toString(),\n        textPosition: textAnchor === null || textAnchor === void 0 ? void 0 : textAnchor.toSelector(),\n        range: rangeAnchor === null || rangeAnchor === void 0 ? void 0 : rangeAnchor.toSelector(),\n    };\n}\n\n\n//# sourceURL=webpack:///./dist/use_case/GetCurrentTextSelection.js?");

/***/ }),

/***/ "./dist/use_case/NotifyTextSelectionChange.js":
/*!****************************************************!*\
  !*** ./dist/use_case/NotifyTextSelectionChange.js ***!
  \****************************************************/
/***/ (function(__unused_webpack_module, exports, __webpack_require__) {

eval("\nvar __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {\n    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }\n    return new (P || (P = Promise))(function (resolve, reject) {\n        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }\n        function rejected(value) { try { step(generator[\"throw\"](value)); } catch (e) { reject(e); } }\n        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }\n        step((generator = generator.apply(thisArg, _arguments || [])).next());\n    });\n};\nvar __importDefault = (this && this.__importDefault) || function (mod) {\n    return (mod && mod.__esModule) ? mod : { \"default\": mod };\n};\nObject.defineProperty(exports, \"__esModule\", ({ value: true }));\nexports[\"default\"] = registerNotifyOnTextSelectionChange;\nconst GetCurrentTextSelection_1 = __importDefault(__webpack_require__(/*! ./GetCurrentTextSelection */ \"./dist/use_case/GetCurrentTextSelection.js\"));\nfunction registerNotifyOnTextSelectionChange() {\n    document.addEventListener(\"selectionchange\", () => __awaiter(this, void 0, void 0, function* () {\n        var _a;\n        const messageHandlers = (_a = window.webkit) === null || _a === void 0 ? void 0 : _a.messageHandlers;\n        if (!messageHandlers)\n            return;\n        const currentTextSelection = yield (0, GetCurrentTextSelection_1.default)();\n        window.webkit.messageHandlers.notebookTextSelectionChange.postMessage(JSON.stringify(currentTextSelection));\n    }));\n}\n\n\n//# sourceURL=webpack:///./dist/use_case/NotifyTextSelectionChange.js?");

/***/ }),

/***/ "./dist/util/RangeAnchor.js":
/*!**********************************!*\
  !*** ./dist/util/RangeAnchor.js ***!
  \**********************************/
/***/ ((__unused_webpack_module, exports, __webpack_require__) => {

eval("\nObject.defineProperty(exports, \"__esModule\", ({ value: true }));\nexports.RangeAnchor = void 0;\nconst TextPosition_1 = __webpack_require__(/*! ./TextPosition */ \"./dist/util/TextPosition.js\");\nconst TextRange_1 = __webpack_require__(/*! ./TextRange */ \"./dist/util/TextRange.js\");\nconst xpath_1 = __webpack_require__(/*! ./xpath */ \"./dist/util/xpath.js\");\nclass RangeAnchor {\n    constructor(root, range) {\n        this.root = root;\n        this.range = range;\n    }\n    static fromRange(root, range) {\n        return new RangeAnchor(root, range);\n    }\n    static fromSelector(root, selector) {\n        if (!(selector === null || selector === void 0 ? void 0 : selector.startContainer) || !(selector === null || selector === void 0 ? void 0 : selector.endContainer)) {\n            console.error(\"No start or end container in selector\");\n            return null;\n        }\n        const startContainer = (0, xpath_1.nodeFromXPath)(selector.startContainer, root);\n        if (!startContainer) {\n            console.error(\"Failed to resolve startContainer XPath\");\n            return null;\n        }\n        const endContainer = (0, xpath_1.nodeFromXPath)(selector.endContainer, root);\n        if (!endContainer) {\n            console.error(\"Failed to resolve endContainer XPath\");\n            return null;\n        }\n        const startPos = TextPosition_1.TextPosition.fromCharOffset(startContainer, selector.startOffset);\n        const endPos = TextPosition_1.TextPosition.fromCharOffset(endContainer, selector.endOffset);\n        if (!startPos || !endPos) {\n            return null;\n        }\n        const range = new TextRange_1.TextRange(startPos, endPos).toRange();\n        return new RangeAnchor(root, range);\n    }\n    toRange() {\n        return this.range;\n    }\n    toSelector() {\n        var _a;\n        const normalizedRange = (_a = TextRange_1.TextRange.fromRange(this.range)) === null || _a === void 0 ? void 0 : _a.toRange();\n        const textRange = normalizedRange && TextRange_1.TextRange.fromRange(normalizedRange);\n        const startContainer = textRange && (0, xpath_1.xpathFromNode)(textRange.start.element, this.root);\n        const endContainer = textRange && (0, xpath_1.xpathFromNode)(textRange.end.element, this.root);\n        if (!startContainer || !endContainer) {\n            return null;\n        }\n        return {\n            startContainer,\n            startOffset: textRange.start.offset,\n            endContainer,\n            endOffset: textRange.end.offset,\n        };\n    }\n}\nexports.RangeAnchor = RangeAnchor;\n\n\n//# sourceURL=webpack:///./dist/util/RangeAnchor.js?");

/***/ }),

/***/ "./dist/util/TextPosition.js":
/*!***********************************!*\
  !*** ./dist/util/TextPosition.js ***!
  \***********************************/
/***/ ((__unused_webpack_module, exports, __webpack_require__) => {

eval("\nObject.defineProperty(exports, \"__esModule\", ({ value: true }));\nexports.TextPosition = void 0;\nconst utils_1 = __webpack_require__(/*! ./utils */ \"./dist/util/utils.js\");\nconst TextRange_1 = __webpack_require__(/*! ./TextRange */ \"./dist/util/TextRange.js\");\nclass TextPosition {\n    constructor(element, offset) {\n        if (offset < 0) {\n            console.error(\"Offset is invalid\");\n        }\n        this.element = element;\n        this.offset = offset;\n    }\n    resolve(options = {}) {\n        try {\n            return (0, utils_1.resolveOffsets)(this.element, this.offset)[0];\n        }\n        catch (err) {\n            if (this.offset === 0 && options.direction !== undefined) {\n                const tw = document.createTreeWalker(this.element.getRootNode(), NodeFilter.SHOW_TEXT);\n                tw.currentNode = this.element;\n                const forwards = options.direction === TextRange_1.ResolveDirection.FORWARDS;\n                const text = forwards\n                    ? tw.nextNode()\n                    : tw.previousNode();\n                if (!text) {\n                    throw err;\n                }\n                return { node: text, offset: forwards ? 0 : text.data.length };\n            }\n            throw err;\n        }\n    }\n    static fromCharOffset(node, offset) {\n        switch (node.nodeType) {\n            case Node.TEXT_NODE:\n                return TextPosition.fromPoint(node, offset);\n            case Node.ELEMENT_NODE:\n                return new TextPosition(node, offset);\n            default:\n                console.error(\"Node is not an element or text node\");\n                return null;\n        }\n    }\n    static fromPoint(node, offset) {\n        switch (node.nodeType) {\n            case Node.TEXT_NODE: {\n                if (offset < 0 || offset > node.data.length) {\n                    console.error(\"Text node offset is out of range\");\n                    return null;\n                }\n                if (!node.parentElement) {\n                    console.error(\"Text node has no parent\");\n                    return null;\n                }\n                const textOffset = (0, utils_1.previousSiblingsTextLength)(node) + offset;\n                return new TextPosition(node.parentElement, textOffset);\n            }\n            case Node.ELEMENT_NODE: {\n                if (offset < 0 || offset > node.childNodes.length) {\n                    console.error(\"Child node offset is out of range\");\n                    return null;\n                }\n                let textOffset = 0;\n                for (let i = 0; i < offset; i++) {\n                    textOffset += (0, utils_1.nodeTextLength)(node.childNodes[i]);\n                }\n                return new TextPosition(node, textOffset);\n            }\n            default:\n                console.error(\"Point is not in an element or text node\");\n                return null;\n        }\n    }\n    relativeTo(parent) {\n        if (!parent.contains(this.element)) {\n            throw new Error(\"Parent is not an ancestor of current element\");\n        }\n        let el = this.element;\n        let offset = this.offset;\n        while (el !== parent) {\n            offset += (0, utils_1.previousSiblingsTextLength)(el);\n            if (el.parentElement) {\n                el = el.parentElement;\n            }\n        }\n        return new TextPosition(el, offset);\n    }\n}\nexports.TextPosition = TextPosition;\n\n\n//# sourceURL=webpack:///./dist/util/TextPosition.js?");

/***/ }),

/***/ "./dist/util/TextPositionAnchor.js":
/*!*****************************************!*\
  !*** ./dist/util/TextPositionAnchor.js ***!
  \*****************************************/
/***/ ((__unused_webpack_module, exports, __webpack_require__) => {

eval("\nObject.defineProperty(exports, \"__esModule\", ({ value: true }));\nexports.TextPositionAnchor = void 0;\nconst TextRange_1 = __webpack_require__(/*! ./TextRange */ \"./dist/util/TextRange.js\");\nclass TextPositionAnchor {\n    constructor(root, start, end) {\n        this.root = root;\n        this.start = start;\n        this.end = end;\n    }\n    static fromRange(root, range) {\n        var _a;\n        const textRange = (_a = TextRange_1.TextRange.fromRange(range)) === null || _a === void 0 ? void 0 : _a.relativeTo(root);\n        if (!textRange)\n            return null;\n        return new TextPositionAnchor(root, textRange.start.offset, textRange.end.offset);\n    }\n    static fromSelector(root, selector) {\n        return new TextPositionAnchor(root, selector.start, selector.end);\n    }\n    toSelector() {\n        return {\n            start: this.start,\n            end: this.end,\n        };\n    }\n    toRange() {\n        return TextRange_1.TextRange.fromOffsets(this.root, this.start, this.end).toRange();\n    }\n}\nexports.TextPositionAnchor = TextPositionAnchor;\n\n\n//# sourceURL=webpack:///./dist/util/TextPositionAnchor.js?");

/***/ }),

/***/ "./dist/util/TextRange.js":
/*!********************************!*\
  !*** ./dist/util/TextRange.js ***!
  \********************************/
/***/ ((__unused_webpack_module, exports, __webpack_require__) => {

eval("\nObject.defineProperty(exports, \"__esModule\", ({ value: true }));\nexports.TextRange = exports.ResolveDirection = void 0;\nconst TextPosition_1 = __webpack_require__(/*! ./TextPosition */ \"./dist/util/TextPosition.js\");\nconst utils_1 = __webpack_require__(/*! ./utils */ \"./dist/util/utils.js\");\nvar ResolveDirection;\n(function (ResolveDirection) {\n    ResolveDirection[ResolveDirection[\"FORWARDS\"] = 1] = \"FORWARDS\";\n    ResolveDirection[ResolveDirection[\"BACKWARDS\"] = 2] = \"BACKWARDS\";\n})(ResolveDirection || (exports.ResolveDirection = ResolveDirection = {}));\nclass TextRange {\n    constructor(start, end) {\n        this.start = start;\n        this.end = end;\n    }\n    toRange() {\n        let start;\n        let end;\n        if (this.start.element === this.end.element &&\n            this.start.offset <= this.end.offset) {\n            [start, end] = (0, utils_1.resolveOffsets)(this.start.element, this.start.offset, this.end.offset);\n        }\n        else {\n            start = this.start.resolve({\n                direction: ResolveDirection.FORWARDS,\n            });\n            end = this.end.resolve({ direction: ResolveDirection.BACKWARDS });\n        }\n        const range = new Range();\n        range.setStart(start.node, start.offset);\n        range.setEnd(end.node, end.offset);\n        return range;\n    }\n    static fromRange(range) {\n        const start = TextPosition_1.TextPosition.fromPoint(range.startContainer, range.startOffset);\n        const end = TextPosition_1.TextPosition.fromPoint(range.endContainer, range.endOffset);\n        if (!start || !end) {\n            return null;\n        }\n        return new TextRange(start, end);\n    }\n    static fromOffsets(root, start, end) {\n        return new TextRange(new TextPosition_1.TextPosition(root, start), new TextPosition_1.TextPosition(root, end));\n    }\n    relativeTo(element) {\n        return new TextRange(this.start.relativeTo(element), this.end.relativeTo(element));\n    }\n}\nexports.TextRange = TextRange;\n\n\n//# sourceURL=webpack:///./dist/util/TextRange.js?");

/***/ }),

/***/ "./dist/util/utils.js":
/*!****************************!*\
  !*** ./dist/util/utils.js ***!
  \****************************/
/***/ ((__unused_webpack_module, exports) => {

eval("\nObject.defineProperty(exports, \"__esModule\", ({ value: true }));\nexports.resolveOffsets = exports.previousSiblingsTextLength = exports.nodeTextLength = void 0;\nconst nodeTextLength = (node) => {\n    var _a, _b;\n    switch (node.nodeType) {\n        case Node.ELEMENT_NODE:\n        case Node.TEXT_NODE:\n            return (_b = (_a = node.textContent) === null || _a === void 0 ? void 0 : _a.length) !== null && _b !== void 0 ? _b : 0;\n        default:\n            return 0;\n    }\n};\nexports.nodeTextLength = nodeTextLength;\nconst previousSiblingsTextLength = (node) => {\n    let sibling = node.previousSibling;\n    let length = 0;\n    while (sibling) {\n        length += (0, exports.nodeTextLength)(sibling);\n        sibling = sibling.previousSibling;\n    }\n    return length;\n};\nexports.previousSiblingsTextLength = previousSiblingsTextLength;\nconst resolveOffsets = (element, ...offsets) => {\n    let nextOffset = offsets.shift();\n    const nodeIter = element.ownerDocument.createNodeIterator(element, NodeFilter.SHOW_TEXT);\n    const results = [];\n    let currentNode = nodeIter.nextNode();\n    let textNode = null;\n    let length = 0;\n    while (nextOffset !== undefined && currentNode) {\n        textNode = currentNode;\n        if (length + textNode.data.length > nextOffset) {\n            results.push({ node: textNode, offset: nextOffset - length });\n            nextOffset = offsets.shift();\n        }\n        else {\n            currentNode = nodeIter.nextNode();\n            length += textNode.data.length;\n        }\n    }\n    while (nextOffset !== undefined && textNode && length === nextOffset) {\n        results.push({ node: textNode, offset: textNode.data.length });\n        nextOffset = offsets.shift();\n    }\n    if (nextOffset !== undefined) {\n        console.error(\"Offset exceeds text length\");\n    }\n    return results;\n};\nexports.resolveOffsets = resolveOffsets;\n\n\n//# sourceURL=webpack:///./dist/util/utils.js?");

/***/ }),

/***/ "./dist/util/xpath.js":
/*!****************************!*\
  !*** ./dist/util/xpath.js ***!
  \****************************/
/***/ ((__unused_webpack_module, exports) => {

eval("\nObject.defineProperty(exports, \"__esModule\", ({ value: true }));\nexports.nodeFromXPath = exports.xpathFromNode = void 0;\nconst getNodeName = (node) => {\n    const nodeName = node.nodeName.toLowerCase();\n    return nodeName === \"#text\" ? \"text()\" : nodeName;\n};\nfunction getNodePosition(node) {\n    let pos = 0;\n    let tmp = node;\n    while (tmp) {\n        if (tmp.nodeName === node.nodeName) {\n            pos += 1;\n        }\n        tmp = tmp.previousSibling;\n    }\n    return pos;\n}\nconst getPathSegment = (node) => {\n    const name = getNodeName(node);\n    const pos = getNodePosition(node);\n    return `${name}[${pos}]`;\n};\nconst xpathFromNode = (node, root) => {\n    let xpath = \"\";\n    let elem = node;\n    while (elem !== root) {\n        if (!elem) {\n            console.error(\"Node is not a descendant of root\");\n            return;\n        }\n        xpath = `${getPathSegment(elem)}/${xpath}`;\n        elem = elem.parentNode;\n    }\n    xpath = `/${xpath}`;\n    xpath = xpath.replace(/\\/$/, \"\"); // Remove trailing slash\n    return xpath;\n};\nexports.xpathFromNode = xpathFromNode;\nconst nthChildOfType = (element, nodeName, index) => {\n    const name = nodeName.toUpperCase();\n    let matchIndex = -1;\n    for (let i = 0; i < element.children.length; i++) {\n        const child = element.children[i];\n        if (child.nodeName.toUpperCase() === name) {\n            ++matchIndex;\n            if (matchIndex === index) {\n                return child;\n            }\n        }\n    }\n    return null;\n};\nconst evaluateSimpleXPath = (xpath, root) => {\n    const isSimpleXPath = xpath.match(/^(\\/[A-Za-z0-9-]+(\\[[0-9]+])?)+$/) !== null;\n    if (!isSimpleXPath) {\n        console.error(\"Expression is not a simple XPath\");\n        return null;\n    }\n    const segments = xpath.split(\"/\");\n    let element = root;\n    // Remove leading empty segment. The regex above validates that the XPath\n    // has at least two segments, with the first being empty and the others non-empty.\n    segments.shift();\n    for (const segment of segments) {\n        let elementName;\n        let elementIndex;\n        const separatorPos = segment.indexOf(\"[\");\n        if (separatorPos !== -1) {\n            elementName = segment.slice(0, separatorPos);\n            const indexStr = segment.slice(separatorPos + 1, segment.indexOf(\"]\"));\n            elementIndex = Number.parseInt(indexStr) - 1;\n            if (elementIndex < 0) {\n                return null;\n            }\n        }\n        else {\n            elementName = segment;\n            elementIndex = 0;\n        }\n        const child = nthChildOfType(element, elementName, elementIndex);\n        if (!child) {\n            return null;\n        }\n        element = child;\n    }\n    return element;\n};\nconst nodeFromXPath = (xpath, root = document.body) => {\n    try {\n        return evaluateSimpleXPath(xpath, root);\n    }\n    catch (_a) {\n        return document.evaluate(`.${xpath}`, root, null /* namespaceResolver */, XPathResult.FIRST_ORDERED_NODE_TYPE, null /* result */).singleNodeValue;\n    }\n};\nexports.nodeFromXPath = nodeFromXPath;\n\n\n//# sourceURL=webpack:///./dist/util/xpath.js?");

/***/ })

/******/ 	});
/************************************************************************/
/******/ 	// The module cache
/******/ 	var __webpack_module_cache__ = {};
/******/ 	
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/ 		// Check if module is in cache
/******/ 		var cachedModule = __webpack_module_cache__[moduleId];
/******/ 		if (cachedModule !== undefined) {
/******/ 			return cachedModule.exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = __webpack_module_cache__[moduleId] = {
/******/ 			// no module.id needed
/******/ 			// no module.loaded needed
/******/ 			exports: {}
/******/ 		};
/******/ 	
/******/ 		// Execute the module function
/******/ 		__webpack_modules__[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/ 	
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/ 	
/************************************************************************/
/******/ 	
/******/ 	// startup
/******/ 	// Load entry module and return exports
/******/ 	// This entry module is referenced by other modules so it can't be inlined
/******/ 	var __webpack_exports__ = __webpack_require__("./dist/main.js");
/******/ 	
/******/ })()
;