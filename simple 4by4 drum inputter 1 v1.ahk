#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
;IMPORTANT NOTE: originally this script had the below line, "SendMode Input", commented out... but this didn't work with holding alt and using mouseclickdrag function to change velocity of notes... so sendmode input line has been uncommented.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
;commented-out 'SendMode Input' caus afaik drawing to GIMP's screen with mouse macros etc. it worked without sendmode input here. maybe activate this line again when GIMP is replaced with Gdip.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#SingleInstance Force
SetBatchLines, -1		;what does this do?

SetKeyDelay, -1			;read manual about this. using 0 here instead of -1 might be more stable.

coordmode, mouse, screen
coordmode, tooltip, screen

; Uncomment if Gdip.ahk is not in your standard library
;#Include, Gdip.ahk

/*
ableton shortcut keypresses:
- show/hide browser															ctrl-alt-b
- change track width 			with track/s selected:						alt =  OR  alt -
- hide/show detail view														ctrl-alt-l
- optimize arrangement width	with qwerty-keyboard midi input off			w [if you press again, looks like it cycles between the horizontal zoom and position you were at and the 'optimal' arrangement width zoom and position.]
- optimize arrangement height												h [if you press again, looks like it cycles between the vertical zoom and position you were at and the 'optimal' arrangement height zoom and position.]
*/

/*

NOTES:
- sending alt= shortcut to any ableton track/s makes it/them the maximum height, which is 1 track width + 25 track widths = 26 track widths total. likewise, sending 25 alt- shortcuts to any max-height ableton track/s makes all those track/s 1 width high (from 26 widths down to 1 width high).
- with ableton in fullscreen mode on this screen (1920 by 1080 i think), and an ableton track at full 26 widths of height [1 trackheight + 25 presses of alt= shortcut..], the automation area is 531 possible pixels of height. this is like 1-531: endpoints included, or 0-530: endpoints included [i think...].
- there seems to be a glitch with M4L Device - Dead Simple Global Transpose, where if you duplicate a track that has this M4L Device on it, the duplicated track's instance of the plugin/knob will not be responsive. at some point it might become responsive again, dont know.
	- probably don't duplicate tracks with this plugin, or have a macro that removes the plugin, then duplicates the track, then puts the plugin on the duplicated track.
- since clipwait isn't working with ableton unless you de-activate the ableton window [only way ive found so far is with "send, !{esc}"]... it looks like ableton consistently takes either 31/47ms to load something into the clipboard when copying something, "send, !{esc}"'ing the ableton window and measuring 'A_TickCount' differences. so maybe a sleep of ~60ms will always do the same thing that 'clipwait' would do (with very low chance of it taking longer than this and creating a bug(?)).
- looks like the default for simpler is to have 'Snap' setting on. This setting being on can remove a lot of the tail of certain samples, so need to turn it off. once it's turned off for a certain track, if you replace it with another sample using ableton's Hotswap mode, the snap will still be OFF. if you don't use hotswap mode to replace the sample, im guessing a new instance of Simpler is loaded, and the 'Snap' setting will be back ON. So use the Hotswap mode to randomize/change samples... otherwise have to turn off the 'Snap' setting each time (or look at saving some type of default Simpler settings that override this behaviour).
- atm there's 2 blank tracks at the top:
	- the first blank track has a long blank midiclip in it from barline 1 to barline 65.
	- the second blank track has two 4bar midi clips in it:
		- THE 1ST MIDI CLIP:
			- the 1st midi clip is from barline 1 to barline 5. this midi clip has 2 notes in it:
			- a note at B7, one 16th long, from barline -1.4.3 to -1.4.4
			- a note at A-1, one 16th long, from barline -1.4.3 to -1.4.4
			- [this midiclip is also on the A minor scale, with the 'Scale' button (button next to 'Fold' button) clicked ON]. the horizontal zoom is set to be from barline 1 to barline 5. then fullscreen mode is turned on, and the vertical zoom is done by double clicking in the vertical-zoom-area so that the 2 notes mentioned above set the vertical-zoom-level.
		- THE 2ND MIDI CLIP:
			- the 2nd midi clip is from barline 5 to barline 9. this midi clip has 2 notes in it:
			- a note at F5, one 16th long, from barline -1.4.3 to -1.4.4
			- a note at F#0, one 16th long, from barline -1.4.3 to -1.4.4
			- [this midiclip has no scale or fold mode turned on]. the horizontal zoom is set to be from barline 1 to barline 5. then fullscreen mode is turned on, and the vertical zoom is done by double clicking in the vertical-zoom-area so that the 2 notes mentioned above set the vertical-zoom-level.


new NOTES on how to use ableton with this system:
- in ableton, when renaming a track, putting '# ' as the first character will make the track number appear as the first character/s with a space, then whatever you name it after.
- need to lower the 'Preview Volume' to -15dB. this slider can be found on the Master Track in Arrangement View, next to the Master Track 'Track Volume' slider.
- put all single-shot-audio-files on audio tracks. color ALL of these audio tracks YELLOW. always have these tracks at volume 0dB. then to get different volumes for each audio sample, double click the audio sample in the arrangement view timeline and drag down the 'Gain' slider until that sample is at the desired volume.[THE THING ABOUT THIS NOTE IS YOU HAVE TO REMEMBER THAT WHEN YOU CTRL-A TO SELECT ALL TRACKS TO CHANGE VOLUME OF MULTIPLE TRACKS AT ONCE, YOU HAVE TO THEN DE-SELECT ALL OF THESE YELLOW AUDIO TRACKS. dont know if theres a better way to do this so that ctrl-a can be used in a simpler way than this...]

;NOTE:
;these 2 lines appear everywhere and probably should be built into a function/built into functions and removed:
;currentInputLayer := "mainLayer"
;gosub, drawMainLayerIndicator
;not sure if those 2 lines always work as intended, and not sure how they will work if there are multiple different 'main' layers for different purposes, e.g. triplet-inputting or EQ-parameter-inputting or synthesizer-plugin-parameter-editing.

;NOTE:
;this line is probably missing in a couple of places, probably especially places where gosub's or macros are called NOT by 126options-type-chains:
;tooltip		;get rid of any tooltip, so that mouse macros dont click on tooltip
;its the line to get rid of tooltips from screen, so that macro's don't click on the tooltip, instead of clicking through to the ableton window.
;probably have now added it in all the places it's needed atm. might forget to add it to future functions though. so leaving this comment block here. if macros arent sending to ableton window properly on rare occasions, it might be because of tooltips blocking mouseclick macros.

;NOTE:
;probably have to turn off 'snap' in ableton sampler for reverse cymbals. caus it cuts off the very end of the reverse sample, the loudest bit.
;might have to turn off 'snap' in ableton sampler for other types of samples as well, not just reverse cymbals.
/*
things to add:
- change instruments
- triplet inputting and showing something onscreen when triplet inputting is activated.
- 'velocity' abilities for FX such as distortion amount, overdrive amount, maybe even EQ settings.
	- other options: reverb amount, delay volume, phase-flanger dry-wet.
- shift velocity of multiple notes with curve. have parameters to define the curve shape(?).
- save/load
	- generate random filename
		- options to pick new filename/go back to previously suggested filenames
- system volume changing/mixer sliders
- randomize options
	- insert random note?
	- insert random chord?
	- insert random 2notes?
- pasting chords?
*/

