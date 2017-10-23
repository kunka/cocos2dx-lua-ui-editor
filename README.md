# cocos2dx-lua-ui-editor
a lightweight ui generator for cocos2d-x-lua implemented by pure lua code, less than 10000 lines of code.

![alt tag](snapshots/ss1.png)

## Features
 * No dependency except cocos2d-x lib (Tested on 3.15).
 * Instance run&edit on Mac(F1:EditMode, F2:ReleaseMode(current), F3:ReleaseMode), hot deploy on Android Device.
 * Support almost all cocos2d-x nodes and lots of custom nodes.
 * 4 root container: gk.Layer, gk.Dialog, gk.Widget, gk.TableViewCell.
 * Compatible with ui created by code.
 * Layout files are generated as lua code, no parser.
 * Screen adaption policy: FIXED_WIDTH, FIXED_HEIGHT, UNIVERSAL(scale coordinates and nodes).
 
 ## TODO(Not Support now)
 * Dynamic inflate nodes when needed :)
 
 ## How to use
 1. Create an empty lua-project by cocos2d-x 3.15
 2. Copy "gk/" dir to "src/"
 3. Init gamekit
 4. Build app and run by Xcode, then you can directly run use "runtime/mac/<youapp>.app"
 
 #### Notice:
  * io.popen may crash when run by Xcode :(
  
