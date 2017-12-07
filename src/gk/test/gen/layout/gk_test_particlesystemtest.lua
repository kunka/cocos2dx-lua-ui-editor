return {
	_fold = false,
	_id = "particleSystemTest1",
	_type = "ParticleSystemTest",
	height = "$fill",
	width = "$fill",
	_children = {	   {
	      _fold = false,
	      _id = "sprite1",
	      _type = "cc.Sprite",
	      scaleX = "$minScale",
	      scaleY = "$minScale",
	      x = 185,
	      y = 150,
	      scaleXY = {
	         x = "$scaleX",
	         y = "$scaleY"},
	      _children = {	         {
	            _id = "particleSystemQuad1",
	            _type = "cc.ParticleSystemQuad",
	            height = 0,
	            particle = "gk/res/particle/Galaxy.plist",
	            positionType = 1,
	            width = 0,
	            x = 50,
	            y = 77}}},
	   {
	      _id = "particleSystemQuad2",
	      _type = "cc.ParticleSystemQuad",
	      emitterMode = 0,
	      height = 0,
	      particle = "gk/res/particle/Galaxy.plist",
	      positionType = 0,
	      scaleX = "$minScale",
	      scaleY = "$minScale",
	      totalParticles = 934,
	      width = 0,
	      x = 640,
	      y = 150,
	      blendFunc = {
	         dst = 1,
	         src = 770},
	      scaleXY = {
	         x = "$scaleX",
	         y = "$scaleY"}},
	   {
	      _id = "particleSystemQuad3",
	      _type = "cc.ParticleSystemQuad",
	      angle = 90,
	      angleVar = 360,
	      autoRemoveOnFinish = 1,
	      displayFrame = "particle.png",
	      duration = -1,
	      emitterMode = 0,
	      endSize = 37,
	      height = 0,
	      life = 4,
	      lifeVar = 1,
	      particle = "",
	      positionType = 0,
	      radialAccel = -20,
	      scaleX = "$minScale",
	      scaleY = "$minScale",
	      speed = 59,
	      speedVar = 10,
	      startSize = 37,
	      startSizeVar = 10,
	      startSpin = 0,
	      tangentialAccel = 50,
	      tangentialAccelVar = 50,
	      totalParticles = 500,
	      width = 0,
	      x = 1000,
	      y = 384,
	      blendFunc = {
	         dst = 1,
	         src = 770},
	      endColor = {
	         a = 1,
	         b = 0,
	         g = 1,
	         r = 0},
	      gravity = {
	         x = 150,
	         y = -300},
	      scaleXY = {
	         x = "$scaleX",
	         y = "$scaleY"},
	      startColor = {
	         a = 1,
	         b = 0.76,
	         g = 0.25,
	         r = 0}}}}