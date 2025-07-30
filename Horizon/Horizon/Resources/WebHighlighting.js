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

// --- Start: dist/util/utils.js ---

/**
 * Calculates the text content length of a given node.
 * @param {Node} node - The DOM node.
 * @returns {number} The length of the text content.
 */
const nodeTextLength = (node) => {
    switch (node.nodeType) {
        case Node.ELEMENT_NODE:
        case Node.TEXT_NODE:
            return node.textContent?.length ?? 0;
        default:
            return 0;
    }
};

/**
 * Calculates the total text length of all previous siblings of a given node.
 * @param {Node} node - The DOM node.
 * @returns {number} The total length of text content of previous siblings.
 */
const previousSiblingsTextLength = (node) => {
    let sibling = node.previousSibling;
    let length = 0;
    while (sibling) {
        length += nodeTextLength(sibling);
        sibling = sibling.previousSibling;
    }
    return length;
};

/**
 * Resolves character offsets within an element to specific text nodes and offsets.
 * @param {Element} element - The root element to resolve offsets within.
 * @param {...number} offsets - One or more character offsets to resolve.
 * @returns {Array<{node: Text, offset: number}>} An array of objects, each containing the text node and the resolved offset within that node.
 */
const resolveOffsets = (element, ...offsets) => {
    let nextOffset = offsets.shift();
    const nodeIter = element.ownerDocument.createNodeIterator(element, NodeFilter.SHOW_TEXT);
    const results = [];
    let currentNode = nodeIter.nextNode();
    let textNode = null;
    let length = 0;

    while (nextOffset !== undefined && currentNode) {
        textNode = currentNode;
        if (length + textNode.data.length > nextOffset) {
            results.push({ node: textNode, offset: nextOffset - length });
            nextOffset = offsets.shift();
        } else {
            currentNode = nodeIter.nextNode();
            length += textNode.data.length;
        }
    }

    // Handle cases where the offset is exactly at the end of a text node
    while (nextOffset !== undefined && textNode && length === nextOffset) {
        results.push({ node: textNode, offset: textNode.data.length });
        nextOffset = offsets.shift();
    }

    if (nextOffset !== undefined) {
        console.error("Offset exceeds text length");
    }
    return results;
};

// --- End: dist/util/utils.js ---


// --- Start: dist/util/xpath.js ---

/**
 * Gets the node name in a format suitable for XPath.
 * @param {Node} node - The DOM node.
 * @returns {string} The node name.
 */
const getNodeName = (node) => {
    const nodeName = node.nodeName.toLowerCase();
    return nodeName === "#text" ? "text()" : nodeName;
};

/**
 * Gets the position of a node among its siblings of the same name.
 * @param {Node} node - The DOM node.
 * @returns {number} The position (1-based index).
 */
function getNodePosition(node) {
    let pos = 0;
    let tmp = node;
    while (tmp) {
        if (tmp.nodeName === node.nodeName) {
            pos += 1;
        }
        tmp = tmp.previousSibling;
    }
    return pos;
}

/**
 * Creates an XPath segment for a given node.
 * @param {Node} node - The DOM node.
 * @returns {string} The XPath segment.
 */
const getPathSegment = (node) => {
    const name = getNodeName(node);
    const pos = getNodePosition(node);
    return `${name}[${pos}]`;
};

/**
 * Generates an XPath expression for a given node relative to a root element.
 * @param {Node} node - The target DOM node.
 * @param {Element} root - The root element for the XPath.
 * @returns {string | undefined} The XPath string, or undefined if the node is not a descendant of the root.
 */
const xpathFromNode = (node, root) => {
    let xpath = "";
    let elem = node;
    while (elem !== root) {
        if (!elem) {
            console.error("Node is not a descendant of root");
            return;
        }
        xpath = `${getPathSegment(elem)}/${xpath}`;
        elem = elem.parentNode;
    }
    xpath = `/${xpath}`;
    xpath = xpath.replace(/\/$/, ""); // Remove trailing slash
    return xpath;
};

/**
 * Finds the nth child of a specific node type.
 * @param {Element} element - The parent element.
 * @param {string} nodeName - The name of the child node type (e.g., "div", "text()").
 * @param {number} index - The 0-based index of the child.
 * @returns {Element | null} The found child element, or null.
 */
const nthChildOfType = (element, nodeName, index) => {
    const name = nodeName.toUpperCase();
    let matchIndex = -1;
    for (let i = 0; i < element.children.length; i++) {
        const child = element.children[i];
        if (child.nodeName.toUpperCase() === name) {
            ++matchIndex;
            if (matchIndex === index) {
                return child;
            }
        }
    }
    return null;
};