; Start gdi+
If !pToken := Gdip_Startup()
{
	MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
	ExitApp
}
OnExit, Exit

;*********************************************
;initializing vars:

; Set the width and height we want as our drawing area, to draw everything in. This will be the dimensions of our bitmap
gdipWidth := 1920
gdipHeight := 1080		; screen resolution probably

;took this out caus it needs to go inside function/gosub instead(???):
;isNoteLengthValid := 0			;this doesn't probably work properly, in at least one place.

suspendVal := 0		;using this so i can leave the script running and this toggles some gdip stuff on/off.

multvar := 0		; this is for verifying that the 126option chain input is a valid option with 1st and 3rd press being valid. 2nd press, i think, is always valid so long as its any value between 1 and 6, endpoints included.

areInputsValid := 0			;this needed/used still?

qwertyOrErgo := 0		;starts on ergo by default, atm.

isAutoVelocityOn := 1			;0 = off, 1 = on.
autoVelocityVal := 100

notTripletOrTriplet := 0			;starts off as not-triplet: 0 is not-triplet, 1 is triplet.
in4BarSectionOrNot := 0				;starts off in 4bar section.

	;initializing these 3 vars, so they can be used in executing macro functions.
yToClick := 0
xToClick := 0
velocityToInput := 0

whatIsCurrentAbletonView := "fourBarMidiClip"

whichMainLayerIndicator := 0
;0 = 4 bar midi clip 64options
;1 = 4 bar midi clip 48options
;2 = arrangement view

startPositionOfLastInputtedNoteInMidiClip64thNumberX := 1 		;initialized as 1, so that if the function that uses this variable is run before inputting ANY notes, function will play from the first 64th in the current 4bar midi clip.
/*
NOTES:
using these m4l devices:
- ntpd2
- dead simple global transpose
*/
;****************************************************************************************************************************
;****************************************************************************************************************************
;****************************************************************************************************************************
/*
numberOfMillisecondsToReversedSoundPeak := 			;get this value by writing macro that does ctrl-r on the sample filename(?)
currentProjectBPM := ;get BPM of track by sending ctrl-c macro to m4l device NTPD2, on master track.
;input a barNumber and 16thNumber you want to line the reversed sound peak up with.
amountOfTimePer16thInMilliseconds := (60 / (currentProjectBPM * 4)) * 1000			;this value will be, for example, ~136.xxxx ms per 16th at 110bpm.
*/
/*
notes for gdip gui:
can probably have everything on one gui, and just draw/delete things from that one gui when needed?
*/
;NOTES for getting ableton coords:
; - make sure ableton is in fullscreen mode.
; - make sure 'Overview' mode is disabled in 'View->Overview'.
; - make sure 'Track Delay' side panel on the far-right of the screen is open.

/*
NOTES FOR USING THIS SYSTEM:
- make sure "Track Delay" side panel on the far-right of the screen is open.
*/

newNumberOfPixelsX := 64
;58 does all the notes of the piano fixed-in-key with key-switching and input always the same finger combinations for each physical screen position:
newNumberOfPixelsY := 58

amountOfXCells := 64		;change this variable value to 48 when needed.

;all these coords are for fullscreen ableton:
;coordinates for MIDI clip things:
abletonMidiClipCoordToOpenSidePanelX := 24
abletonMidiClipCoordToOpenSidePanelY := 200
abletonMidiClipCoordToDoubleNotesX := 169
abletonMidiClipCoordToHalveNotesX := 74
abletonMidiClipCoordToHalveOrDoubleNotesY := 393
abletonMidiClipCoordToCloseSidePanelX := 121
abletonMidiClipCoordToCloseSidePanelY := 69
abletonMidiClipCoordToZoomHorizontallyX := 843
abletonMidiClipCoordToZoomHorizontallyY := 68
pixelCoordOfFirstBarlineInMidiClip4BarSectionX := 163	;these ones have different names, should rename all these so they all have similar naming convention.
pixelCoordOfLastBarlineInMidiClip4BarSectionX := 1904
pixelCoordOfRowJustAboveMidiClipY := 118
newBottomPixel := 1011			;should rename these two.
newTopPixel := 144

;coordinates for arrangement view things:
abletonTrackNamesX := 1499
abletonMiddleOfTrack1Y := 125
abletonMiddleOfMasterTrackDeviceViewClosedY := 1001
abletonMiddleOfMasterTrackDeviceViewOpenY := 746
abletonYDistanceBetweenTracksAtSmallestHeightInPixels := 23.74285714
abletonCoordToZoomArrangementViewHorizontallyX := 648
abletonCoordToZoomArrangementViewHorizontallyY := 63
abletonCoordTriangleToOpenLeftBrowserPanelX := 21
abletonCoordTriangleToOpenLeftBrowserPanelY := 56
abletonCoordToOpenMainSamplesFolderX := 30
abletonCoordToOpenMainSamplesFolderY := 659
abletonCoordForTrackVolumeX := 1688

;ableton top row button coords/blank space to place cursor utility:
abletonCoordToClickBPMSetterX := 129
abletonCoordToClickMetronomeX := 277
abletonCoordToClickBlankSpaceToPlaceCursorX := 485			;use 'abletonTopRowButtonsY' as the Y value, when using this coord in macros.
abletonCoordToClickPlayButtonX := 751
abletonCoordToClickStopButtonX := 782
abletonCoordToClickToggleLoopOnOff := 1135
abletonCoordToClickTopRowButtonsY := 22

;ableton bottom row coords:
abletonCoordToClickBottomRowY := 1058
abletonCoordToClickBottomRowDeviceViewSelectorX := 1838
abletonCoordToClickBottomRowBottomRightTriangleX := 1898
	;these two are for pixelgetcolor function:
	abletonBottomRightTriangleChangingPartX := 1894
	abletonBottomRightTriangleChangingPartY := 1061

