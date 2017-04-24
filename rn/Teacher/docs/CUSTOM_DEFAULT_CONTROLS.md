# Custom Default Controls

There exist a few custom elements that can be used in a component.  By using these components you get the proper font family and font size for the app.  These settings can then be changed in fewer places.  Try to use these instead of the default `ReactNative` controls.

### text.js
---

#### &LT;Text&GT;
##### style 
- `fontSize: `  default is 16
- `fontWeight: ` The following font weights are supported:
	
	``` 
	300 / normal = (SFUIDisplay) // this is default and you do not need to specify this
	500 = medium (SFUIDisplay-medium)
	600 = semi-bold (SFUIDisplay-semibold)
	700 = bold (SFUIDisplay-bold)
	```
	

#### &LT;Heading1&GT;
####  &LT;Heading2&GT;
####  &LT;TextInput&GT;
####  &LT;ModalActivityIndicatorAlertText&GT;

### buttons.js 
---
These buttons use the proper font and font size for anything button related.
#### &LT;Button&GT;
#### &LT;LinkButton&GT;