/**
 * Evaluates a simple XPath expression to find a node.
 * @param {string} xpath - The simple XPath expression.
 * @param {Element} root - The root element to start the search from.
 * @returns {Element | null} The found element, or null.
 */
const evaluateSimpleXPath = (xpath, root) => {
    // This regex checks for simple paths like /div[1]/span[2]
    const isSimpleXPath = xpath.match(/^(\/[A-Za-z0-9-]+(\[[0-9]+])?)+$/) !== null;
    if (!isSimpleXPath) {
        console.error("Expression is not a simple XPath");
        return null;
    }

    const segments = xpath.split("/");
    let element = root;
    // Remove leading empty segment. The regex above validates that the XPath
    // has at least two segments, with the first being empty and the others non-empty.
    segments.shift();

    for (const segment of segments) {
        let elementName;
        let elementIndex;
        const separatorPos = segment.indexOf("[");
        if (separatorPos !== -1) {
            elementName = segment.slice(0, separatorPos);
            const indexStr = segment.slice(separatorPos + 1, segment.indexOf("]"));
            elementIndex = Number.parseInt(indexStr) - 1;
            if (elementIndex < 0) {
                return null;
            }
        } else {
            elementName = segment;
            elementIndex = 0;
        }

        const child = nthChildOfType(element, elementName, elementIndex);
        if (!child) {
            return null;
        }
        element = child;
    }
    return element;
};

/**
 * Finds a node from an XPath expression. Tries a simple evaluation first, then falls back to `document.evaluate`.
 * @param {string} xpath - The XPath expression.
 * @param {Element} [root=document.body] - The root element for the XPath evaluation.
 * @returns {Node | null} The found node, or null.
 */
const nodeFromXPath = (xpath, root = document.body) => {
    try {
        return evaluateSimpleXPath(xpath, root);
    } catch (e) {
        // Fallback to standard XPath evaluation for more complex cases
        return document.evaluate(`.${xpath}`, root, null /* namespaceResolver */, XPathResult.FIRST_ORDERED_NODE_TYPE, null /* result */).singleNodeValue;
    }
};

// --- End: dist/util/xpath.js ---


// --- Start: dist/util/TextRange.js (and ResolveDirection enum) ---

/**
 * Enum for text resolution direction.
 * @enum {number}
 */
const ResolveDirection = {
    FORWARDS: 1,
    BACKWARDS: 2
};

/**
 * Represents a text range defined by start and end TextPositions.
 */
class TextRange {
    /**
     * @param {TextPosition} start - The starting TextPosition.
     * @param {TextPosition} end - The ending TextPosition.
     */
    constructor(start, end) {
        this.start = start;
        this.end = end;
    }

    /**
     * Converts the TextRange to a DOM Range object.
     * @returns {Range} A DOM Range object.
     */
    toRange() {
        let start;
        let end;

        // Note: TextPosition class is defined below, due to circular dependency.
        // This method will rely on TextPosition being available at runtime.
        if (this.start.element === this.end.element &&
            this.start.offset <= this.end.offset) {
            // If start and end are in the same element and in order, resolve within that element
            [start, end] = resolveOffsets(this.start.element, this.start.offset, this.end.offset);
        } else {
            // Otherwise, resolve start and end positions independently with direction
            start = this.start.resolve({
                direction: ResolveDirection.FORWARDS,
            });
            end = this.end.resolve({ direction: ResolveDirection.BACKWARDS });
        }

        const range = new Range();
        range.setStart(start.node, start.offset);
        range.setEnd(end.node, end.offset);
        return range;
    }

    /**
     * Creates a TextRange from a DOM Range object.
     * @param {Range} range - The DOM Range object.
     * @returns {TextRange | null} A new TextRange instance, or null if start/end positions cannot be determined.
     */
    static fromRange(range) {
        // Note: TextPosition class is defined below.
        const start = TextPosition.fromPoint(range.startContainer, range.startOffset);
        const end = TextPosition.fromPoint(range.endContainer, range.endOffset);
        if (!start || !end) {
            return null;
        }
        return new TextRange(start, end);
    }

    /**
     * Creates a TextRange from character offsets within a root element.
     * @param {Element} root - The root element.
     * @param {number} start - The starting character offset.
     * @param {number} end - The ending character offset.
     * @returns {TextRange} A new TextRange instance.
     */
    static fromOffsets(root, start, end) {
        // Note: TextPosition class is defined below.
        return new TextRange(new TextPosition(root, start), new TextPosition(root, end));
    }

