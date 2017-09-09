return {
	height = "$fill",
	id = "drawNodeTest1",
	type = "DrawNodeTest",
	width = "$fill",
	children = {	   {
	      angle = 0,
	      drawLineToCenter = 1,
	      id = "drawNodeCircle1",
	      radius = 80,
	      scaleX = "$minScale",
	      scaleY = "$minScale",
	      solid = 1,
	      type = "DrawNodeCircle",
	      x = 160,
	      y = 620,
	      scaleXY = {
	         x = "$scaleX",
	         y = "$scaleY"}},
	   {
	      curvesNum = 2,
	      id = "cubicBezierNode1",
	      lineWidth = 1,
	      scaleX = "$minScale",
	      scaleY = "$minScale",
	      type = "CubicBezierNode",
	      x = 300,
	      y = 620,
	      scaleXY = {
	         x = "$scaleX",
	         y = "$scaleY"},
	      destination = {	         {
	            c1 = {
	               x = 0,
	               y = -44},
	            c2 = {
	               x = 36,
	               y = -80},
	            dst = {
	               x = 80,
	               y = -80}},
	         {
	            c1 = {
	               x = 124,
	               y = -80},
	            c2 = {
	               x = 160,
	               y = -44},
	            dst = {
	               x = 160,
	               y = 0}}}},
	   {
	      borderWidth = 1,
	      id = "drawPolygon1",
	      scaleX = "$minScale",
	      scaleY = "$minScale",
	      type = "DrawPolygon",
	      x = 517,
	      y = 620,
	      c4f = {
	         a = 0.5,
	         b = 0,
	         g = 1,
	         r = 0},
	      fillColor = {
	         a = 0.2,
	         b = 0.5,
	         g = 0,
	         r = 0},
	      scaleXY = {
	         x = "$scaleX",
	         y = "$scaleY"},
	      points = {	         {
	            x = 0,
	            y = 0},
	         {
	            x = 50,
	            y = 50},
	         {
	            x = 100,
	            y = 50},
	         {
	            x = 150,
	            y = 0}}},
	   {
	      id = "drawCardinalSpline1",
	      pointsNum = 6,
	      scaleX = "$minScale",
	      scaleY = "$minScale",
	      segments = 100,
	      tension = 0.2,
	      type = "DrawCardinalSpline",
	      x = 706,
	      y = 620,
	      scaleXY = {
	         x = "$scaleX",
	         y = "$scaleY"},
	      points = {	         {
	            x = 0,
	            y = 0},
	         {
	            x = 50,
	            y = 50},
	         {
	            x = 100,
	            y = 0},
	         {
	            x = 150,
	            y = -50},
	         {
	            x = 200,
	            y = 0},
	         {
	            x = 250,
	            y = 50}}},
	   {
	      dot = 1,
	      id = "drawPoint1",
	      pointSize = 40,
	      scaleX = "$minScale",
	      scaleY = "$minScale",
	      type = "DrawPoint",
	      x = 1070,
	      y = 608,
	      scaleXY = {
	         x = "$scaleX",
	         y = "$scaleY"}},
	   {
	      id = "drawLine1",
	      scaleX = "$minScale",
	      scaleY = "$minScale",
	      segment = 1,
	      type = "DrawLine",
	      x = 160,
	      y = 234,
	      from = {
	         x = -40,
	         y = 0},
	      scaleXY = {
	         x = "$scaleX",
	         y = "$scaleY"},
	      to = {
	         x = 40,
	         y = 50}},
	   {
	      id = "drawLine2",
	      scaleX = "$minScale",
	      scaleY = "$minScale",
	      segment = 0,
	      type = "DrawLine",
	      x = 160,
	      y = 99,
	      from = {
	         x = -40,
	         y = 0},
	      scaleXY = {
	         x = "$scaleX",
	         y = "$scaleY"},
	      to = {
	         x = 40,
	         y = 50}},
	   {
	      angle = 0,
	      drawLineToCenter = 0,
	      id = "drawNodeCircle2",
	      radius = 80,
	      scaleX = "$minScale",
	      scaleY = "$minScale",
	      solid = 0,
	      type = "DrawNodeCircle",
	      x = 160,
	      y = 430,
	      c4f = {
	         a = 0.2,
	         b = 0,
	         g = 1,
	         r = 0},
	      scaleXY = {
	         x = "$scaleX",
	         y = "$scaleY"}},
	   {
	      borderWidth = 1,
	      id = "drawPolygon2",
	      pointsNum = 3,
	      scaleX = "$minScale",
	      scaleY = "$minScale",
	      type = "DrawPolygon",
	      x = 517,
	      y = 430,
	      c4f = {
	         a = 0.5,
	         b = 0,
	         g = 1,
	         r = 0},
	      fillColor = {
	         a = 0.2,
	         b = 0.5,
	         g = 0,
	         r = 0},
	      scaleXY = {
	         x = "$scaleX",
	         y = "$scaleY"},
	      points = {	         {
	            x = 0,
	            y = 0},
	         {
	            x = 50,
	            y = 60},
	         {
	            x = 100,
	            y = 0},
	         {
	            x = 150,
	            y = 0}}},
	   {
	      id = "drawCardinalSpline2",
	      pointsNum = 6,
	      scaleX = "$minScale",
	      scaleY = "$minScale",
	      segments = 100,
	      tension = 5,
	      type = "DrawCardinalSpline",
	      x = 706,
	      y = 430,
	      scaleXY = {
	         x = "$scaleX",
	         y = "$scaleY"},
	      points = {	         {
	            x = 0,
	            y = 0},
	         {
	            x = 50,
	            y = 50},
	         {
	            x = 100,
	            y = 0},
	         {
	            x = 150,
	            y = -50},
	         {
	            x = 200,
	            y = 0},
	         {
	            x = 250,
	            y = 50}}},
	   {
	      dot = 0,
	      id = "drawPoint2",
	      pointSize = 40,
	      scaleX = "$minScale",
	      scaleY = "$minScale",
	      type = "DrawPoint",
	      x = 1070,
	      y = 430,
	      scaleXY = {
	         x = "$scaleX",
	         y = "$scaleY"}},
	   {
	      borderWidth = 1,
	      id = "drawPolygon3",
	      pointsNum = 5,
	      scaleX = "$minScale",
	      scaleY = "$minScale",
	      type = "DrawPolygon",
	      x = 516,
	      y = 234,
	      c4f = {
	         a = 0.5,
	         b = 0,
	         g = 1,
	         r = 0},
	      fillColor = {
	         a = 0,
	         b = 0.5,
	         g = 0,
	         r = 0},
	      scaleXY = {
	         x = "$scaleX",
	         y = "$scaleY"},
	      points = {	         {
	            x = 0,
	            y = 0},
	         {
	            x = 150,
	            y = 0},
	         {
	            x = 25,
	            y = -100},
	         {
	            x = 75,
	            y = 50},
	         {
	            x = 125,
	            y = -100}}}}}