;ableton device view coords:
abletonCoordToHotswapSimplerSampleX := 908
abletonCoordToHotswapSimplerSampleY := 924
abletonCoordToClickDeadSimpleGlobalTransposeKnobX := 97
abletonCoordToClickDeadSimpleGlobalTransposeKnobY := 886
abletonCoordToClickTransposeSimplerClick1X := 819
abletonCoordToClickTransposeSimplerClick1Y := 802
abletonCoordToClickTransposeSimplerClick2X := 808
abletonCoordToClickTransposeSimplerClick2Y := 948
abletonCoordToClickTransposeSimplerClick3X := 750
abletonCoordToClickTransposeSimplerClick3Y := 803

;other values:
sleepAmountForInputtingAndDuplicatingNotes := 30			;think this has failed once on 2ms in brief testing. 5ms should do it.
sleepAmountForAbletonBrowser := 500			;100ms is about the lowest value thats working consistently for this value atm [testing on multiple instrument randomizations in one macro]. 85ms failed at least once. so 100ms is good value for this for now.
numberOfDownArrowsForAbletonBrowserToDo := 0
abletonOpenDeviceViewSleep := 10			;10ms atm. this could probably be lowered to ~5ms or lower(?). or does it sometimes randomly fail even at 10ms?

;values that aren't good because no way of ensuring they're consistent with current ableton project(?):
currentTrackHeightInPixels := abletonYDistanceBetweenTracksAtSmallestHeightInPixels * 2

;temp values:
tempLocationToOpen4BarMidiClipX := 983
tempC3ValueForDrumsY := 569
tempLocationToProbablyClickArrangementLoopBraceX := 84
tempLocationToProbablyClickArrangementLoopBraceY := 82