    /**
     * Creates a new TextRange with positions relative to a given parent element.
     * @param {Element} element - The parent element to make positions relative to.
     * @returns {TextRange} A new TextRange instance with relative positions.
     * @throws {Error} If the parent is not an ancestor of the current elements.
     */
    relativeTo(element) {
        // Note: TextPosition class is defined below.
        return new TextRange(this.start.relativeTo(element), this.end.relativeTo(element));
    }
}

// --- End: dist/util/TextRange.js ---


// --- Start: dist/util/TextPosition.js ---

/**
 * Represents a position within a text flow, defined by an element and an offset.
 */
class TextPosition {
    /**
     * @param {Element} element - The element containing the text.
     * @param {number} offset - The character offset within the element's text content.
     */
    constructor(element, offset) {
        if (offset < 0) {
            console.error("Offset is invalid");
        }
        this.element = element;
        this.offset = offset;
    }

    /**
     * Resolves the TextPosition to a specific text node and offset within that node.
     * @param {object} [options={}] - Options for resolution.
     * @param {number} [options.direction] - Direction to resolve if offset is 0 (from ResolveDirection enum).
     * @returns {{node: Text, offset: number}} The resolved text node and offset.
     * @throws {Error} If the offset cannot be resolved.
     */
    resolve(options = {}) {
        try {
            return resolveOffsets(this.element, this.offset)[0];
        } catch (err) {
            // Special handling for offset 0 with a direction, to find the previous/next text node.
            if (this.offset === 0 && options.direction !== undefined) {
                const tw = document.createTreeWalker(this.element.getRootNode(), NodeFilter.SHOW_TEXT);
                tw.currentNode = this.element;
                const forwards = options.direction === ResolveDirection.FORWARDS;
                const text = forwards
                    ? tw.nextNode()
                    : tw.previousNode();
                if (!text) {
                    throw err; // Re-throw if no text node found in the specified direction
                }
                return { node: text, offset: forwards ? 0 : text.data.length };
            }
            throw err; // Re-throw other errors
        }
    }

    /**
     * Creates a TextPosition from a character offset within a given node.
     * This is useful when the node might be a text node or an element node.
     * @param {Node} node - The node (can be Element or Text).
     * @param {number} offset - The character offset.
     * @returns {TextPosition | null} A new TextPosition instance, or null if invalid.
     */
    static fromCharOffset(node, offset) {
        switch (node.nodeType) {
            case Node.TEXT_NODE:
                return TextPosition.fromPoint(node, offset);
            case Node.ELEMENT_NODE:
                return new TextPosition(node, offset);
            default:
                console.error("Node is not an element or text node");
                return null;
        }
    }

    /**
     * Creates a TextPosition from a point (node and offset within that node).
     * This method handles both text nodes and element nodes correctly.
     * @param {Node} node - The node (can be Element or Text).
     * @param {number} offset - The offset within the node.
     * @returns {TextPosition | null} A new TextPosition instance, or null if invalid.
     */
    static fromPoint(node, offset) {
        switch (node.nodeType) {
            case Node.TEXT_NODE: {
                if (offset < 0 || offset > node.data.length) {
                    console.error("Text node offset is out of range");
                    return null;
                }
                if (!node.parentElement) {
                    console.error("Text node has no parent");
                    return null;
                }
                const textOffset = previousSiblingsTextLength(node) + offset;
                return new TextPosition(node.parentElement, textOffset);
            }
            case Node.ELEMENT_NODE: {
                if (offset < 0 || offset > node.childNodes.length) {
                    console.error("Child node offset is out of range");
                    return null;
                }
                let textOffset = 0;
                for (let i = 0; i < offset; i++) {
                    textOffset += nodeTextLength(node.childNodes[i]);
                }
                return new TextPosition(node, textOffset);
            }
            default:
                console.error("Point is not in an element or text node");
                return null;
        }
    }

    /**
     * Calculates a new TextPosition relative to a given parent element.
     * @param {Element} parent - The parent element to make the position relative to.
     * @returns {TextPosition} A new TextPosition instance relative to the parent.
     * @throws {Error} If the parent is not an ancestor of the current element.
     */
    relativeTo(parent) {
        if (!parent.contains(this.element)) {
            throw new Error("Parent is not an ancestor of current element");
        }
        let el = this.element;
        let offset = this.offset;
        while (el !== parent) {
            offset += previousSiblingsTextLength(el);
            if (el.parentElement) {
                el = el.parentElement;
            } else {
                // Should not happen if parent.contains(this.element) is true
                throw new Error("Unexpected: Element has no parent while traversing up to root.");
            }
        }
        return new TextPosition(el, offset);
    }
}

// --- End: dist/util/TextPosition.js ---


// --- Start: dist/util/RangeAnchor.js ---

/**
 * Represents a range anchor using XPath and character offsets,
 * allowing it to be serialized and deserialized.
 */
