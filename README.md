# cocos2dx-lua-ui-editor
A lightweight ui editor for cocos2d-x-lua implemented by pure lua code, less than 10000 lines of code.

### LabelTest
![alt tag](snapshots/ss1.png)
### TableViewTest on ScreenSize 1280x720
![alt tag](snapshots/ss2.png)
### TableViewTest on ScreenSize 1280x960
![alt tag](snapshots/ss3.png)

## Features
 * No dependency except cocos2d-x-lua lib (Tested on 3.15).
 * Instance Run&Edit on Mac, F1:EditMode, F2:ReleaseMode(Editing node), F3:ReleaseMode, Hot deploy on Android Device.
 * Support almost all cocos2d-x nodes and lots of custom nodes.
 * 4 root containers: gk.Layer, gk.Dialog, gk.Widget, gk.TableViewCell.
 * Completely compatible with ui created by code.
 * Layout files are generated as lua code, no parser.
 * Screen adapt policy: FIXED_WIDTH, FIXED_HEIGHT, UNIVERSAL(Scale coordinates and nodes separately), support iPhoneX.
 * FSM Editor;
  
 ## How to use
 1. Create an empty lua-project by cocos2d-x 3.15.
 2. Copy "gk/" dir to "src/".
 3. Init gamekit correctly.
 4. Build app and run by Xcode, then you can directly run use "runtime/mac/&lt;youapp&gt;.app".

 ## TODO
 * Dynamic inflate nodes when needed :)
 * 3D support, but the cocos3D is too weak :(
 * Document. 