;sample transpose arrays: (theres a VEDM2 array or three that aren't pasted here yet):
	;important note for owenJ808TransposeArray: derg 808 and thicc 808 are actually D#, not F# as they are labelled. just leaving it named the way it was though in the folder structure, anyway. can change it with macros and leave the filename the same, even if it is labelled wrong in the file names. (derg 808 is the 9 in this array atm, inbetween the 7's and 6's atm, the 'thicc 808' is the 9 shortly after that 9, atm.)
	owenJ808TransposeArray := [3,3,15,3,3,3,2,2,14,14,14,2,13,13,1,12,0,12,12,12,12,12,12,12,12,12,12,12,0,12,12,12,12,12,12,12,12,12,12,12,12,12,0,12,11,11,11,11,11,11,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,9,9,9,9,9,9,9,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,7,7,7,7,7,-5,7,7,7,7,7,7,7,7,7,7,9,6,6,6,6,6,6,9,5,5,-7,5,5,5,4,4,4,4,4,4,4,4]

	;these pitches have all been checked: they all resolve to the exact same frequency when all notes are played on C3 and pitched according to this array:
	vengeancePunchKickPitchArray := [3, 7, 5, 5, 6, 6, 6, 4, 6, 4, 5, 5, 5, 6, 2, 5, 0, 4, 8, 9, 4, 3, 3, 8, 4, 4, 5, 5, 5, 8, 4, 5, 7, 5, 4, 5, 4, 6, 6, 8, 6, 5, 6, 10, 5, 5, 6, 5, 4, 6, 6, 2, 7, 6, 6, 5, 8, 6, 5, 6, 6, 5, "invalid", 4, 6, 6, 6, 6, 7, 6, 5, 6, 6, 5, 5, 6, 5, 5, 7, 5, 7, 5, 6, 6, 8, 9, 5, 6, 5, 5, 5, 6, 6, 6, 3, 5, 5, 4, 8, 5, 6, 5, 8, 6, 6, 6, 4, 4, 5, 6, 4, 6, 1, 4, 4, 6, 8, 6, 5, 6, 5, 7, "invalid", 4]		;note there are 2 invalid options in here with no one fixed pitch.

;these depend on some values inputted somewhere above:
sizeOf1GridUnitInPixelsX := (pixelCoordOfLastBarlineInMidiClip4BarSectionX - pixelCoordOfFirstBarlineInMidiClip4BarSectionX) / newNumberOfPixelsX
sizeOf1GridUnitInPixelsY := (newBottomPixel - newTopPixel) / newNumberOfPixelsY
;****************************************************************************************************************************
;****************************************************************************************************************************
;****************************************************************************************************************************

currentInputLayer := "active16thTrainingPress1"
inputStorage := []
inputStorageRefined := []

;gosub, gdipDrawFourBarGridOverlay			;grid isnt lined up to drum rack inputting atm.
gosub, drawMainLayerIndicator
gosub, gdipDrawQwertyOrErgoIndicatorToScreen
gosub, gdipDrawClockToScreen
;update the clock every 3 seconds
SetTimer, gdipDrawClockToScreen, 3000, -2147483648		;-2147483648 is lowest possible thread priority. may need to increase this value

gosub, runTrainingGame

return			;end of auto-run section, all the above needs to run on script start

switchToFourBarMidiClipStuff:
	currentInputLayer := "fourBarMidiClipMainLayer"
	gosub, drawMainLayerIndicator
return
switchToArrangementViewStuff:
	currentInputLayer := "arrangementViewMainLayer"
	gosub, drawMainLayerIndicator
return
toggleBetweenNotTripletAndTripletGrid:
	if (notTripletOrTriplet == 0)				;currently not-triplet.
	{
		newNumberOfPixelsX := 48
		notTripletOrTriplet := 1				;now is triplet grid.
	}
	else if (notTripletOrTriplet == 1)			;currently triplet.
	{
		newNumberOfPixelsX := 64
		notTripletOrTriplet := 0				;now is not-triplet grid.
	}
return
firstPartOfCreatingGdipGUI(guiName)
{
	global
	; Create a layered window (+E0x80000 : must be used for UpdateLayeredWindow to work!) that is always on top (+AlwaysOnTop), has no taskbar entry or caption
	Gui, %guiName%: -Caption +E0x20 +E0x80000 +LastFound +ToolWindow +OwnDialogs +AlwaysOnTop		;+E0x20 - this command makes gdip click-throughable, apparently.
	; Show the window
	Gui, %guiName%: Show, NA
	; Get a handle to this window we have created in order to update it later
	hwnd_%guiName% := WinExist()
	; Create a gdi bitmap with width and height of what we are going to draw into it. This is the entire drawing area for everything
	hbm_%guiName% := CreateDIBSection(gdipWidth, gdipHeight)
	; Get a device context compatible with the screen
	hdc_%guiName% := CreateCompatibleDC()
	; Select the bitmap into the device context
	obm_%guiName% := SelectObject(hdc_%guiName%, hbm_%guiName%)
	; Get a pointer to the graphics of the bitmap, for use with drawing functions
	G_%guiName% := Gdip_GraphicsFromHDC(hdc_%guiName%)
	; Set the smoothing mode to antialias = 4 to make shapes appear smoother (only used for vector drawing and filling)
	Gdip_SetSmoothingMode(G_%guiName%, 4)
	return
}
;below function used for gdip windows which don't need multiple things added to them and staying there. if you want to add things that stay on the screen over time over multiple function calls to gdip, don't use this function. although not using this function might be terrible for memory, or something. don't know how gdip works, really.
gdipCleanUpTrash(guiName)
{
	global
	; Select the object back into the hdc
	SelectObject(hdc_%guiName%, obm_%guiName%)
	; Now the bitmap may be deleted
	DeleteObject(hbm_%guiName%)
	; Also the device context related to the bitmap may be deleted
	DeleteDC(hdc_%guiName%)
	; The graphics may now be deleted
	Gdip_DeleteGraphics(G_%guiName%)
	return
}
gdipCleanUpTrashAndDestroyWindow(guiName)
{
	global
	gdipCleanUpTrash(guiName)			;this line only works if guiName is NOT enclosed in %%'s. you can test this by attempting to redraw things to a GUI window that has been 'made-inaccessible/uneditable' by this line, with and without enclosing % signs.
	gui %guiName%: destroy
}
gdipDrawQwertyOrErgoIndicatorToScreen:
	firstPartOfCreatingGdipGUI("qwertyOrErgoIndicator")
	if (qwertyOrErgo == 0)
	{
		pBrush := Gdip_BrushCreateSolid(0x99FFFF00)		;yellow if qwerty
	}
	else
	{
		pBrush := Gdip_BrushCreateSolid(0x99FF00FF)		;purple if ergo
	}
	Gdip_FillRectangle(G_qwertyOrErgoIndicator, pBrush, 1340, 0, 100, 40)
	UpdateLayeredWindow(hwnd_qwertyOrErgoIndicator, hdc_qwertyOrErgoIndicator, 0, 0, gdipWidth, gdipHeight)
	;gdipCleanUpTrashAndDestroyWindow("qwertyOrErgoIndicator")
	gdipCleanUpTrash("qwertyOrErgoIndicator")
return
drawMainLayerIndicator:			;should shorten all the code in here.
;msgbox, f
	if (whichMainLayerIndicator == 0)		;4 bar midi clip main layer 64 options
	{
		firstPartOfCreatingGdipGUI("mainLayerIndicator")
		if (isAutoVelocityOn == 0)							;auto-velocity off
			pBrush := Gdip_BrushCreateSolid(0xFFFFFF00)		;yellow
		else if (isAutoVelocityOn == 1)						;auto-velocity on
			pBrush := Gdip_BrushCreateSolid(0xFF0000FF)		;blue
		/*
	newBottomPixel := 1011			;should rename these two.
	newTopPixel := 144
	pixelCoordOfFirstBarlineInMidiClip4BarSectionX := 196	;these ones have different names, should rename all these so they all have similar naming convention.
	pixelCoordOfLastBarlineInMidiClip4BarSectionX := 1871
		*/
		Gdip_FillRectangle(G_mainLayerIndicator, pBrush, pixelCoordOfFirstBarlineInMidiClip4BarSectionX - 40, newTopPixel - 40, 20, newBottomPixel - newTopPixel + 80)			;left side
		Gdip_FillRectangle(G_mainLayerIndicator, pBrush, pixelCoordOfLastBarlineInMidiClip4BarSectionX + 20, newTopPixel - 40, 20, newBottomPixel - newTopPixel + 80)		;right side
		Gdip_FillRectangle(G_mainLayerIndicator, pBrush, pixelCoordOfFirstBarlineInMidiClip4BarSectionX - 40, newTopPixel - 40, pixelCoordOfLastBarlineInMidiClip4BarSectionX + 40, 20)		;top
		Gdip_FillRectangle(G_mainLayerIndicator, pBrush, pixelCoordOfFirstBarlineInMidiClip4BarSectionX - 40, newBottomPixel + 20, pixelCoordOfLastBarlineInMidiClip4BarSectionX + 40, 20)		;bottom
		Gdip_DeleteBrush(pBrush)
		UpdateLayeredWindow(hwnd_mainLayerIndicator, hdc_mainLayerIndicator, 0, 0, gdipWidth, gdipHeight)
		;gdipCleanUpTrashAndDestroyWindow("mainLayerIndicator")
		gdipCleanUpTrash("mainLayerIndicator")
	}
	else if (whichMainLayerIndicator == 1)		;4 bar midi clip main layer 48 options (is this any different than 64 options though?)
	{
	}
	else if (whichMainLayerIndicator == 2)		;arrangment view main layer
	{
		firstPartOfCreatingGdipGUI("mainLayerIndicator")
		if (isAutoVelocityOn == 0)							;auto-velocity off
			pBrush := Gdip_BrushCreateSolid(0xFFFFFF00)		;yellow
		else if (isAutoVelocityOn == 1)						;auto-velocity on
			pBrush := Gdip_BrushCreateSolid(0xFF0000FF)		;blue
		/*
	newBottomPixel := 1011			;should rename these two.
	newTopPixel := 144
	pixelCoordOfFirstBarlineInMidiClip4BarSectionX := 196	;these ones have different names, should rename all these so they all have similar naming convention.
	pixelCoordOfLastBarlineInMidiClip4BarSectionX := 1871
		*/
		Gdip_FillRectangle(G_mainLayerIndicator, pBrush, pixelCoordOfFirstBarlineInMidiClip4BarSectionX - 40, newTopPixel - 40, 20, newBottomPixel - newTopPixel + 80)			;left side
		Gdip_FillRectangle(G_mainLayerIndicator, pBrush, pixelCoordOfLastBarlineInMidiClip4BarSectionX + 20, newTopPixel - 40, 20, newBottomPixel - newTopPixel + 80)		;right side
		Gdip_FillRectangle(G_mainLayerIndicator, pBrush, pixelCoordOfFirstBarlineInMidiClip4BarSectionX - 40, newTopPixel - 40, pixelCoordOfLastBarlineInMidiClip4BarSectionX + 40, 20)		;top
		Gdip_FillRectangle(G_mainLayerIndicator, pBrush, pixelCoordOfFirstBarlineInMidiClip4BarSectionX - 40, newBottomPixel + 20, pixelCoordOfLastBarlineInMidiClip4BarSectionX + 40, 20)		;bottom
		Gdip_DeleteBrush(pBrush)
		UpdateLayeredWindow(hwnd_mainLayerIndicator, hdc_mainLayerIndicator, 0, 0, gdipWidth, gdipHeight)
		;gdipCleanUpTrashAndDestroyWindow("mainLayerIndicator")
		gdipCleanUpTrash("mainLayerIndicator")
	}
return
gdipDrawClockToScreen:
	firstPartOfCreatingGdipGUI("clock")
	FormatTime, systemTimeString
	trimmedSystemTimeString := SubStr(systemTimeString, 1, 8)
	; We can specify the font to use. Here we use Arial as most systems should have this installed
	Font = Arial
	; Next we can check that the user actually has the font that we wish them to use
	; If they do not then we can do something about it. I choose to give a wraning and exit!
	If !Gdip_FontFamilyCreate(Font)
	{
	   MsgBox, 48, Font error!, The font you have specified does not exist on the system
	   ExitApp
	}
	; There are a lot of things to cover with the function Gdip_TextToGraphics
	; The 1st parameter is the graphics we wish to use (our canvas)
	; The 2nd parameter is the text we wish to write. It can include new lines `n
	; The 3rd parameter, the options are where all the action takes place...
	; You can write literal x and y coordinates such as x20 y50 which would place the text at that position in pixels
	; or you can include the last 2 parameters (Width and Height of the Graphics we will use) and then you can use x10p
	; which will place the text at 10% of the width and y30p which is 30% of the height
	; The same percentage marker may be used for width and height also, so w80p makes the bounding box of the rectangle the text
	; will be written to 80% of the width of the graphics. If either is missed (as I have missed height) then the height of the bounding
	; box will be made to be the height of the graphics, so 100%
	; Any of the following words may be used also: Regular,Bold,Italic,BoldItalic,Underline,Strikeout to perform their associated action
	; To justify the text any of the following may be used: Near,Left,Centre,Center,Far,Right with different spelling of words for convenience
	; The rendering hint (the quality of the antialiasing of the text) can be specified with r, whose values may be:
	; SystemDefault = 0
	; SingleBitPerPixelGridFit = 1
	; SingleBitPerPixel = 2
	; AntiAliasGridFit = 3
	; AntiAlias = 4
	; The size can simply be specified with s
	; The colour and opacity can be specified for the text also by specifying the ARGB as demonstrated with other functions such as the brush
	; So cffff0000 would make a fully opaque red brush, so it is: cARGB (the literal letter c, follwed by the ARGB)
	; The 4th parameter is the name of the font you wish to use
	; As mentioned previously, you don not need to specify the last 2 parameters, the width and height, unless
	; you are planning on using the p option with the x,y,w,h to use the percentage
	Options = x70p y1p w80p cff000000 r4 s20 Underline Italic
	Gdip_TextToGraphics(G_clock, trimmedSystemTimeString, Options, Font, gdipWidth, gdipHeight)
	UpdateLayeredWindow(hwnd_clock, hdc_clock, 0, 0, gdipWidth, gdipHeight)
	;gdipCleanUpTrashAndDestroyWindow("clock")
	gdipCleanUpTrash("clock")
return
Exit:
; gdi+ may now be shutdown on exiting the program
Gdip_Shutdown(pToken)
ExitApp
Return
GdipShadeWholeScreen(colorVal)			;can this be merged with other gdip code/shortened?
{
	global		;this line is needed. i think is needed because a lot of these GDIP gui references are to global variables. putting this 'global' keyword i think gives the function access to all of them. or however many there are, maybe only 1. maybe 10. dont know.
	; Create a layered window (+E0x80000 : must be used for UpdateLayeredWindow to work!) that is always on top (+AlwaysOnTop), has no taskbar entry or caption
	firstPartOfCreatingGdipGUI("shadeWholeScreen")
	pBrush := Gdip_BrushCreateSolid(colorVal)
	Gdip_FillRectangle(G_shadeWholeScreen, pBrush, 0, 0, 120, 1080)
	Gdip_DeleteBrush(pBrush)
	; Update the specified window we have created (hwnd1) with a handle to our bitmap (hdc), specifying the x,y,w,h we want it positioned on our screen
	; So this will position our gui at (0,0) with the Width and Height specified earlier
	UpdateLayeredWindow(hwnd_shadeWholeScreen, hdc_shadeWholeScreen, 0, 0, gdipWidth, gdipHeight)
	;gdipCleanUpTrashAndDestroyWindow("shadeWholeScreen")
	gdipCleanUpTrash("shadeWholeScreen")
	return
}
gdipDrawFourBarGridOverlay:
	xOffset := -6			;this var is so that note start- and end- points are visible; not obfuscated by the gridlines.
	firstPartOfCreatingGdipGUI("fourBarGridOverlay")
	pBrush := Gdip_BrushCreateSolid(0xFFFFFFFF)		;white
	loopvar := 1
	Loop, 15		;15 vertical lines to separate 4 bars
	{
		if (loopvar == 4 || loopvar == 8 || loopvar == 12)
		{
			xToDrawAt := pixelCoordOfFirstBarlineInMidiClip4BarSectionX + (loopvar * ((pixelCoordOfLastBarlineInMidiClip4BarSectionX - pixelCoordOfFirstBarlineInMidiClip4BarSectionX) / 64) * 4) - 4 + xOffset
			yToDrawAt := newBottomPixel - (sizeOf1GridUnitInPixelsY * newNumberOfPixelsY)
			Gdip_FillRectangle(G_fourBarGridOverlay, pBrush, xToDrawAt, yToDrawAt, 8, sizeOf1GridUnitInPixelsY * newNumberOfPixelsY)
		}
		else
		{
			xToDrawAt := pixelCoordOfFirstBarlineInMidiClip4BarSectionX + (loopvar * ((pixelCoordOfLastBarlineInMidiClip4BarSectionX - pixelCoordOfFirstBarlineInMidiClip4BarSectionX) / 64) * 4) - 2 + xOffset
			yToDrawAt := newBottomPixel - (sizeOf1GridUnitInPixelsY * newNumberOfPixelsY)
			Gdip_FillRectangle(G_fourBarGridOverlay, pBrush, xToDrawAt, yToDrawAt, 4, sizeOf1GridUnitInPixelsY * newNumberOfPixelsY)
		}
		loopvar ++
	}
	loopvar := 1
	Loop, 8			; atm theres 8 bars. there were 9. probably hasn't caused any bugs changing this over though.
	{
		if (loopvar == 3 || loopvar == 6)
		{
			yToDrawAt := newBottomPixel - (loopvar * sizeOf1GridUnitInPixelsY * 7) - 4		;the 7 here is caus its 4 pixels per guidebar
			Gdip_FillRectangle(G_fourBarGridOverlay, pBrush, pixelCoordOfFirstBarlineInMidiClip4BarSectionX + xOffset, yToDrawAt, ((pixelCoordOfLastBarlineInMidiClip4BarSectionX - pixelCoordOfFirstBarlineInMidiClip4BarSectionX) / 64) * newNumberOfPixelsX, 8)
		}
		else
		{
			yToDrawAt := newBottomPixel - (loopvar * sizeOf1GridUnitInPixelsY * 7) - 2		;the 7 here is caus its 4 pixels per guidebar
			Gdip_FillRectangle(G_fourBarGridOverlay, pBrush, pixelCoordOfFirstBarlineInMidiClip4BarSectionX + xOffset, yToDrawAt, ((pixelCoordOfLastBarlineInMidiClip4BarSectionX - pixelCoordOfFirstBarlineInMidiClip4BarSectionX) / 64) * newNumberOfPixelsX, 4)
		}
		loopvar ++
	}
	;drawing the inside black bars:
	pBrush := Gdip_BrushCreateSolid(0xFF000000)		;black
	loopvar := 1
	Loop, 15		;15 vertical lines to separate 4 bars
	{
		if (loopvar == 4 || loopvar == 8 || loopvar == 12)
		{
			xToDrawAt := pixelCoordOfFirstBarlineInMidiClip4BarSectionX + (loopvar * ((pixelCoordOfLastBarlineInMidiClip4BarSectionX - pixelCoordOfFirstBarlineInMidiClip4BarSectionX) / 64) * 4) - 3 + xOffset
			yToDrawAt := newBottomPixel - (sizeOf1GridUnitInPixelsY * newNumberOfPixelsY)
			Gdip_FillRectangle(G_fourBarGridOverlay, pBrush, xToDrawAt, yToDrawAt, 6, sizeOf1GridUnitInPixelsY * newNumberOfPixelsY)
		}
		else
		{
			xToDrawAt := pixelCoordOfFirstBarlineInMidiClip4BarSectionX + (loopvar * ((pixelCoordOfLastBarlineInMidiClip4BarSectionX - pixelCoordOfFirstBarlineInMidiClip4BarSectionX) / 64) * 4) - 1 + xOffset
			yToDrawAt := newBottomPixel - (sizeOf1GridUnitInPixelsY * newNumberOfPixelsY)
			Gdip_FillRectangle(G_fourBarGridOverlay, pBrush, xToDrawAt, yToDrawAt, 2, sizeOf1GridUnitInPixelsY * newNumberOfPixelsY)
		}
		loopvar ++
	}
	loopvar := 1
	Loop, 8			; atm theres 8 bars. there were 9. probably hasn't caused any bugs changing this over though.
	{
		if (loopvar == 3 || loopvar == 6)
		{
			yToDrawAt := newBottomPixel - (loopvar * sizeOf1GridUnitInPixelsY * 7) - 3		;the 7 here is caus its 4 pixels per guidebar
			Gdip_FillRectangle(G_fourBarGridOverlay, pBrush, pixelCoordOfFirstBarlineInMidiClip4BarSectionX + xOffset, yToDrawAt, ((pixelCoordOfLastBarlineInMidiClip4BarSectionX - pixelCoordOfFirstBarlineInMidiClip4BarSectionX) / 64) * newNumberOfPixelsX, 6)		;width of 4 for the black bars.
		}
		else
		{
			yToDrawAt := newBottomPixel - (loopvar * sizeOf1GridUnitInPixelsY * 7) - 1		;the 7 here is caus its 4 pixels per guidebar
			Gdip_FillRectangle(G_fourBarGridOverlay, pBrush, pixelCoordOfFirstBarlineInMidiClip4BarSectionX + xOffset, yToDrawAt, ((pixelCoordOfLastBarlineInMidiClip4BarSectionX - pixelCoordOfFirstBarlineInMidiClip4BarSectionX) / 64) * newNumberOfPixelsX, 2)		;width of 4 for the black bars.
		}
		loopvar ++
	}
	Gdip_DeleteBrush(pBrush)
	UpdateLayeredWindow(hwnd_fourBarGridOverlay, hdc_fourBarGridOverlay, 0, 0, gdipWidth, gdipHeight)
	;gdipCleanUpTrashAndDestroyWindow("fourBarGridOverlay")
	gdipCleanUpTrash("fourBarGridOverlay")
return
home::
;this key used to switch between ergo and qwerty
if (qwertyOrErgo == 0)
	qwertyOrErgo := 1
else
	qwertyOrErgo := 0
gosub, gdipDrawQwertyOrErgoIndicatorToScreen
return
esc::
	ExitApp
return
drawKeyPressToScreen(funcKeyPressName)
{
	global
/*
;dont know if this is causing bugs. comment blocking it out for now.
	firstPartOfCreatingGdipGUI("drawKeyPressToScreen")
	; We can specify the font to use. Here we use Arial as most systems should have this installed
	Font = Arial
	; Next we can check that the user actually has the font that we wish them to use
	; If they do not then we can do something about it. I choose to give a wraning and exit!
	If !Gdip_FontFamilyCreate(Font)
	{
	   MsgBox, 48, Font error!, The font you have specified does not exist on the system
	   ExitApp
	}
	; There are a lot of things to cover with the function Gdip_TextToGraphics
	; The 1st parameter is the graphics we wish to use (our canvas)
	; The 2nd parameter is the text we wish to write. It can include new lines `n
	; The 3rd parameter, the options are where all the action takes place...
	; You can write literal x and y coordinates such as x20 y50 which would place the text at that position in pixels
	; or you can include the last 2 parameters (Width and Height of the Graphics we will use) and then you can use x10p
	; which will place the text at 10% of the width and y30p which is 30% of the height
	; The same percentage marker may be used for width and height also, so w80p makes the bounding box of the rectangle the text
	; will be written to 80% of the width of the graphics. If either is missed (as I have missed height) then the height of the bounding
	; box will be made to be the height of the graphics, so 100%
	; Any of the following words may be used also: Regular,Bold,Italic,BoldItalic,Underline,Strikeout to perform their associated action
	; To justify the text any of the following may be used: Near,Left,Centre,Center,Far,Right with different spelling of words for convenience
	; The rendering hint (the quality of the antialiasing of the text) can be specified with r, whose values may be:
	; SystemDefault = 0
	; SingleBitPerPixelGridFit = 1
	; SingleBitPerPixel = 2
	; AntiAliasGridFit = 3
	; AntiAlias = 4
	; The size can simply be specified with s
	; The colour and opacity can be specified for the text also by specifying the ARGB as demonstrated with other functions such as the brush
	; So cffff0000 would make a fully opaque red brush, so it is: cARGB (the literal letter c, follwed by the ARGB)
	; The 4th parameter is the name of the font you wish to use
	; As mentioned previously, you don not need to specify the last 2 parameters, the width and height, unless
	; you are planning on using the p option with the x,y,w,h to use the percentage
	Options = x5p y90p w80p cff000000 r4 s38 Underline Italic
	keyPressStringToPrintToScreen := keyPressStringToPrintToScreen . funcKeyPressName . " "
	if (StrLen(keyPressStringToPrintToScreen) > 130)
	{
		keyPressStringToPrintToScreen := ""
	}
	Gdip_TextToGraphics(G_drawKeyPressToScreen, keyPressStringToPrintToScreen, Options, Font, gdipWidth, gdipHeight)
	UpdateLayeredWindow(hwnd_drawKeyPressToScreen, hdc_drawKeyPressToScreen, 0, 0, gdipWidth, gdipHeight)
	Gdip_DeleteBrush(pBrush)
	UpdateLayeredWindow(hwnd_drawKeyPressToScreen, hdc_drawKeyPressToScreen, 0, 0, gdipWidth, gdipHeight)
	;gdipCleanUpTrashAndDestroyWindow("drawKeyPressToScreen")
	gdipCleanUpTrash("drawKeyPressToScreen")
*/
	return
}
t::
	%currentInputLayer%(1)
