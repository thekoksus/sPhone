
	
		local buttonsInHome = {
			{"sPhone.header",23,1,25,1,sPhone.theme["header"],sPhone.theme["headerText"],"vvv"},
			{"sPhone.appsButton",12,20,14,20,sPhone.theme["backgroundColor"],sPhone.theme["header"],"==="},
			{"sPhone.shell",2,3,8,5,colors.black,colors.yellow," Shell",2},
			{"sPhone.lock",19,3,24,5,colors.lightGray,colors.black," Lock",2},
			{"sPhone.chat",11,3,16,5,colors.black,colors.white," Chat",2},
			{"sPhone.gps",11,7,15,9,colors.red,colors.black," GPS",2},
			{"sPhone.info",18,7,23,9,colors.lightGray,colors.black," Info",2},
			{"sPhone.store",2,7,8,9,colors.orange,colors.white," Store",2},
		}
		
		
		local appsOnHome = {
			["sPhone.shell"] = "/.sPhone/apps/shell",
			["sPhone.chat"] = "/.sPhone/apps/chat",
			["sPhone.gps"] = "/.sPhone/apps/gps",
			["sPhone.info"] = "/.sPhone/apps/system/info",
			["sPhone.store"] = "/.sPhone/apps/store",
			["sPhone.appsButton"] = "/.sPhone/apps/appList",
			
		}
		
		local function clear()
		term.setBackgroundColor(sPhone.theme["backgroundColor"])
		term.clear()
		term.setCursorPos(1,1)
		term.setTextColor(sPhone.theme["text"])
	end

		local function drawHome()
			local function box(x,y,text,bg,colorText,page)
				graphics.box(x,y,x+1+#text,y+2,bg)
				term.setCursorPos(x+1,y+1)
				term.setTextColor(colorText)
				write(text)
			end
			clear()
			
			
			visum.buttons(buttonsInHome,true)
			
			local w, h = term.getSize()
			paintutils.drawLine(1,1,w,1, sPhone.theme["header"])
			term.setTextColor(sPhone.theme["headerText"])
			visum.align("right","vvv ",false,1)
		end
		local function footerMenu()
			sPhone.isFooterMenuOpen = true
			function redraw()
				drawHome()
				local w, h = term.getSize()
				graphics.box(1,2,w,4,sPhone.theme["header"])
				term.setTextColor(sPhone.theme["headerText"])
				term.setBackgroundColor(sPhone.theme["header"])
				visum.align("right","^^^ ",false,1)
				visum.align("right", "Reboot ",false,3)
				term.setCursorPos(11,3)
				write("Settings")
				term.setCursorPos(2,3)
				write("Shutdown")
			end
			while true do
				term.redirect(sPhone.mainTerm)
				drawHome()
				redraw()
				local _,_,x,y = os.pullEvent("mouse_click")
				if y == 3 then
					if x > 1 and x < 10 then
						os.shutdown()
						sPhone.inHome = true
					elseif x > 19 and x < 26 then
						os.reboot()
						sPhone.inHome = true
					elseif x > 10 and x < 19 then
						sPhone.inHome = false
						shell.run("/.sPhone/apps/system/settings")
						sPhone.inHome = true
						drawHome()
					end
				elseif y == 1 then
					if x < 26 and x > 22 then
						sPhone.isFooterMenuOpen = false
						return
					end
				end
			end
		end
		local function buttonHomeLoop()
			while true do
				drawHome()
				term.setCursorBlink(false)
				local autoLockTimer = os.startTimer(10)
				local id = visum.buttons(buttonsInHome)
				
				if id == "sPhone.header" then
					footerMenu()
				elseif id == "sPhone.lock" then
					sPhone.inHome = false
					sPhone.login()
					sPhone.inHome = true
				elseif appsOnHome[id] then
					sPhone.inHome = false
					os.pullEvent = os.oldPullEvent
					shell.run(appsOnHome[id])
					os.pullEvent = os.pullEventRaw
					sPhone.inHome = true
				end
			end
		
			sPhone.inHome = false
		
		end
		
		local function updateClock()
			while true do
				if sPhone.inHome then
					term.setCursorPos(1,1)
					term.setBackgroundColor(sPhone.theme["header"])
					term.setTextColor(sPhone.theme["headerText"])
					term.setCursorPos(1,1)
					write("      ")
					term.setCursorPos(1,1)
					write(" "..textutils.formatTime(os.time(),true))
				end
				sleep(0)
			end
		end
		
		parallel.waitForAll(buttonHomeLoop, updateClock)
