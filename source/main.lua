-- VIDEO GALLERY
-- by John Polacek @ 2011
--
-- Version: 1.0
--
-- Git: https://github.com/johnpolacek/Video-Gallery
-- Blog: http://johnpolacek.com
-- Twitter: @johnpolacek


-- Background Width/Height/Alignment
local backgroundWidth = 1024
local backgroundHeight = 768
local backgroundAlignment = "center"

-- Scroll Nav spacing/margins
local spacing = 50
local leftMargin = 50
local topMargin = 100
local scrollbarY = 480

-- Load content
local content = require("content")

--import the scrollNav class
local scrollNav = require("scrollNav")

display.setStatusBar(display.HiddenStatusBar)

-- Background
local background = display.newImageRect("background.jpg", backgroundWidth, backgroundHeight)

-- Center background image
background.x = backgroundWidth / 2

-- Align background
local topMarginAdjust = 0
if (backgroundAlignment == "bottom") then
	topMarginAdjust = -(backgroundHeight - display.viewableContentHeight)
elseif (backgroundAlignment == "top") then
	topMarginAdjust = backgroundHeight - display.viewableContentHeight
end
background.y = (backgroundHeight / 2) + topMarginAdjust -((backgroundHeight - display.viewableContentHeight)/2)

-- Setup a scrollable content group
local scrollNav = scrollNav.new({left=0, right=0, tm=topMargin, lm=leftMargin, sp=spacing})

-- Iterate through content and add to scrollNav
for index, value in ipairs(content) do
    local thumb = display.newImage(content[index].thumb)
    scrollNav:insertButton(thumb, content[index].asset)
end

-- Add the scrollbar to the scrollNav
scrollNav:addScrollBar(scrollbarY)