class RangeAnchor {
    /**
     * @param {Element} root - The root element relative to which the range is defined.
     * @param {Range} range - The DOM Range object.
     */
    constructor(root, range) {
        this.root = root;
        this.range = range;
    }

    /**
     * Creates a RangeAnchor from a DOM Range.
     * @param {Element} root - The root element.
     * @param {Range} range - The DOM Range.
     * @returns {RangeAnchor} A new RangeAnchor instance.
     */
    static fromRange(root, range) {
        return new RangeAnchor(root, range);
    }

    /**
     * Creates a RangeAnchor from a serialized selector object.
     * @param {Element} root - The root element.
     * @param {object} selector - The selector object with startContainer, startOffset, endContainer, endOffset.
     * @returns {RangeAnchor | null} A new RangeAnchor instance, or null if resolution fails.
     */
    static fromSelector(root, selector) {
        if (!selector?.startContainer || !selector?.endContainer) {
            console.error("No start or end container in selector");
            return null;
        }

        const startContainer = nodeFromXPath(selector.startContainer, root);
        if (!startContainer) {
            console.error("Failed to resolve startContainer XPath");
            return null;
        }

        const endContainer = nodeFromXPath(selector.endContainer, root);
        if (!endContainer) {
            console.error("Failed to resolve endContainer XPath");
            return null;
        }

        const startPos = TextPosition.fromCharOffset(startContainer, selector.startOffset);
        const endPos = TextPosition.fromCharOffset(endContainer, selector.endOffset);

        if (!startPos || !endPos) {
            return null;
        }

        const range = new TextRange(startPos, endPos).toRange();
        return new RangeAnchor(root, range);
    }

    /**
     * Returns the underlying DOM Range object.
     * @returns {Range} The DOM Range.
     */
    toRange() {
        return this.range;
    }

    /**
     * Serializes the RangeAnchor to a selector object.
     * @returns {object | null} The selector object, or null if serialization fails.
     */
    toSelector() {
        const normalizedRange = TextRange.fromRange(this.range)?.toRange();
        const textRange = normalizedRange && TextRange.fromRange(normalizedRange);

        const startContainer = textRange && xpathFromNode(textRange.start.element, this.root);
        const endContainer = textRange && xpathFromNode(textRange.end.element, this.root);

        if (!startContainer || !endContainer) {
            return null;
        }

        return {
            startContainer,
            startOffset: textRange.start.offset,
            endContainer,
            endOffset: textRange.end.offset,
        };
    }
}

// --- End: dist/util/RangeAnchor.js ---


// --- Start: dist/util/TextPositionAnchor.js ---

/**
 * Represents a text position anchor using character offsets relative to a root element.
 * This is a simpler anchor type compared to RangeAnchor, suitable for collapsed selections or single points.
 */
class TextPositionAnchor {
    /**
     * @param {Element} root - The root element relative to which the offsets are defined.
     * @param {number} start - The starting character offset.
     * @param {number} end - The ending character offset.
     */
    constructor(root, start, end) {
        this.root = root;
        this.start = start;
        this.end = end;
    }

    /**
     * Creates a TextPositionAnchor from a DOM Range.
     * @param {Element} root - The root element.
     * @param {Range} range - The DOM Range.
     * @returns {TextPositionAnchor | null} A new TextPositionAnchor instance, or null if conversion fails.
     */
    static fromRange(root, range) {
        const textRange = TextRange.fromRange(range)?.relativeTo(root);
        if (!textRange)
            return null;
        return new TextPositionAnchor(root, textRange.start.offset, textRange.end.offset);
    }

    /**
     * Creates a TextPositionAnchor from a serialized selector object.
     * @param {Element} root - The root element.
     * @param {object} selector - The selector object with start and end offsets.
     * @returns {TextPositionAnchor} A new TextPositionAnchor instance.
     */
    static fromSelector(root, selector) {
        return new TextPositionAnchor(root, selector.start, selector.end);
    }

    /**
     * Serializes the TextPositionAnchor to a selector object.
     * @returns {{start: number, end: number}} The selector object.
     */
    toSelector() {
        return {
            start: this.start,
            end: this.end,
        };
    }

    /**
     * Converts the TextPositionAnchor to a DOM Range object.
     * @returns {Range} A DOM Range object.
     */
    toRange() {
        return TextRange.fromOffsets(this.root, this.start, this.end).toRange();
    }
}

// --- End: dist/util/TextPositionAnchor.js ---


// --- Start: dist/use_case/GetCurrentTextSelection.js ---

/**
 * Gets the current text selection information from the DOM.
 * @returns {object} An object containing selected text, text position selector, and range selector.
 */