return
r::
	%currentInputLayer%(2)
return
f::
	%currentInputLayer%(3)
return
d::
	%currentInputLayer%(4)
return
u::
	%currentInputLayer%(5)
return
i::
	%currentInputLayer%(6)
return
j::
	%currentInputLayer%(7)
return
k::
	%currentInputLayer%(8)
return
Space::
%currentInputLayer%(9)			;putting space on 9 for now
return
clearInputStorageArrays:
	inputStorage := []
	inputStorageRefined := []
return
incorrectSequenceInputted:			;THIS FUNCTION USED TO DESELECT ALL CURRENTLY-SELECTED NOTES, BY CLICKING ON A COORDINATE SPOT... left the block of code, just would need to remove the blockcomment start and end symbols and it would run as before, probably.
/*
	tooltip		;get rid of any tooltip, so that mouse macros dont click on tooltip
	if (in4BarSectionOrFull256OrNotInMidiClip == 0)				;currently in 4bar section.
	{
		mousemove, pixelCoordOfFirstBarlineInMidiClip4BarSectionX, pixelCoordOfRowJustAboveMidiClipY			;click cursor to 1:1
		Click		;this click deselects any currently-selected notes
	}
	else if (in4BarSectionOrFull256OrNotInMidiClip == 1)		;currently in full 256bar section.
	{
		mousemove, pixelCoordOfFirstBarlineInMidiClipFull256BarsX, pixelCoordOfRowJustAboveMidiClipY			;click cursor to 1:1
		Click		;this click deselects any currently-selected notes
	}
	else if (in4BarSectionOrFull256OrNotInMidiClip == 2)		;currently NOT in MIDI editor window.
	{
		;do nothing.			;maybe this should do something.
	}
*/
	GdipShadeWholeScreen("0x66ff0000")									;red
