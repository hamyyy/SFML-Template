set appName to system attribute "appName"
set appNameExt to appName & ".app"

tell application "Finder"
	tell disk appName
		open
		set current view of container window to icon view
		set toolbar visible of container window to false
		set statusbar visible of container window to false
		set the bounds of container window to {400, 100, 1060, 500}
		set viewOptions to the icon view options of container window
		set arrangement of viewOptions to not arranged
		set icon size of viewOptions to 128
		set background picture of viewOptions to file ".background:dmg-background.png"
		set position of item appNameExt of container window to {180, 170}
		set position of item "Applications" of container window to {480, 170}
		set position of item ".background" of container window to {180, 570}
		-- set position of item ".fseventsd" of container window to {480, 570}
		close
		update without registering applications
		delay 2
	end tell
end tell