function getCurrentTextSelection() {
    const selection = window.getSelection();
    const range = selection?.getRangeAt(0); // Optional chaining for selection and getRangeAt
    const parentRef = document.getElementById("parent-container");

    const rangeAnchor = parentRef && range ? RangeAnchor.fromRange(parentRef, range) : null;
    const textAnchor = parentRef && range ? TextPositionAnchor.fromRange(parentRef, range) : null;

    return {
        selectedText: selection?.toString(), // Optional chaining for selection
        textPosition: textAnchor?.toSelector(), // Optional chaining for textAnchor
        range: rangeAnchor?.toSelector(), // Optional chaining for rangeAnchor
    };
}

// --- End: dist/use_case/GetCurrentTextSelection.js ---


// --- Start: dist/use_case/ApplyHighlights.js ---

const highlightClassName = "notebook-highlight";

/**
 * Adds a single highlight to the document.
 * @param {object} notebookTextSelection - The highlight object containing range and styling.
 */
const addHighlight = (notebookTextSelection) => {
    let parent = document.getElementById("parent-container");
    if (!parent) return;

    // Resolve the range from the selector
    let range = RangeAnchor.fromSelector(parent, notebookTextSelection.range)?.toRange();
    if (!range) return;

    const textNodeSpans = getHighlightRange(range);

    for (const textNode of textNodeSpans) {
        const parentNode = textNode.parentNode;
        const highlightElement = createHighlightElement({ textContent: textNode.textContent, notebookTextSelection });
        if (!highlightElement) return;
        parentNode.replaceChild(highlightElement, textNode);
    }
};

/**
 * Removes all existing highlights from the document.
 */
function clearHighlights() {
    const elements = document.getElementsByClassName(highlightClassName);
    
    
    const icons = element.querySelectorAll('.highlight-icon');
    icons.forEach(icon => icon.remove());
    // Iterate while elements exist, as getElementsByClassName returns a live collection
    while (elements.length) {
        const element = elements[0];
        // Filter for actual text nodes (Node.TEXT_NODE) and replace the highlight element with them
        const textNodes = Array.from(element.childNodes).filter(node => node.nodeType === Node.TEXT_NODE);
        element.replaceWith(...textNodes);
    }
}

/**
 * Gets the text nodes within a given range that should be highlighted.
 * @param {Range} range - The DOM Range object.
 * @returns {Array<Text>} An array of text nodes to be highlighted.
 */
const getHighlightRange = (range) => {
    const textNodes = wholeTextNodesInRange(range);
    const whitespace = /^\s*$/; // Regex to test for only whitespace

    return textNodes.filter((node) => {
        const parentElement = node.parentElement;
        // Only highlight if:
        // 1. The parent element has only one child and is a SPAN (suggests it's already a highlight span)
        // OR
        // 2. The node's data is not just whitespace.
        return (((parentElement?.childNodes.length) === 1 && (parentElement?.tagName) === "SPAN") || !whitespace.test(node.data));
    });
};

/**
 * Retrieves all whole text nodes within a given DOM Range.
 * Splits text nodes at range boundaries if necessary.
 * @param {Range} range - The DOM Range object.
 * @returns {Array<Text>} An array of text nodes fully contained or partially covered by the range.
 */
const wholeTextNodesInRange = (range) => {
    if (range.collapsed) return [];

    let root = range.commonAncestorContainer;
    // If common ancestor is a text node, go up to its parent element
    if (root && root.nodeType !== Node.ELEMENT_NODE) root = root.parentElement;
    if (!root) return [];

    const textNodes = [];
    // Create a NodeIterator to traverse only text nodes within the root
    const nodeIter = root?.ownerDocument?.createNodeIterator(root, NodeFilter.SHOW_TEXT);

    let node = nodeIter?.nextNode() || null;
    while (node) {
        // Skip nodes that are not within the range
        if (!isNodeInRange(range, node)) {
            node = nodeIter?.nextNode() || null;
            continue;
        }

        const text = node;
        // If the start of the range is within this text node, split it
        if (text === range.startContainer && range.startOffset > 0) {
            text.splitText(range.startOffset);
            node = nodeIter?.nextNode() || null; // NodeIterator needs to be advanced after split
            continue;
        }
        // If the end of the range is within this text node, split it
        if (text === range.endContainer && range.endOffset < text.data.length) {
            text.splitText(range.endOffset);
        }
        textNodes.push(text);
        node = nodeIter?.nextNode() || null;
    }
    return textNodes;
};

/**
 * Checks if a given node is within the boundaries of a DOM Range.
 * @param {Range} range - The DOM Range.
 * @param {Node} node - The node to check.
 * @returns {boolean} True if the node is within the range, false otherwise.
 */
