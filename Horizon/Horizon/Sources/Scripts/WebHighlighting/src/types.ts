interface Window {
  applyHighlights: (highlights: [NotebookTextSelection]) => void;
  getCurrentTextSelection: () => NotebookTextSelection;
  scrollToHighlight: (notebookTextSelection: NotebookTextSelection) => void;
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
  borderStyle?: string;
  range: RangeSelector;
  selectedText: string;
  textPosition: TextPositionSelector;
};
