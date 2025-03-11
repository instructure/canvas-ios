interface Window {
  applyHighlights: (highlights: [NotebookTextSelection]) => void;
  getCurrentTextSelection: () => NotebookTextSelection;
  notifyTextSelectionChange: () => void;
  webkit?: any;
}

type RangeSelector = {
  startContainer: string;
  endContainer: string;
  startOffset: number;
  endOffset: number;
};

type TextPositionSelector = {
  start: number;
  end: number;
};

type NotebookTextSelection = {
  backgroundColor?: string;
  borderColor?: string;
  range: RangeSelector;
  selectedText: string;
  textPosition: TextPositionSelector;
};