const isNodeInRange = (range, node) => {
    try {
        // Compare the start and end points of the node with the range's boundaries
        const length = node.nodeValue?.length ?? node.childNodes.length;
        return (range.comparePoint(node, 0) <= 0 && range.comparePoint(node, length) >= 0);
    } catch (e) {
        // Catch errors that might occur if comparePoint is called on an invalid node/offset
        return false;
    }
};

/**
 * Notifies the iOS webkit message handler about a highlight tap.
 * @param {object} notebookTextSelection - The highlight data associated with the tapped highlight.
 */
const notifyiOSOfHighlightTap = (notebookTextSelection) => {
    const messageHandlers = window.webkit?.messageHandlers;
    if (!messageHandlers) return;
    messageHandlers.notebookHighlightTap.postMessage(JSON.stringify(notebookTextSelection));
};

/**
 * Creates a highlight HTML span element.
 * @param {object} params - Parameters for creating the highlight element.
 * @param {string} params.textContent - The text content for the highlight.
 * @param {object} params.notebookTextSelection - The selection data for the highlight.
 * @returns {HTMLSpanElement | null} The created span element, or null if textContent is empty.
 */

function injectHighlightStyles() {
  if (document.getElementById("highlight-style")) return; // prevent duplicates

  const style = document.createElement("style");
  style.id = "highlight-style";
  style.textContent = `
    .notebook-highlight {
      position: relative;
      padding: 0px;
      border-top: none;
      border-right: none;
      border-bottom: 1px solid var(--border-color);
      background-color: var(--background-color);
    }

    .with-badge::before {
      content: "";
      position: absolute;
      left: -5px;
      top: 0px;
      transform: translateY(-50%);
      width: 14px;
      height: 14px;
      background-image: var(--badge-icon);
      background-size: contain;
      background-repeat: no-repeat;
      background-position: center;
      border-radius: 50%;
      background-color: var(--background-color);  
    }
  `;
  document.head.appendChild(style);
}