return
pushABunchOfKeysUpToTryPreventBugs:			;maybe should add stuff like '{Win up}' or ralt, rshift, lshift, etc.... but checked atm.
;does this add a lot of delay to the script, since it runs every time mainLayer happens?
	suspend, on
	send, {ctrl up}{shift up}{alt up}{lbutton up}{rbutton up}
	suspend, off
return



doEverythingForGoingBackToMainLayer:
	gosub, clearInputStorageArrays
	currentInputLayer := "active16thTrainingPress1"
	gosub, drawMainLayerIndicator
return

active16thTrainingPress1(inputNumber)
{
	global
		;putting this here atm to see if it prevents bugs:
		;does this add a lot of delay to the script, since it runs every time mainLayer happens(?):
		;does it cause bugs as well(?):
	;gosub, pushABunchOfKeysUpToTryPreventBugs
	if (inputNumber == 5)
	{
		inputNumberReEvaluated := inputNumber - 4
		inputStorage.Push(inputNumberReEvaluated)
		currentInputLayer := "active16thTrainingPress2"
		gdipCleanUpTrashAndDestroyWindow("mainLayerIndicator")			;put this line on every layer that redirects away from mainLayer.
		gdipCleanUpTrashAndDestroyWindow("shadeWholeScreen")			;putting this line here for now.
	}
	else if (inputNumber == 6)
	{
		inputNumberReEvaluated := inputNumber - 4
		inputStorage.Push(inputNumberReEvaluated)
		currentInputLayer := "active16thTrainingPress2"
		gdipCleanUpTrashAndDestroyWindow("mainLayerIndicator")			;put this line on every layer that redirects away from mainLayer.
		gdipCleanUpTrashAndDestroyWindow("shadeWholeScreen")			;putting this line here for now.
	}
	else if (inputNumber == 7)
	{
		inputNumberReEvaluated := inputNumber - 4
		inputStorage.Push(inputNumberReEvaluated)
		currentInputLayer := "active16thTrainingPress2"
		gdipCleanUpTrashAndDestroyWindow("mainLayerIndicator")			;put this line on every layer that redirects away from mainLayer.
		gdipCleanUpTrashAndDestroyWindow("shadeWholeScreen")			;putting this line here for now.
	}
	else if (inputNumber == 8)
	{
		inputNumberReEvaluated := inputNumber - 4
		inputStorage.Push(inputNumberReEvaluated)
		currentInputLayer := "active16thTrainingPress2"
		gdipCleanUpTrashAndDestroyWindow("mainLayerIndicator")			;put this line on every layer that redirects away from mainLayer.
		gdipCleanUpTrashAndDestroyWindow("shadeWholeScreen")			;putting this line here for now.
	}
	else if (inputNumber == 9)
	{
		; do nothing caus this is pretty much the 'main' layer atm, at time of writing this.
	}
	else
	{

		;gdipCleanUpTrashAndDestroyWindow("mainLayerIndicator")			;should this line be here at all??? (its not usually here, just wondering.)
		gosub, incorrectSequenceInputted
	}
	return
}
active16thTrainingPress2(inputNumber)
{
	global
	if (inputNumber == 1)
	{
		inputStorage.Push(inputNumber)
		currentInputLayer := "active16thTrainingPress3"
	}
	else if (inputNumber == 2)
	{
		inputStorage.Push(inputNumber)
		currentInputLayer := "active16thTrainingPress3"
	}
	else if (inputNumber == 3)
	{
		inputStorage.Push(inputNumber)
		currentInputLayer := "active16thTrainingPress3"
	}
	else if (inputNumber == 4)
	{
		inputStorage.Push(inputNumber)
		currentInputLayer := "active16thTrainingPress3"
	}
	else if (inputNumber == 9)
	{
		gosub, doEverythingForGoingBackToMainLayer
	}
	else
	{
		gosub, incorrectSequenceInputted
	}
	return
}
active16thTrainingPress3(inputNumber)
{
	global
	if (inputNumber == 5)
	{
		shitForGame(inputNumber)
	}
	else if (inputNumber == 6)
	{
		shitForGame(inputNumber)
	}
	else if (inputNumber == 7)
	{
		shitForGame(inputNumber)
	}
	else if (inputNumber == 8)
	{
		shitForGame(inputNumber)
	}
	else if (inputNumber == 9)
	{
		gosub, doEverythingForGoingBackToMainLayer
	}
	else
	{
		gosub, incorrectSequenceInputted
	}
	return
}

