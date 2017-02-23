return {
	height = 120,
	id = "ChatCell",
	ignoreAnchor = 1,
	localZOrder = 0,
	opacity = 255,
	rotation = 0,
	scaleX = 1,
	scaleY = 1,
	type = "ChatCell",
	visible = 0,
	width = "$fill",
	x = 140,
	y = 20,
	anchor = {
	   x = 0,
	   y = 0},
	color = {
	   b = 255,
	   g = 255,
	   r = 255},
	scaleSize = {
	   h = "$minScale",
	   w = 1},
	children = {	   {
	      height = "$fill",
	      id = "layerColor1",
	      ignoreAnchor = 0,
	      localZOrder = 0,
	      opacity = 255,
	      parentId = "ChatCell",
	      rotation = 0,
	      scaleX = 1,
	      scaleY = 1,
	      type = "cc.LayerColor",
	      visible = 0,
	      width = "$fill",
	      x = 0,
	      y = 0,
	      anchor = {
	         x = 0.5,
	         y = 0.5},
	      color = {
	         a = 255,
	         b = 255,
	         g = 255,
	         r = 255},
	      children = {	         {
	            height = 1,
	            id = "layerColor2",
	            ignoreAnchor = 0,
	            localZOrder = 0,
	            opacity = 255,
	            parentId = "layerColor1",
	            rotation = 0,
	            scaleX = 1,
	            scaleY = 1,
	            type = "cc.LayerColor",
	            visible = 0,
	            width = "$fill",
	            x = 0,
	            y = 0,
	            anchor = {
	               x = 0.5,
	               y = 0.5},
	            children = {},
	            color = {
	               a = 255,
	               b = 240,
	               g = 240,
	               r = 240},
	            scaleSize = {
	               h = "1",
	               w = 1}},
	         {
	            file = "main/default_hd_avatar.png",
	            flippedX = 1,
	            height = 80,
	            id = "sprite1",
	            ignoreAnchor = 1,
	            localZOrder = 0,
	            opacity = 255,
	            parentId = "layerColor1",
	            rotation = 0,
	            scaleX = "$minScale",
	            scaleY = "$minScale",
	            type = "cc.Sprite",
	            visible = 0,
	            width = 80,
	            x = 61,
	            y = 60,
	            anchor = {
	               x = 0.5,
	               y = 0.5},
	            children = {},
	            color = {
	               b = 255,
	               g = 255,
	               r = 255},
	            scaleXY = {
	               x = "$xScale",
	               y = "$yScale"}}}}}}