const createHighlightElement = ({ textContent, notebookTextSelection }) => {
  if (!textContent) return null;

  injectHighlightStyles(); // Make sure styles are added

  const span = document.createElement("span");

  span.classList.add("notebook-highlight", "with-badge");

  // Set dynamic variables 
  const confusingImageBase64 = "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTQiIGhlaWdodD0iMTQiIHZpZXdCb3g9IjAgMCAxNCAxNCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHJlY3Qgd2lkdGg9IjE0IiBoZWlnaHQ9IjE0IiByeD0iNyIgZmlsbD0iI0M3MUYyMyIvPgo8cGF0aCBkPSJNOC4yMzE1NyA1LjM0MDc4QzguMjMxNTcgNC45OTY3NSA4LjExNjYgNC43MjA0MyA3Ljg4NjY3IDQuNTExODJDNy42NTY2NyA0LjMwMzI4IDcuMzUzMSA0LjE5OTAxIDYuOTc1OTQgNC4xOTkwMUM2LjczNzE5IDQuMTk5MDEgNi41MjU1MyA0LjI0NzczIDYuMzQwOTQgNC4zNDUxNkM2LjE1NjM2IDQuNDQyNjYgNS45OTcwMiA0LjU4OTQzIDUuODYyOTIgNC43ODU0N0M1Ljc4MzkgNC44OTcxNCA1LjY3ODI3IDQuOTYzMTEgNS41NDYwNSA0Ljk4MzM5QzUuNDEzOSA1LjAwMzczIDUuMjk4MzggNC45NzE0NCA1LjE5OTQ5IDQuODg2NTFDNS4xMjYzNiA0LjgyMjkgNS4wODQ1OSA0Ljc0MzE4IDUuMDc0MTcgNC42NDczNEM1LjA2Mzc2IDQuNTUxNDQgNS4wODYwNSA0LjQ2MDQ3IDUuMTQxMDUgNC4zNzQ0M0M1LjM1MjU4IDQuMDU0NSA1LjYxNDIxIDMuODExMiA1LjkyNTk0IDMuNjQ0NTNDNi4yMzc2MSAzLjQ3Nzg2IDYuNTg3NjEgMy4zOTQ1MyA2Ljk3NTk0IDMuMzk0NTNDNy41OTYxNSAzLjM5NDUzIDguMTAwOTggMy41NzIxNCA4LjQ5MDQyIDMuOTI3MzRDOC44Nzk4IDQuMjgyNTUgOS4wNzQ0OSA0Ljc0NTE2IDkuMDc0NDkgNS4zMTUxNkM5LjA3NDQ5IDUuNjE2OTYgOS4wMDk4NyA1Ljg5MzUyIDguODgwNjMgNi4xNDQ4NEM4Ljc1MTMzIDYuMzk2MjMgOC41MzA5OCA2LjY2NjY4IDguMjE5NTkgNi45NTYyQzcuOTI3OTIgNy4yMjA2NCA3LjcyODkzIDcuNDM1MjYgNy42MjI2MSA3LjYwMDA1QzcuNTE2MjkgNy43NjQ4NCA3LjQ1NDU5IDcuOTUwMDUgNy40Mzc1MSA4LjE1NTY4QzcuNDIwNDIgOC4yNzQyOSA3LjM3MTI5IDguMzczMTEgNy4yOTAxMSA4LjQ1MjE0QzcuMjA4ODYgOC41MzEyMyA3LjExMTA4IDguNTcwNzggNi45OTY3OCA4LjU3MDc4QzYuODgyNDcgOC41NzA3OCA2Ljc4NDczIDguNTMxNjUgNi43MDM1NSA4LjQ1MzM5QzYuNjIyMzcgOC4zNzUxMiA2LjU4MTc4IDguMjc4ODQgNi41ODE3OCA4LjE2NDUzQzYuNTgxNzggNy44ODU3MSA2LjY0NTQ2IDcuNjMwNzggNi43NzI4MiA3LjM5OTc0QzYuOTAwMjUgNy4xNjg3IDcuMTEzNTUgNi45MjAxNiA3LjQxMjcyIDYuNjU0MTJDNy43MzIxNiA2LjM3MzcgNy45NDg0OCA2LjEzOTcxIDguMDYxNjcgNS45NTIxNEM4LjE3NDk0IDUuNzY0NjQgOC4yMzE1NyA1LjU2MDg1IDguMjMxNTcgNS4zNDA3OFpNNi45NzU5NCAxMC45NTg2QzYuODA1NTMgMTAuOTU4NiA2LjY1ODc2IDEwLjg5NyA2LjUzNTYzIDEwLjc3MzlDNi40MTI1MSAxMC42NTA4IDYuMzUwOTQgMTAuNTA0IDYuMzUwOTQgMTAuMzMzNkM2LjM1MDk0IDEwLjE2MzIgNi40MTI1MSAxMC4wMTY0IDYuNTM1NjMgOS44OTMyOEM2LjY1ODc2IDkuNzcwMTYgNi44MDU1MyA5LjcwODU5IDYuOTc1OTQgOS43MDg1OUM3LjE0NjM2IDkuNzA4NTkgNy4yOTMxMyA5Ljc3MDE2IDcuNDE2MjYgOS44OTMyOEM3LjUzOTM4IDEwLjAxNjQgNy42MDA5NCAxMC4xNjMyIDcuNjAwOTQgMTAuMzMzNkM3LjYwMDk0IDEwLjUwNCA3LjUzOTM4IDEwLjY1MDggNy40MTYyNiAxMC43NzM5QzcuMjkzMTMgMTAuODk3IDcuMTQ2MzYgMTAuOTU4NiA2Ljk3NTk0IDEwLjk1ODZaIiBmaWxsPSJ3aGl0ZSIvPgo8L3N2Zz4K";
  const importantImageBase64 = "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTQiIGhlaWdodD0iMTQiIHZpZXdCb3g9IjAgMCAxNCAxNCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHJlY3Qgd2lkdGg9IjE0IiBoZWlnaHQ9IjE0IiByeD0iNyIgZmlsbD0iIzJCN0FCQyIvPgo8bWFzayBpZD0ibWFzazBfMTUzNzlfMzU4MyIgc3R5bGU9Im1hc2stdHlwZTphbHBoYSIgbWFza1VuaXRzPSJ1c2VyU3BhY2VPblVzZSIgeD0iMiIgeT0iMiIgd2lkdGg9IjEwIiBoZWlnaHQ9IjEwIj4KPHJlY3QgeD0iMiIgeT0iMiIgd2lkdGg9IjEwIiBoZWlnaHQ9IjEwIiBmaWxsPSIjRDlEOUQ5Ii8+CjwvbWFzaz4KPGcgbWFzaz0idXJsKCNtYXNrMF8xNTM3OV8zNTgzKSI+CjxwYXRoIGQ9Ik00LjkxNjUgNy4zMjAyVjEwLjY0NTVDNC45MTY1IDEwLjczNCA0Ljg4NjU0IDEwLjgwODMgNC44MjY2MSAxMC44NjgxQzQuNzY2NjggMTAuOTI4IDQuNjkyNDQgMTAuOTU4IDQuNjAzOSAxMC45NThDNC41MTUyOSAxMC45NTggNC40NDEwOSAxMC45MjggNC4zODEzIDEwLjg2ODFDNC4zMjE0MyAxMC44MDgzIDQuMjkxNSAxMC43MzQgNC4yOTE1IDEwLjY0NTVWMy44MzQ2N0M0LjI5MTUgMy43Mjc5NCA0LjMyNzYxIDMuNjM4NDkgNC4zOTk4NCAzLjU2NjM0QzQuNDcxOTkgMy40OTQxMiA0LjU2MTQzIDMuNDU4MDEgNC42NjgxNyAzLjQ1ODAxSDkuOTYyOTZDMTAuMDMxNCAzLjQ1ODAxIDEwLjA5MyAzLjQ3Mzg0IDEwLjE0NzggMy41MDU1MUMxMC4yMDI2IDMuNTM3MTEgMTAuMjQ2MiAzLjU3ODIyIDEwLjI3ODQgMy42Mjg4NEMxMC4zMTA2IDMuNjc5NDcgMTAuMzMwNiAzLjczNTc5IDEwLjMzODQgMy43OTc4QzEwLjM0NjEgMy44NTk3NCAxMC4zMzU3IDMuOTIyOTQgMTAuMzA3MiAzLjk4NzM4TDkuNjg4MTcgNS4zODkxNUwxMC4zMDcyIDYuNzkwODJDMTAuMzM1NyA2Ljg1NTI2IDEwLjM0NjEgNi45MTg0NiAxMC4zMzg0IDYuOTgwNEMxMC4zMzA2IDcuMDQyNDIgMTAuMzEwNiA3LjA5ODc0IDEwLjI3ODQgNy4xNDkzNkMxMC4yNDYyIDcuMTk5OTkgMTAuMjAyNiA3LjI0MTEgMTAuMTQ3OCA3LjI3MjdDMTAuMDkzIDcuMzA0MzYgMTAuMDMxNCA3LjMyMDIgOS45NjI5NiA3LjMyMDJINC45MTY1Wk00LjkxNjUgNi42OTUySDkuNTk2ODJMOS4xNDU2NyA1LjY5MzYzQzkuMTAxMzcgNS41OTg4NCA5LjA3OTIxIDUuNDk3MjggOS4wNzkyMSA1LjM4ODk1QzkuMDc5MjEgNS4yODA2MSA5LjEwMTM3IDUuMTc5MTUgOS4xNDU2NyA1LjA4NDU3TDkuNTk2ODIgNC4wODMwMUg0LjkxNjVWNi42OTUyWiIgZmlsbD0id2hpdGUiLz4KPC9nPgo8L3N2Zz4K";
  const image =  notebookTextSelection.backgroundColor == '#c71f2233' ? confusingImageBase64 : importantImageBase64
  span.style.setProperty('--badge-icon', `url(${image})`);
  span.style.setProperty('--border-color', notebookTextSelection.borderColor);
  span.style.setProperty('--background-color', notebookTextSelection.backgroundColor);

  span.onclick = () => notifyiOSOfHighlightTap(notebookTextSelection);

  const textNode = document.createTextNode(textContent);
  span.appendChild(textNode);

  return span;
};


