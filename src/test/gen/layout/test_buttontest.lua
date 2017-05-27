return {
	enableKeyPad = 1,
	height = "$fill",
	id = "ButtonTest",
	ignoreAnchor = 0,
	popOnBack = 1,
	swallowTouchEvent = 0,
	type = "ButtonTest",
	width = "$fill",
	x = 240,
	y = 100,
	color = {
	   b = 255,
	   g = 255,
	   r = 255},
	children = {	   {
	      cascadeColorEnabled = 0,
	      cascadeOpacityEnabled = 0,
	      enabled = 0,
	      file = "?",
	      height = 150,
	      id = "button1",
	      ignoreAnchor = 1,
	      onClicked = "-",
	      parentId = "ButtonTest",
	      scaleX = "$minScale",
	      scaleY = "$minScale",
	      type = "ZoomButton",
	      width = 108,
	      x = 567,
	      y = 149,
	      zoomScale = 0.904,
	      color = {
	         b = 255,
	         g = 255,
	         r = 255},
	      scaleXY = {
	         x = "$scaleX",
	         y = "$scaleY"}},
	   {
	      cascadeColorEnabled = 0,
	      cascadeOpacityEnabled = 0,
	      disabledSprite = "disabled.png",
	      enabled = 0,
	      height = 78,
	      id = "spriteButton",
	      ignoreAnchor = 1,
	      normalSprite = "normal.png",
	      onClicked = "&onSpriteButtonClicked",
	      parentId = "ButtonTest",
	      scaleX = "$minScale",
	      scaleY = "$minScale",
	      selectedSprite = "selected.png",
	      type = "SpriteButton",
	      width = 350,
	      x = 525,
	      y = 557,
	      color = {
	         b = 255,
	         g = 255,
	         r = 255},
	      scaleXY = {
	         x = "$scaleX",
	         y = "$scaleY"}}}}