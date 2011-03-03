-- SCROLL NAV
-- by John Polacek @ 2011
--
-- Based on ScrollView sample from AnscaMobile
--
-- Version: 1.0
--
-- Git: https://github.com/johnpolacek/Video-Gallery
-- Blog: http://johnpolacek.com
-- Twitter: @johnpolacek

 
module(..., package.seeall)

-- set values for width and height of the screen
local screenW, screenH = display.contentWidth, display.contentHeight
local viewableScreenW, viewableScreenH = display.viewableContentWidth, display.viewableContentHeight
local screenOffsetW = display.contentWidth - display.viewableContentWidth
local screenOffsetH = display.contentHeight - display.viewableContentHeight

local prevTime = 0
local xPos
local leftMargin
local topMargin
local bottomMargin
local spacing
local contentMatrix = {}
local scrollBackground


function new(params)

	-- setup a group to be the scrolling screen
	local scrollNav = display.newGroup()
	
	-- Add transparent background to the scroll view for a full screen hit area
	scrollBackground = display.newRect(0, 0, display.contentWidth, display.contentHeight)
	scrollBackground:setFillColor(255, 255, 255, 0)
	scrollNav:insert(scrollBackground)
	
	scrollNav.left = params.left or 0
	scrollNav.right = params.right or 0
	topMargin = params.tm or 40
	leftMargin = params.lm or 40
	spacing = params.sp or 30
	xPos = leftMargin
	scrollNav.x = scrollNav.left
	
	-- setup the touch listener 
	scrollNav:addEventListener("touch", scrollNav)
	
	------------------------------------------------------------
	-- EVENT HANDLERS
	
	function scrollNav:touch(event) 
	        local phase = event.phase      
	        			        
	        if(phase == "began") then
				
	                self.startPos = event.x
	                self.prevPos = event.x                                       
	                self.delta, self.velocity = 0, 0
	                if self.tween then transition.cancel(self.tween) end

	                Runtime:removeEventListener("enterFrame", scrollNav) 

					self.prevTime = 0
					self.prevX = 0

					transition.to(self.scrollBar,  { time=200, alpha=1 })									

					-- Start tracking velocity
					Runtime:addEventListener("enterFrame", trackVelocity)
	                
	                -- Subsequent touch events will target button even if they are outside the contentBounds of button
	                display.getCurrentStage():setFocus(self)
	                self.isFocus = true
	 
	        elseif(self.isFocus) then
	 
	                if(phase == "moved") then     
					        local rightLimit = screenW - self.width - self.right
					        
	            			self.moved = true
	                        self.delta = event.x - self.prevPos
	                        self.prevPos = event.x
	                        if (self.x > self.left or self.x < rightLimit) then 
                                self.x  = self.x + self.delta/2
	                        else
                                self.x = self.x + self.delta   
	                        end
	                        
	                        scrollNav:moveScrollBar()

	                elseif(phase == "ended" or phase == "cancelled") then 
	                        local dragDistance = event.x - self.startPos
							self.lastTime = event.time
	                        
	                        Runtime:addEventListener("enterFrame", scrollNav)  	 			
	                        Runtime:removeEventListener("enterFrame", trackVelocity)
	        	                	        
	                        -- Allow touch events to be sent normally to the objects they "hit"
	                        display.getCurrentStage():setFocus(nil)
	                        self.isFocus = false
	                        
	                        -- check if touch instance is a drag or a touch to open content
	                        if (dragDistance < 10 and dragDistance > -10 and event.y > topMargin and event.y < bottomMargin) then
	                        	getContent(event.x)
	                        end
	                end
	        end
	        
	        return true
	end
	 
	function scrollNav:enterFrame(event)   
		local friction = 0.9
		local timePassed = event.time - self.lastTime
		self.lastTime = self.lastTime + timePassed       

        --turn off scrolling if velocity is near zero
        if math.abs(self.velocity) < .01 then
                self.velocity = 0
	            Runtime:removeEventListener("enterFrame", scrollNav)          
				transition.to(self.scrollBar,  { time=400, alpha=0 })									
        end       

        self.velocity = self.velocity * friction
        
        self.x = math.floor(self.x + self.velocity * timePassed)
        
        local leftLimit = self.left 
	    local rightLimit = screenW - self.width
        
        if (self.x > leftLimit) then
                self.velocity = 0
                Runtime:removeEventListener("enterFrame", scrollNav)          
                self.tween = transition.to(self, { time=400, x=leftLimit, transition=easing.outQuad})
				transition.to(self.scrollBar,  { time=400, alpha=0 })									
        elseif (self.x < rightLimit and rightLimit < 0) then 
                self.velocity = 0
                Runtime:removeEventListener("enterFrame", scrollNav)          
                self.tween = transition.to(self, { time=400, x=rightLimit, transition=easing.outQuad})
				transition.to(self.scrollBar,  { time=400, alpha=0 })									
        elseif (self.x < rightLimit) then 
                self.velocity = 0
                Runtime:removeEventListener("enterFrame", scrollNav)          
                self.tween = transition.to(self, { time=400, x=leftLimit, transition=easing.outQuad})        
				transition.to(self.scrollBar,  { time=400, alpha=0 })									
        end 

        scrollNav:moveScrollBar()
        	        
	    return true
	end

	function trackVelocity(event) 	
		local timePassed = event.time - scrollNav.prevTime
		scrollNav.prevTime = scrollNav.prevTime + timePassed
	
		if scrollNav.prevX then 
			scrollNav.velocity = (scrollNav.x - scrollNav.prevX) / timePassed 
		end
		scrollNav.prevX = scrollNav.x
	end			
	
	function getContent(touchX)
		buttonIndex = 0
		for index, value in ipairs(contentMatrix) do
			local leftX = contentMatrix[index].leftBound + scrollNav.x
			local rightX = contentMatrix[index].rightBound + scrollNav.x
			if (touchX > leftX and touchX < rightX) then
				buttonIndex = index
			end
		end
		if (buttonIndex > 0) then
			showContent(contentMatrix[buttonIndex].content)
		end
	end
	
	function showContent(content)
		print("showContent: "..content)
		media.playVideo(content, true)
	end
	
	
	------------------------------------------------------------
	-- CLASS FUNCTIONS
	
	function scrollNav:insertButton(button, c)
		button.x = xPos + (button.width / 2)
   		button.y = (button.height / 2) + topMargin
   		bottomMargin = topMargin + button.height
   		xPos = button.x + spacing + (button.width / 2)
   		buttonL = button.x - (button.width / 2)
   		buttonR = button.x + (button.width / 2)
   		t = {leftBound = buttonL, rightBound = buttonR, content = c}
   		table.insert(contentMatrix, t)
		self:insert(button)
		scrollBackground.width = buttonR + spacing
		scrollBackground.x = scrollBackground.width / 2
	end
	
	function scrollNav:moveScrollBar()
		if self.scrollBar then						
			local scrollBar = self.scrollBar
			
			scrollBar.x = -self.x * self.xRatio + scrollBar.width * 0.5 + self.left
			
			if scrollBar.x <  5 + self.left + scrollBar.width * 0.5 then
				scrollBar.x = 5 + self.left + scrollBar.width * 0.5
			end
			if scrollBar.x > screenW - self.right  - 5 - scrollBar.width * 0.5 then
				scrollBar.x = screenW - self.right - 5 - scrollBar.width * 0.5
			end
			
		end
	end
	
	function scrollNav:addScrollBar(scrollbarY, r, g, b, a)
		if self.scrollBar then self.scrollBar:removeSelf() end

		local scrollColorR = r or 122
		local scrollColorG = g or 122
		local scrollColorB = b or 122
		local scrollColorA = a or 120
						
		local viewPortW = screenW - self.left - self.right 
		local scrollW = viewPortW * self.width / (self.width * 2 - viewPortW)		
		local scrollBar = display.newRoundedRect(0, self.height + 6, scrollW, 5, 2)
		scrollBar:setFillColor(scrollColorR, scrollColorG, scrollColorB, scrollColorA)

		local xRatio = scrollW / self.width
		self.xRatio = xRatio		

		scrollBar.x = scrollBar.width * 0.5 + self.left
		scrollBar.y = scrollbarY or viewableScreenH - 10

		self.scrollBar = scrollBar

		transition.to(scrollBar,  {time=400, alpha=0})			
	end

	function scrollNav:removeScrollBar()
		if self.scrollBar then 
			self.scrollBar:removeSelf() 
			self.scrollBar = nil
		end
	end
	
	function scrollNav:cleanUp()
        Runtime:removeEventListener("enterFrame", trackVelocity)
		Runtime:removeEventListener("touch", scrollNav)
		Runtime:removeEventListener("enterFrame", scrollNav) 
		scrollNav:removeScrollBar()
	end
	
	------------------------------------------------------------
	-- RETURN SCROLLNAV OBJECT
	
	return scrollNav
	
end