shitForGame(inputNumber)
{
	global
	inputNumberReEvaluated := inputNumber - 4
	inputStorage.Push(inputNumberReEvaluated)
	valToPushToArray := ((inputStorage[1] - 1) * 16) + ((inputStorage[2] - 1) * 4) + inputStorage[3]
	if (valToPushToArray >= 1 && valToPushToArray <= 64)		;check value is between 1 and 64, endpoints included.
	{
		inputStorageRefined.Push(valToPushToArray)	;stores 1-64 value in array to be used later.
		if (trainingGameVal == valToPushToArray)
		{
			gosub, runTrainingGame
		}
		else
		{
			gosub, incorrectSequenceInputted
		}
		;return 1		;was this line necessary?
	}
	else
	{
		gosub, incorrectSequenceInputted
		;return 0		;was this line necessary?
	}
	gosub, doEverythingForGoingBackToMainLayer
	return
}


runTrainingGame:
random, trainingGameVal, 1, 64
gosub, gdipDrawTrainingGameToScreen
return

gdipDrawTrainingGameToScreen:
	; Create a layered window (+E0x80000 : must be used for UpdateLayeredWindow to work!) that is always on top (+AlwaysOnTop), has no taskbar entry or caption
	firstPartOfCreatingGdipGUI("gdipTrainingGame")
	pBrush := Gdip_BrushCreateSolid(0xFF000000)

	;probably put these 3 values in the top of the script with all the other variables:
	gameLeftX := 255
	gameRightX := 1904
	gameYVal := 414

	leftXToDrawGameRectangleAt := (((gameRightX - gameLeftX) / 64) * (trainingGameVal - 1)) + gameLeftX
	rightXToDrawGameRectangleAt := (((gameRightX - gameLeftX) / 64) * (trainingGameVal - 0)) + gameLeftX
	XSizeOfGameRectangle := rightXToDrawGameRectangleAt - leftXToDrawGameRectangleAt
	YSizeOfGameRectangle := 28		;does this have to be an even number? probably?

	Gdip_FillRectangle(G_gdipTrainingGame, pBrush, leftXToDrawGameRectangleAt, gameYVal - (YSizeOfGameRectangle / 2), XSizeOfGameRectangle, YSizeOfGameRectangle)
	Gdip_DeleteBrush(pBrush)
	; Update the specified window we have created (hwnd1) with a handle to our bitmap (hdc), specifying the x,y,w,h we want it positioned on our screen
	; So this will position our gui at (0,0) with the Width and Height specified earlier
	UpdateLayeredWindow(hwnd_gdipTrainingGame, hdc_gdipTrainingGame, 0, 0, gdipWidth, gdipHeight)
	;gdipCleanUpTrashAndDestroyWindow("gdipTrainingGame")
	gdipCleanUpTrash("gdipTrainingGame")