/**
 * Applies highlights to the document based on an array of notebook text selections.
 * Clears existing highlights before applying new ones.
 * @param {Array<object>} highlights - An array of highlight objects, each with a 'range' and styling properties.
 */
function applyHighlights(highlights) {
    clearHighlights();
    highlights.forEach(addHighlight);
}

// --- End: dist/use_case/ApplyHighlights.js ---


// --- Start: dist/use_case/NotifyTextSelectionChange.js ---

/**
 * Registers an event listener for text selection changes and notifies iOS webkit message handlers.
 */
function registerNotifyOnTextSelectionChange() {
    document.addEventListener("selectionchange", async () => {
        const messageHandlers = window.webkit?.messageHandlers;
        if (!messageHandlers) {
            return;
        }

        const currentTextSelection = await getCurrentTextSelection();
        // Ensure the message handler exists before posting
        if (messageHandlers.notebookTextSelectionChange) {
            window.webkit.messageHandlers.notebookTextSelectionChange.postMessage(JSON.stringify(currentTextSelection));
        } else {
            console.warn("webkit.messageHandlers.notebookTextSelectionChange is not defined.");
        }
    });
}

// --- End: dist/use_case/NotifyTextSelectionChange.js ---


// --- Start: dist/main.js (Global Exposure) ---

// This file is just an interface. No implementation details here!
window.applyHighlights = applyHighlights;
window.getCurrentTextSelection = getCurrentTextSelection;
registerNotifyOnTextSelectionChange();

// --- End: dist/main.js ---