return





;deleted a bunch of code here. lots of the old functions just deleted... all the old functions here were deleted now.






return		;putting this here as a stop so all these hotkeys aren't triggered.
;function keys dont work on laptop
f1::
f2::
f3::
f4::
f5::
f6::
f7::
f8::
f9::
f10::
;f11::			;'f11': using this for fullscreen game atm
f12::
`::				;does this need to be escaped?
1::
;gosub, saveGdipBitmapToFile			;'1' press was the temporary save bitmap file shortcut, when this script was for gdip pixel drawing.
2::
3::
4::
5::
6::
7::
8::
9::
0::
-::
=::
Backspace::
Tab::
q::
w::
[::
]::
\::
CapsLock::
a::
'::
Enter::
LShift::
RShift::
LCtrl::
LWin::
LAlt::
RAlt::
RWin:
AppsKey::
RCtrl::
Left::
Up::
Right::
Down::
Delete::
PgUp::
PgDn::
e::
g::
s::
b::
v::
c::
x::
z::
y::
o::
p::
h::
l::
`;::
n::
m::
,::
.::
/::
NumpadHome::
return
return

End::
	suspend, permit ;this line just means the hotkey end-press doesn't get suspended. so that this keypress can be used to toggle suspend on and off.
	if (suspendVal == 0)
	{
		gdipCleanUpTrashAndDestroyWindow("fourBarGridOverlay")
		gdipCleanUpTrashAndDestroyWindow("mainLayerIndicator")
		suspendVal := 1
	}
	else
	{
		gosub, gdipDrawFourBarGridOverlay
		suspendVal := 0
	}
	suspend, toggle			;temp suspend key
return

;atm only key missing on laptop keyboard is entire top row (including the function keys, EXCEPT esc and delete), and laptop trackpad+clickers, and the fn key in bottom left corner.


/*
new ideas for this simple drum inputter:
- drum layout:
	C3:		kick
	C#3:	snare
	D3:		clap
	D#3:	rim
	E3:		snap
	F3:		tom
	F#3:	hh
	G3:		crash
	G#3:	oh
- limit to 4 bars
- have bpm randomizer
- have sample randomizer?
- have things like copy/paste/duplicate
- no velocity
- no automation
- have playback options?

main:
1	moveActive16thOptionsPress1
2	inputNoteOptions
3	playbackOptions
4	copyPasteDuplicateOptions

moveActive16thOptions:
1	moveActive16thAbsolutePress1				(3 more presses)
2	moveActive16thRelativeNegativePress1		(2 more presses)
3	moveActive16thRelativePositivePress1		(2 more presses)
4			UNUSED ATM

inputNoteOptionsPress1:
1	inputNoteOptionsPress2Options1To4			(1 more press)
2	inputNoteOptionsPress2Options5To8			(1 more press)
3	inputNoteOptionsPress2Options9To12			(1 more press)
4			UNUSED ATM

playbackOptions:
1	[play from start of 4bar section]
2	[play from 1st barline to the left of active16th]
3	[play from 2nd barline to the left of active16th]
4			UNUSED ATM

copyPasteDuplicateOptions:
1
2
3
4














*/