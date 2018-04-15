require "Wherigo"
ZonePoint = Wherigo.ZonePoint
Distance = Wherigo.Distance
Player = Wherigo.Player

-- String decode --
function _o1x(str)
	local res = ""
    local dtable = "\005\041\027\026\100\117\061\098\010\013\015\040\066\068\049\089\082\038\071\074\079\017\032\008\047\025\012\086\121\042\052\003\056\109\105\004\099\119\092\096\108\029\059\069\060\035\045\114\101\110\043\088\095\039\077\051\080\120\083\028\020\073\054\057\055\014\091\122\070\009\123\006\016\126\097\087\116\007\076\058\030\044\050\001\118\084\053\113\019\064\031\000\033\011\112\107\022\072\065\046\067\018\090\021\104\034\075\024\062\103\094\111\002\036\023\106\048\124\085\102\125\115\093\081\078\037\063"
	for i=1, #str do
        local b = str:byte(i)
        if b > 0 and b <= 0x7F then
	        res = res .. string.char(dtable:byte(b))
        else
            res = res .. string.char(b)
        end
	end
	return res
end

-- Internal functions --
require "table"
require "math"

math.randomseed(os.time())
math.random()
math.random()
math.random()

_Urwigo = {}

_Urwigo.InlineRequireLoaded = {}
_Urwigo.InlineRequireRes = {}
_Urwigo.InlineRequire = function(moduleName)
  local res
  if _Urwigo.InlineRequireLoaded[moduleName] == nil then
    res = _Urwigo.InlineModuleFunc[moduleName]()
    _Urwigo.InlineRequireLoaded[moduleName] = 1
    _Urwigo.InlineRequireRes[moduleName] = res
  else
    res = _Urwigo.InlineRequireRes[moduleName]
  end
  return res
end

_Urwigo.Round = function(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

_Urwigo.Ceil = function(num, idp)
  local mult = 10^(idp or 0)
  return math.ceil(num * mult) / mult
end

_Urwigo.Floor = function(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult) / mult
end

_Urwigo.DialogQueue = {}
_Urwigo.RunDialogs = function(callback)
	local dialogs = _Urwigo.DialogQueue
	local lastCallback = nil
	_Urwigo.DialogQueue = {}
	local msgcb = {}
	msgcb = function(action)
		if action ~= nil then
			if lastCallback ~= nil then
				lastCallback(action)
			end
			local entry = table.remove(dialogs, 1)
			if entry ~= nil then
				lastCallback = entry.Callback;
				if entry.Text ~= nil then
					Wherigo.MessageBox({Text = entry.Text, Media=entry.Media, Buttons=entry.Buttons, Callback=msgcb})
				else
					msgcb(action)
				end
			else
				if callback ~= nil then
					callback()
				end
			end
		end
	end
	msgcb(true) -- any non-null argument
end

_Urwigo.MessageBox = function(tbl)
    _Urwigo.RunDialogs(function() Wherigo.MessageBox(tbl) end)
end

_Urwigo.OldDialog = function(tbl)
    _Urwigo.RunDialogs(function() Wherigo.Dialog(tbl) end)
end

_Urwigo.Dialog = function(buffered, tbl, callback)
	for k,v in ipairs(tbl) do
		table.insert(_Urwigo.DialogQueue, v)
	end
	if callback ~= nil then
		table.insert(_Urwigo.DialogQueue, {Callback=callback})
	end
	if not buffered then
		_Urwigo.RunDialogs(nil)
	end
end

_Urwigo.Hash = function(str)
   local b = 378551;
   local a = 63689;
   local hash = 0;
   for i = 1, #str, 1 do
      hash = hash*a+string.byte(str,i);
      hash = math.fmod(hash, 65535)
      a = a*b;
      a = math.fmod(a, 65535)
   end
   return hash;
end

_Urwigo.DaysInMonth = {
	31,
	28,
	31,
	30,
	31,
	30,
	31,
	31,
	30,
	31,
	30,
	31,
}

_Urwigo_Date_IsLeapYear = function(year)
	if year % 400 == 0 then
		return true
	elseif year% 100 == 0 then
		return false
	elseif year % 4 == 0 then
		return true
	else
		return false
	end
end

_Urwigo.Date_DaysInMonth = function(year, month)
	if month ~= 2 then
		return _Urwigo.DaysInMonth[month];
	else
		if _Urwigo_Date_IsLeapYear(year) then
			return 29
		else
			return 28
		end
	end
end

_Urwigo.Date_DayInYear = function(t)
	local res = t.day
	for month = 1, t.month - 1 do
		res = res + _Urwigo.Date_DaysInMonth(t.year, month)
	end
	return res
end

_Urwigo.Date_HourInWeek = function(t)
	return t.hour + (t.wday-1) * 24
end

_Urwigo.Date_HourInMonth = function(t)
	return t.hour + t.day * 24
end

_Urwigo.Date_HourInYear = function(t)
	return t.hour + (_Urwigo.Date_DayInYear(t) - 1) * 24
end

_Urwigo.Date_MinuteInDay = function(t)
	return t.min + t.hour * 60
end

_Urwigo.Date_MinuteInWeek = function(t)
	return t.min + t.hour * 60 + (t.wday-1) * 1440;
end

_Urwigo.Date_MinuteInMonth = function(t)
	return t.min + t.hour * 60 + (t.day-1) * 1440;
end

_Urwigo.Date_MinuteInYear = function(t)
	return t.min + t.hour * 60 + (_Urwigo.Date_DayInYear(t) - 1) * 1440;
end

_Urwigo.Date_SecondInHour = function(t)
	return t.sec + t.min * 60
end

_Urwigo.Date_SecondInDay = function(t)
	return t.sec + t.min * 60 + t.hour * 3600
end

_Urwigo.Date_SecondInWeek = function(t)
	return t.sec + t.min * 60 + t.hour * 3600 + (t.wday-1) * 86400
end

_Urwigo.Date_SecondInMonth = function(t)
	return t.sec + t.min * 60 + t.hour * 3600 + (t.day-1) * 86400
end

_Urwigo.Date_SecondInYear = function(t)
	return t.sec + t.min * 60 + t.hour * 3600 + (_Urwigo.Date_DayInYear(t)-1) * 86400
end


-- Inlined modules --
_Urwigo.InlineModuleFunc = {}

objKlausraeumtauf = Wherigo.ZCartridge()

-- Media --
objKlaus = Wherigo.ZMedia(objKlausraeumtauf)
objKlaus.Id = "18d2d68c-c80d-41e6-8105-edb9120b9e43"
objKlaus.Name = "Klaus"
objKlaus.Description = ""
objKlaus.AltText = ""
objKlaus.Resources = {
	{
		Type = "jpg", 
		Filename = "Klaus.jpg", 
		Directives = {}
	}
}
objKoordinaten = Wherigo.ZMedia(objKlausraeumtauf)
objKoordinaten.Id = "19afd0ac-8d56-4bb6-8bfb-f10f21b76f88"
objKoordinaten.Name = "Koordinaten"
objKoordinaten.Description = ""
objKoordinaten.AltText = ""
objKoordinaten.Resources = {
	{
		Type = "jpg", 
		Filename = "koordinaten.jpg", 
		Directives = {}
	}
}
objicoKoordinaten = Wherigo.ZMedia(objKlausraeumtauf)
objicoKoordinaten.Id = "fac30f8f-69db-451b-8d89-8059b7073700"
objicoKoordinaten.Name = "ico-Koordinaten"
objicoKoordinaten.Description = ""
objicoKoordinaten.AltText = ""
objicoKoordinaten.Resources = {
	{
		Type = "jpg", 
		Filename = "ico-koordinaten.jpg", 
		Directives = {}
	}
}
objSpoiler = Wherigo.ZMedia(objKlausraeumtauf)
objSpoiler.Id = "54fb5488-9be7-4f5d-b535-4b08f60a6e9f"
objSpoiler.Name = "Spoiler"
objSpoiler.Description = ""
objSpoiler.AltText = ""
objSpoiler.Resources = {
	{
		Type = "jpg", 
		Filename = "spoiler.jpg", 
		Directives = {}
	}
}
objicoSpoiler = Wherigo.ZMedia(objKlausraeumtauf)
objicoSpoiler.Id = "301faaa8-dc39-459d-976b-7250f6f188d7"
objicoSpoiler.Name = "ico-Spoiler"
objicoSpoiler.Description = ""
objicoSpoiler.AltText = ""
objicoSpoiler.Resources = {
	{
		Type = "jpg", 
		Filename = "ico-spoiler.jpg", 
		Directives = {}
	}
}
objFreischaltcode = Wherigo.ZMedia(objKlausraeumtauf)
objFreischaltcode.Id = "0cb22c5e-4649-4efe-996f-1d092cb8258d"
objFreischaltcode.Name = "Freischaltcode"
objFreischaltcode.Description = ""
objFreischaltcode.AltText = ""
objFreischaltcode.Resources = {
	{
		Type = "jpg", 
		Filename = "grundbuch.jpg", 
		Directives = {}
	}
}
objicoFreischaltcode = Wherigo.ZMedia(objKlausraeumtauf)
objicoFreischaltcode.Id = "c16918d0-97c5-4793-922d-e23d23bab8f3"
objicoFreischaltcode.Name = "ico-Freischaltcode"
objicoFreischaltcode.Description = ""
objicoFreischaltcode.AltText = ""
objicoFreischaltcode.Resources = {
	{
		Type = "jpg", 
		Filename = "ico-grundbuch.jpg", 
		Directives = {}
	}
}
objAnleitung = Wherigo.ZMedia(objKlausraeumtauf)
objAnleitung.Id = "b60e8f4c-ef31-4396-be2b-dd4103abc7c8"
objAnleitung.Name = "Anleitung"
objAnleitung.Description = ""
objAnleitung.AltText = ""
objAnleitung.Resources = {
	{
		Type = "jpg", 
		Filename = "Notizbuch.jpg", 
		Directives = {}
	}
}
objicoAnleitung = Wherigo.ZMedia(objKlausraeumtauf)
objicoAnleitung.Id = "249a1aec-df24-4ce4-8c02-8e214647dcc2"
objicoAnleitung.Name = "ico-Anleitung"
objicoAnleitung.Description = ""
objicoAnleitung.AltText = ""
objicoAnleitung.Resources = {
	{
		Type = "jpg", 
		Filename = "ico-Notizbuch.jpg", 
		Directives = {}
	}
}
objfahne = Wherigo.ZMedia(objKlausraeumtauf)
objfahne.Id = "46dbd109-a29a-4ee8-9916-700f73b50da4"
objfahne.Name = "fahne"
objfahne.Description = ""
objfahne.AltText = ""
objfahne.Resources = {
	{
		Type = "jpg", 
		Filename = "fahne.jpg", 
		Directives = {}
	}
}
objicofahne = Wherigo.ZMedia(objKlausraeumtauf)
objicofahne.Id = "db100ea6-c0d3-4745-b6b0-7e5bf8b0116e"
objicofahne.Name = "ico-fahne"
objicofahne.Description = ""
objicofahne.AltText = ""
objicofahne.Resources = {
	{
		Type = "jpg", 
		Filename = "ico-fahne.jpg", 
		Directives = {}
	}
}
objtest = Wherigo.ZMedia(objKlausraeumtauf)
objtest.Id = "f11618d6-0b05-4b17-aa2a-50b64bebc48f"
objtest.Name = "test"
objtest.Description = ""
objtest.AltText = ""
objtest.Resources = {
	{
		Type = "jpg", 
		Filename = "fragezeichen.jpg", 
		Directives = {}
	}
}
imgT = Wherigo.ZMedia(objKlausraeumtauf)
imgT.Id = "dedc72ba-d67a-4559-9f84-4f7c16ae7749"
imgT.Name = "ico-test"
imgT.Description = ""
imgT.AltText = ""
imgT.Resources = {
	{
		Type = "jpg", 
		Filename = "ico-fragezeichen.jpg", 
		Directives = {}
	}
}
objicoKarte = Wherigo.ZMedia(objKlausraeumtauf)
objicoKarte.Id = "48d495cd-a43c-43ad-9027-058f08cc9ef8"
objicoKarte.Name = "ico-Karte"
objicoKarte.Description = ""
objicoKarte.AltText = ""
objicoKarte.Resources = {
	{
		Type = "jpg", 
		Filename = "karte.jpg", 
		Directives = {}
	}
}
objkartegross = Wherigo.ZMedia(objKlausraeumtauf)
objkartegross.Id = "3de1745b-c7ae-40d5-aa6a-942722c3687c"
objkartegross.Name = "karte-gross"
objkartegross.Description = ""
objkartegross.AltText = ""
objkartegross.Resources = {
	{
		Type = "jpg", 
		Filename = "kartenfeld.jpg", 
		Directives = {}
	}
}
img0 = Wherigo.ZMedia(objKlausraeumtauf)
img0.Id = "1ea8e559-479a-456d-a31b-48d82fd46faf"
img0.Name = "0"
img0.Description = ""
img0.AltText = ""
img0.Resources = {
	{
		Type = "jpg", 
		Filename = "0.jpg", 
		Directives = {}
	}
}
img1 = Wherigo.ZMedia(objKlausraeumtauf)
img1.Id = "faa8dc53-4622-491c-9a7c-8609974402e1"
img1.Name = "1"
img1.Description = ""
img1.AltText = ""
img1.Resources = {
	{
		Type = "jpg", 
		Filename = "1.jpg", 
		Directives = {}
	}
}
img2 = Wherigo.ZMedia(objKlausraeumtauf)
img2.Id = "4d567526-f462-440f-a04b-6f557090d187"
img2.Name = "2"
img2.Description = ""
img2.AltText = ""
img2.Resources = {
	{
		Type = "jpg", 
		Filename = "2.jpg", 
		Directives = {}
	}
}
img3 = Wherigo.ZMedia(objKlausraeumtauf)
img3.Id = "90ddead8-7101-4adb-9ead-84d556908ff8"
img3.Name = "3"
img3.Description = ""
img3.AltText = ""
img3.Resources = {
	{
		Type = "jpg", 
		Filename = "3.jpg", 
		Directives = {}
	}
}
img4 = Wherigo.ZMedia(objKlausraeumtauf)
img4.Id = "95488872-b49f-4c56-b266-dfe8bd8b03ad"
img4.Name = "4"
img4.Description = ""
img4.AltText = ""
img4.Resources = {
	{
		Type = "jpg", 
		Filename = "4.jpg", 
		Directives = {}
	}
}
img5 = Wherigo.ZMedia(objKlausraeumtauf)
img5.Id = "865db4a1-59c2-4f10-8a07-a82d06f8b822"
img5.Name = "5"
img5.Description = ""
img5.AltText = ""
img5.Resources = {
	{
		Type = "jpg", 
		Filename = "5.jpg", 
		Directives = {}
	}
}
img6 = Wherigo.ZMedia(objKlausraeumtauf)
img6.Id = "04698fcd-5645-4849-9350-bfa919bc8c49"
img6.Name = "6"
img6.Description = ""
img6.AltText = ""
img6.Resources = {
	{
		Type = "jpg", 
		Filename = "6.jpg", 
		Directives = {}
	}
}
img7 = Wherigo.ZMedia(objKlausraeumtauf)
img7.Id = "29e20ccd-526b-4d4e-9e5d-f24ad21d3718"
img7.Name = "7"
img7.Description = ""
img7.AltText = ""
img7.Resources = {
	{
		Type = "jpg", 
		Filename = "7.jpg", 
		Directives = {}
	}
}
img8 = Wherigo.ZMedia(objKlausraeumtauf)
img8.Id = "ad0aa392-3854-44f6-9fd5-ab22ee195731"
img8.Name = "8"
img8.Description = ""
img8.AltText = ""
img8.Resources = {
	{
		Type = "jpg", 
		Filename = "8.jpg", 
		Directives = {}
	}
}
imgF = Wherigo.ZMedia(objKlausraeumtauf)
imgF.Id = "28eea171-cf82-46de-a169-e81c4c57848a"
imgF.Name = "feldfahne"
imgF.Description = ""
imgF.AltText = ""
imgF.Resources = {
	{
		Type = "jpg", 
		Filename = "f-fahne.jpg", 
		Directives = {}
	}
}
objexplosion = Wherigo.ZMedia(objKlausraeumtauf)
objexplosion.Id = "0285393f-0aa3-4f7b-8f97-2c9623798c9e"
objexplosion.Name = "explosion"
objexplosion.Description = ""
objexplosion.AltText = ""
objexplosion.Resources = {
	{
		Type = "jpg", 
		Filename = "explosion.jpg", 
		Directives = {}
	}
}
obj_explosion = Wherigo.ZMedia(objKlausraeumtauf)
obj_explosion.Id = "2b970ff7-f8f4-4e96-a533-d070a9d61fa1"
obj_explosion.Name = "_explosion"
obj_explosion.Description = ""
obj_explosion.AltText = ""
obj_explosion.Resources = {
	{
		Type = "mp3", 
		Filename = "donner.mp3", 
		Directives = {}
	}
}
obj_tusch = Wherigo.ZMedia(objKlausraeumtauf)
obj_tusch.Id = "37f67fa6-4e34-48e4-adab-dbabb71aa0e3"
obj_tusch.Name = "_tusch"
obj_tusch.Description = ""
obj_tusch.AltText = ""
obj_tusch.Resources = {
	{
		Type = "mp3", 
		Filename = "tusch.mp3", 
		Directives = {}
	}
}
obj_intro = Wherigo.ZMedia(objKlausraeumtauf)
obj_intro.Id = "623a6662-b9a3-468b-9b4d-9a1f2a92d198"
obj_intro.Name = "_intro"
obj_intro.Description = ""
obj_intro.AltText = ""
obj_intro.Resources = {
	{
		Type = "mp3", 
		Filename = "DieserWeg.mp3", 
		Directives = {}
	}
}
objMarkierung = Wherigo.ZMedia(objKlausraeumtauf)
objMarkierung.Id = "f5b5ba89-361d-46aa-94dc-fcd137f71e7e"
objMarkierung.Name = "Markierung"
objMarkierung.Description = ""
objMarkierung.AltText = ""
objMarkierung.Resources = {
	{
		Type = "jpg", 
		Filename = "minenfahne.jpg", 
		Directives = {}
	}
}
objicomarker = Wherigo.ZMedia(objKlausraeumtauf)
objicomarker.Id = "fba0339d-1525-4217-812d-50976e21fa29"
objicomarker.Name = "ico-marker"
objicomarker.Description = ""
objicomarker.AltText = ""
objicomarker.Resources = {
	{
		Type = "jpg", 
		Filename = "ico-minenfahne.jpg", 
		Directives = {}
	}
}
-- Cartridge Info --
objKlausraeumtauf.Id="2f31e031-1948-4846-a30c-d402581411a4"
objKlausraeumtauf.Name="Klaus raeumt auf"
objKlausraeumtauf.Description=[[]]
objKlausraeumtauf.Visible=true
objKlausraeumtauf.Activity="Puzzle"
objKlausraeumtauf.StartingLocationDescription=[[]]
objKlausraeumtauf.StartingLocation = ZonePoint(52.4724067576171,13.1341412959796,0)
objKlausraeumtauf.Version=""
objKlausraeumtauf.Company=""
objKlausraeumtauf.Author="tmz"
objKlausraeumtauf.BuilderVersion="URWIGO 1.22.5798.37755"
objKlausraeumtauf.CreateDate="12/04/2015 21:44:19"
objKlausraeumtauf.PublishDate="1/1/0001 12:00:00 AM"
objKlausraeumtauf.UpdateDate="12/13/2015 15:53:02"
objKlausraeumtauf.LastPlayedDate="1/1/0001 12:00:00 AM"
objKlausraeumtauf.TargetDevice="PocketPC"
objKlausraeumtauf.TargetDeviceVersion="0"
objKlausraeumtauf.StateId="1"
objKlausraeumtauf.CountryId="2"
objKlausraeumtauf.Complete=false
objKlausraeumtauf.UseLogging=true

objKlausraeumtauf.Media=objkartegross

objKlausraeumtauf.Icon=objicoKarte


-- Zones --
z01 = Wherigo.Zone(objKlausraeumtauf)
z01.Id = "61770d63-d3e4-4ae7-b355-f44c2bf5f805"
z01.Name = "1"
z01.Description = ""
z01.Visible = true
z01.Media = objtest
z01.Icon = imgT
z01.Commands = {}
z01.DistanceRange = Distance(-1, "feet")
z01.ShowObjects = "OnEnter"
z01.ProximityRange = Distance(100, "meters")
z01.AllowSetPositionTo = false
z01.Active = false
z01.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z01.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z01.DistanceRangeUOM = "Feet"
z01.ProximityRangeUOM = "Meters"
z01.OutOfRangeName = ""
z01.InRangeName = ""
z02 = Wherigo.Zone(objKlausraeumtauf)
z02.Id = "3cd18b0f-17e6-441b-91b6-976ff2128317"
z02.Name = "2"
z02.Description = ""
z02.Visible = true
z02.Media = objtest
z02.Icon = imgT
z02.Commands = {}
z02.DistanceRange = Distance(-1, "feet")
z02.ShowObjects = "OnEnter"
z02.ProximityRange = Distance(100, "meters")
z02.AllowSetPositionTo = false
z02.Active = false
z02.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z02.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z02.DistanceRangeUOM = "Feet"
z02.ProximityRangeUOM = "Meters"
z02.OutOfRangeName = ""
z02.InRangeName = ""
z49 = Wherigo.Zone(objKlausraeumtauf)
z49.Id = "f6fe16b7-4348-43d6-97f1-e432a28f5249"
z49.Name = "49"
z49.Description = ""
z49.Visible = true
z49.Media = objtest
z49.Icon = imgT
z49.Commands = {}
z49.DistanceRange = Distance(-1, "feet")
z49.ShowObjects = "OnEnter"
z49.ProximityRange = Distance(100, "meters")
z49.AllowSetPositionTo = false
z49.Active = false
z49.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z49.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z49.DistanceRangeUOM = "Feet"
z49.ProximityRangeUOM = "Meters"
z49.OutOfRangeName = ""
z49.InRangeName = ""
z03 = Wherigo.Zone(objKlausraeumtauf)
z03.Id = "09253a92-e512-4ee2-810d-c1d3420f7b32"
z03.Name = "3"
z03.Description = ""
z03.Visible = true
z03.Media = objtest
z03.Icon = imgT
z03.Commands = {}
z03.DistanceRange = Distance(0, "meters")
z03.ShowObjects = "OnEnter"
z03.ProximityRange = Distance(100, "meters")
z03.AllowSetPositionTo = false
z03.Active = false
z03.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z03.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z03.DistanceRangeUOM = "Meters"
z03.ProximityRangeUOM = "Meters"
z03.OutOfRangeName = ""
z03.InRangeName = ""
z48 = Wherigo.Zone(objKlausraeumtauf)
z48.Id = "37083f68-4f27-4c48-8bcf-9feb4abc958a"
z48.Name = "48"
z48.Description = ""
z48.Visible = true
z48.Media = objtest
z48.Icon = imgT
z48.Commands = {}
z48.DistanceRange = Distance(-1, "feet")
z48.ShowObjects = "OnEnter"
z48.ProximityRange = Distance(100, "meters")
z48.AllowSetPositionTo = false
z48.Active = false
z48.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z48.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z48.DistanceRangeUOM = "Feet"
z48.ProximityRangeUOM = "Meters"
z48.OutOfRangeName = ""
z48.InRangeName = ""
z04 = Wherigo.Zone(objKlausraeumtauf)
z04.Id = "4b48e391-5c9a-4553-abe4-7dd49997c158"
z04.Name = "4"
z04.Description = ""
z04.Visible = true
z04.Media = objtest
z04.Icon = imgT
z04.Commands = {}
z04.DistanceRange = Distance(0, "meters")
z04.ShowObjects = "OnEnter"
z04.ProximityRange = Distance(100, "meters")
z04.AllowSetPositionTo = false
z04.Active = false
z04.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z04.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z04.DistanceRangeUOM = "Meters"
z04.ProximityRangeUOM = "Meters"
z04.OutOfRangeName = ""
z04.InRangeName = ""
z47 = Wherigo.Zone(objKlausraeumtauf)
z47.Id = "d83dd3cf-f212-4745-b49c-8c9a15787e1e"
z47.Name = "47"
z47.Description = ""
z47.Visible = true
z47.Media = objtest
z47.Icon = imgT
z47.Commands = {}
z47.DistanceRange = Distance(-1, "feet")
z47.ShowObjects = "OnEnter"
z47.ProximityRange = Distance(100, "meters")
z47.AllowSetPositionTo = false
z47.Active = false
z47.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z47.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z47.DistanceRangeUOM = "Feet"
z47.ProximityRangeUOM = "Meters"
z47.OutOfRangeName = ""
z47.InRangeName = ""
z05 = Wherigo.Zone(objKlausraeumtauf)
z05.Id = "92540e56-9cc9-49b5-84ba-c74af6f9e5aa"
z05.Name = "5"
z05.Description = ""
z05.Visible = true
z05.Media = objtest
z05.Icon = imgT
z05.Commands = {}
z05.DistanceRange = Distance(-1, "feet")
z05.ShowObjects = "OnEnter"
z05.ProximityRange = Distance(100, "meters")
z05.AllowSetPositionTo = false
z05.Active = false
z05.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z05.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z05.DistanceRangeUOM = "Feet"
z05.ProximityRangeUOM = "Meters"
z05.OutOfRangeName = ""
z05.InRangeName = ""
z46 = Wherigo.Zone(objKlausraeumtauf)
z46.Id = "8675eed8-9732-4270-ae71-992771283fa3"
z46.Name = "46"
z46.Description = ""
z46.Visible = true
z46.Media = objtest
z46.Icon = imgT
z46.Commands = {}
z46.DistanceRange = Distance(-1, "feet")
z46.ShowObjects = "OnEnter"
z46.ProximityRange = Distance(100, "meters")
z46.AllowSetPositionTo = false
z46.Active = false
z46.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z46.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z46.DistanceRangeUOM = "Feet"
z46.ProximityRangeUOM = "Meters"
z46.OutOfRangeName = ""
z46.InRangeName = ""
z06 = Wherigo.Zone(objKlausraeumtauf)
z06.Id = "79b385f1-45c2-495d-9c4f-4425032afbe0"
z06.Name = "6"
z06.Description = ""
z06.Visible = true
z06.Media = objtest
z06.Icon = imgT
z06.Commands = {}
z06.DistanceRange = Distance(-1, "feet")
z06.ShowObjects = "OnEnter"
z06.ProximityRange = Distance(100, "meters")
z06.AllowSetPositionTo = false
z06.Active = false
z06.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z06.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z06.DistanceRangeUOM = "Feet"
z06.ProximityRangeUOM = "Meters"
z06.OutOfRangeName = ""
z06.InRangeName = ""
z45 = Wherigo.Zone(objKlausraeumtauf)
z45.Id = "d172febe-e2e7-45a9-9b62-a84f8e4f1532"
z45.Name = "45"
z45.Description = ""
z45.Visible = true
z45.Media = objtest
z45.Icon = imgT
z45.Commands = {}
z45.DistanceRange = Distance(0, "meters")
z45.ShowObjects = "OnEnter"
z45.ProximityRange = Distance(100, "meters")
z45.AllowSetPositionTo = false
z45.Active = false
z45.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z45.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z45.DistanceRangeUOM = "Meters"
z45.ProximityRangeUOM = "Meters"
z45.OutOfRangeName = ""
z45.InRangeName = ""
z07 = Wherigo.Zone(objKlausraeumtauf)
z07.Id = "8219431a-08ae-4c3c-a295-ce96f0e3470b"
z07.Name = "7"
z07.Description = ""
z07.Visible = true
z07.Media = objtest
z07.Icon = imgT
z07.Commands = {}
z07.DistanceRange = Distance(-1, "feet")
z07.ShowObjects = "OnEnter"
z07.ProximityRange = Distance(100, "meters")
z07.AllowSetPositionTo = false
z07.Active = false
z07.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z07.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z07.DistanceRangeUOM = "Feet"
z07.ProximityRangeUOM = "Meters"
z07.OutOfRangeName = ""
z07.InRangeName = ""
z44 = Wherigo.Zone(objKlausraeumtauf)
z44.Id = "23ee5f98-0606-40c1-b5ec-050841b663f9"
z44.Name = "44"
z44.Description = ""
z44.Visible = true
z44.Media = objtest
z44.Icon = imgT
z44.Commands = {}
z44.DistanceRange = Distance(-1, "feet")
z44.ShowObjects = "OnEnter"
z44.ProximityRange = Distance(100, "meters")
z44.AllowSetPositionTo = false
z44.Active = false
z44.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z44.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z44.DistanceRangeUOM = "Feet"
z44.ProximityRangeUOM = "Meters"
z44.OutOfRangeName = ""
z44.InRangeName = ""
z08 = Wherigo.Zone(objKlausraeumtauf)
z08.Id = "cd12e9f5-07bf-4043-8122-fd60d12a2476"
z08.Name = "8"
z08.Description = ""
z08.Visible = true
z08.Media = objtest
z08.Icon = imgT
z08.Commands = {}
z08.DistanceRange = Distance(-1, "feet")
z08.ShowObjects = "OnEnter"
z08.ProximityRange = Distance(100, "meters")
z08.AllowSetPositionTo = false
z08.Active = false
z08.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z08.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z08.DistanceRangeUOM = "Feet"
z08.ProximityRangeUOM = "Meters"
z08.OutOfRangeName = ""
z08.InRangeName = ""
z43 = Wherigo.Zone(objKlausraeumtauf)
z43.Id = "fdc7c427-ed55-476f-8bb3-226117455eda"
z43.Name = "43"
z43.Description = ""
z43.Visible = true
z43.Media = objtest
z43.Icon = imgT
z43.Commands = {}
z43.DistanceRange = Distance(0, "meters")
z43.ShowObjects = "OnEnter"
z43.ProximityRange = Distance(100, "meters")
z43.AllowSetPositionTo = false
z43.Active = false
z43.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z43.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z43.DistanceRangeUOM = "Meters"
z43.ProximityRangeUOM = "Meters"
z43.OutOfRangeName = ""
z43.InRangeName = ""
z09 = Wherigo.Zone(objKlausraeumtauf)
z09.Id = "0623ff84-c685-43d5-b83c-cd3466e3308d"
z09.Name = "9"
z09.Description = ""
z09.Visible = true
z09.Media = objtest
z09.Icon = imgT
z09.Commands = {}
z09.DistanceRange = Distance(-1, "feet")
z09.ShowObjects = "OnEnter"
z09.ProximityRange = Distance(100, "meters")
z09.AllowSetPositionTo = false
z09.Active = false
z09.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z09.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z09.DistanceRangeUOM = "Feet"
z09.ProximityRangeUOM = "Meters"
z09.OutOfRangeName = ""
z09.InRangeName = ""
z42 = Wherigo.Zone(objKlausraeumtauf)
z42.Id = "d517e39f-3b8d-410f-94e8-c2305e7e3ffe"
z42.Name = "42"
z42.Description = ""
z42.Visible = true
z42.Media = objtest
z42.Icon = imgT
z42.Commands = {}
z42.DistanceRange = Distance(-1, "feet")
z42.ShowObjects = "OnEnter"
z42.ProximityRange = Distance(100, "meters")
z42.AllowSetPositionTo = false
z42.Active = false
z42.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z42.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z42.DistanceRangeUOM = "Feet"
z42.ProximityRangeUOM = "Meters"
z42.OutOfRangeName = ""
z42.InRangeName = ""
z10 = Wherigo.Zone(objKlausraeumtauf)
z10.Id = "e05864e2-4dbc-42d1-b428-59a9537b9d53"
z10.Name = "10"
z10.Description = ""
z10.Visible = true
z10.Media = objtest
z10.Icon = imgT
z10.Commands = {}
z10.DistanceRange = Distance(-1, "feet")
z10.ShowObjects = "OnEnter"
z10.ProximityRange = Distance(100, "meters")
z10.AllowSetPositionTo = false
z10.Active = false
z10.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z10.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z10.DistanceRangeUOM = "Feet"
z10.ProximityRangeUOM = "Meters"
z10.OutOfRangeName = ""
z10.InRangeName = ""
z41 = Wherigo.Zone(objKlausraeumtauf)
z41.Id = "8c0fb608-a87a-43c7-9f06-0811868f9a75"
z41.Name = "41"
z41.Description = ""
z41.Visible = true
z41.Media = objtest
z41.Icon = imgT
z41.Commands = {}
z41.DistanceRange = Distance(0, "meters")
z41.ShowObjects = "OnEnter"
z41.ProximityRange = Distance(100, "meters")
z41.AllowSetPositionTo = false
z41.Active = false
z41.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z41.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z41.DistanceRangeUOM = "Meters"
z41.ProximityRangeUOM = "Meters"
z41.OutOfRangeName = ""
z41.InRangeName = ""
z11 = Wherigo.Zone(objKlausraeumtauf)
z11.Id = "1f5a82f2-7bcf-46b7-a973-f6431afd226e"
z11.Name = "11"
z11.Description = ""
z11.Visible = true
z11.Media = objtest
z11.Icon = imgT
z11.Commands = {}
z11.DistanceRange = Distance(-1, "feet")
z11.ShowObjects = "OnEnter"
z11.ProximityRange = Distance(100, "meters")
z11.AllowSetPositionTo = false
z11.Active = false
z11.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z11.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z11.DistanceRangeUOM = "Feet"
z11.ProximityRangeUOM = "Meters"
z11.OutOfRangeName = ""
z11.InRangeName = ""
z40 = Wherigo.Zone(objKlausraeumtauf)
z40.Id = "d708f7c1-1831-4668-abdc-c013bf207522"
z40.Name = "40"
z40.Description = ""
z40.Visible = true
z40.Media = objtest
z40.Icon = imgT
z40.Commands = {}
z40.DistanceRange = Distance(-1, "feet")
z40.ShowObjects = "OnEnter"
z40.ProximityRange = Distance(100, "meters")
z40.AllowSetPositionTo = false
z40.Active = false
z40.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z40.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z40.DistanceRangeUOM = "Feet"
z40.ProximityRangeUOM = "Meters"
z40.OutOfRangeName = ""
z40.InRangeName = ""
z12 = Wherigo.Zone(objKlausraeumtauf)
z12.Id = "dcf232c5-e8c4-4544-8205-b3a321e1907e"
z12.Name = "12"
z12.Description = ""
z12.Visible = true
z12.Media = objtest
z12.Icon = imgT
z12.Commands = {}
z12.DistanceRange = Distance(-1, "feet")
z12.ShowObjects = "OnEnter"
z12.ProximityRange = Distance(100, "meters")
z12.AllowSetPositionTo = false
z12.Active = false
z12.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z12.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z12.DistanceRangeUOM = "Feet"
z12.ProximityRangeUOM = "Meters"
z12.OutOfRangeName = ""
z12.InRangeName = ""
z39 = Wherigo.Zone(objKlausraeumtauf)
z39.Id = "7a240a96-9012-4480-82d0-44da9770d1d8"
z39.Name = "39"
z39.Description = ""
z39.Visible = true
z39.Media = objtest
z39.Icon = imgT
z39.Commands = {}
z39.DistanceRange = Distance(-1, "feet")
z39.ShowObjects = "OnEnter"
z39.ProximityRange = Distance(100, "meters")
z39.AllowSetPositionTo = false
z39.Active = false
z39.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z39.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z39.DistanceRangeUOM = "Feet"
z39.ProximityRangeUOM = "Meters"
z39.OutOfRangeName = ""
z39.InRangeName = ""
z13 = Wherigo.Zone(objKlausraeumtauf)
z13.Id = "d0ffeceb-efea-4a47-a113-75b185c68e39"
z13.Name = "13"
z13.Description = ""
z13.Visible = true
z13.Media = objtest
z13.Icon = imgT
z13.Commands = {}
z13.DistanceRange = Distance(-1, "feet")
z13.ShowObjects = "OnEnter"
z13.ProximityRange = Distance(100, "meters")
z13.AllowSetPositionTo = false
z13.Active = false
z13.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z13.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z13.DistanceRangeUOM = "Feet"
z13.ProximityRangeUOM = "Meters"
z13.OutOfRangeName = ""
z13.InRangeName = ""
z38 = Wherigo.Zone(objKlausraeumtauf)
z38.Id = "1d9fd8e0-de46-4907-a60c-7d195f80e70e"
z38.Name = "38"
z38.Description = ""
z38.Visible = true
z38.Media = objtest
z38.Icon = imgT
z38.Commands = {}
z38.DistanceRange = Distance(-1, "feet")
z38.ShowObjects = "OnEnter"
z38.ProximityRange = Distance(100, "meters")
z38.AllowSetPositionTo = false
z38.Active = false
z38.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z38.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z38.DistanceRangeUOM = "Feet"
z38.ProximityRangeUOM = "Meters"
z38.OutOfRangeName = ""
z38.InRangeName = ""
z14 = Wherigo.Zone(objKlausraeumtauf)
z14.Id = "a16086f4-50b1-4256-bc3a-303c650dc594"
z14.Name = "14"
z14.Description = ""
z14.Visible = true
z14.Media = objtest
z14.Icon = imgT
z14.Commands = {}
z14.DistanceRange = Distance(0, "meters")
z14.ShowObjects = "OnEnter"
z14.ProximityRange = Distance(100, "meters")
z14.AllowSetPositionTo = false
z14.Active = false
z14.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z14.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z14.DistanceRangeUOM = "Meters"
z14.ProximityRangeUOM = "Meters"
z14.OutOfRangeName = ""
z14.InRangeName = ""
z37 = Wherigo.Zone(objKlausraeumtauf)
z37.Id = "184f8565-4034-4d0f-8d93-15c0129a2f9a"
z37.Name = "37"
z37.Description = ""
z37.Visible = true
z37.Media = objtest
z37.Icon = imgT
z37.Commands = {}
z37.DistanceRange = Distance(-1, "feet")
z37.ShowObjects = "OnEnter"
z37.ProximityRange = Distance(100, "meters")
z37.AllowSetPositionTo = false
z37.Active = false
z37.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z37.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z37.DistanceRangeUOM = "Feet"
z37.ProximityRangeUOM = "Meters"
z37.OutOfRangeName = ""
z37.InRangeName = ""
z15 = Wherigo.Zone(objKlausraeumtauf)
z15.Id = "ab9cdb2e-d044-4810-a897-0469da3317d2"
z15.Name = "15"
z15.Description = ""
z15.Visible = true
z15.Media = objtest
z15.Icon = imgT
z15.Commands = {}
z15.DistanceRange = Distance(-1, "feet")
z15.ShowObjects = "OnEnter"
z15.ProximityRange = Distance(100, "meters")
z15.AllowSetPositionTo = false
z15.Active = false
z15.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z15.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z15.DistanceRangeUOM = "Feet"
z15.ProximityRangeUOM = "Meters"
z15.OutOfRangeName = ""
z15.InRangeName = ""
z36 = Wherigo.Zone(objKlausraeumtauf)
z36.Id = "7d60bd66-ae6a-496a-816f-1f89695b2914"
z36.Name = "36"
z36.Description = ""
z36.Visible = true
z36.Media = objtest
z36.Icon = imgT
z36.Commands = {}
z36.DistanceRange = Distance(-1, "feet")
z36.ShowObjects = "OnEnter"
z36.ProximityRange = Distance(100, "meters")
z36.AllowSetPositionTo = false
z36.Active = false
z36.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z36.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z36.DistanceRangeUOM = "Feet"
z36.ProximityRangeUOM = "Meters"
z36.OutOfRangeName = ""
z36.InRangeName = ""
z16 = Wherigo.Zone(objKlausraeumtauf)
z16.Id = "d66a4dab-b6fe-4254-9148-8f2955bbb4c4"
z16.Name = "16"
z16.Description = ""
z16.Visible = true
z16.Media = objtest
z16.Icon = imgT
z16.Commands = {}
z16.DistanceRange = Distance(0, "meters")
z16.ShowObjects = "OnEnter"
z16.ProximityRange = Distance(100, "meters")
z16.AllowSetPositionTo = false
z16.Active = false
z16.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z16.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z16.DistanceRangeUOM = "Meters"
z16.ProximityRangeUOM = "Meters"
z16.OutOfRangeName = ""
z16.InRangeName = ""
z35 = Wherigo.Zone(objKlausraeumtauf)
z35.Id = "83393bad-8a45-4ab3-9755-a762e9b4f056"
z35.Name = "35"
z35.Description = ""
z35.Visible = true
z35.Media = objtest
z35.Icon = imgT
z35.Commands = {}
z35.DistanceRange = Distance(-1, "feet")
z35.ShowObjects = "OnEnter"
z35.ProximityRange = Distance(100, "meters")
z35.AllowSetPositionTo = false
z35.Active = false
z35.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z35.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z35.DistanceRangeUOM = "Feet"
z35.ProximityRangeUOM = "Meters"
z35.OutOfRangeName = ""
z35.InRangeName = ""
z17 = Wherigo.Zone(objKlausraeumtauf)
z17.Id = "61bb6b4f-3582-4e23-a582-18819ea4a550"
z17.Name = "17"
z17.Description = ""
z17.Visible = true
z17.Media = objtest
z17.Icon = imgT
z17.Commands = {}
z17.DistanceRange = Distance(-1, "feet")
z17.ShowObjects = "OnEnter"
z17.ProximityRange = Distance(0, "meters")
z17.AllowSetPositionTo = false
z17.Active = false
z17.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z17.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z17.DistanceRangeUOM = "Feet"
z17.ProximityRangeUOM = "Meters"
z17.OutOfRangeName = ""
z17.InRangeName = ""
z34 = Wherigo.Zone(objKlausraeumtauf)
z34.Id = "1232e10c-372f-43fc-b452-f11e946f9613"
z34.Name = "34"
z34.Description = ""
z34.Visible = true
z34.Media = objtest
z34.Icon = imgT
z34.Commands = {}
z34.DistanceRange = Distance(-1, "feet")
z34.ShowObjects = "OnEnter"
z34.ProximityRange = Distance(100, "meters")
z34.AllowSetPositionTo = false
z34.Active = false
z34.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z34.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z34.DistanceRangeUOM = "Feet"
z34.ProximityRangeUOM = "Meters"
z34.OutOfRangeName = ""
z34.InRangeName = ""
z18 = Wherigo.Zone(objKlausraeumtauf)
z18.Id = "94f9effa-2902-4ac6-9677-9949343b63e2"
z18.Name = "18"
z18.Description = ""
z18.Visible = true
z18.Media = objtest
z18.Icon = imgT
z18.Commands = {}
z18.DistanceRange = Distance(0, "meters")
z18.ShowObjects = "OnEnter"
z18.ProximityRange = Distance(100, "meters")
z18.AllowSetPositionTo = false
z18.Active = false
z18.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z18.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z18.DistanceRangeUOM = "Meters"
z18.ProximityRangeUOM = "Meters"
z18.OutOfRangeName = ""
z18.InRangeName = ""
z33 = Wherigo.Zone(objKlausraeumtauf)
z33.Id = "588d0d25-3b4d-4bdb-9476-2c5019539659"
z33.Name = "33"
z33.Description = ""
z33.Visible = true
z33.Media = objtest
z33.Icon = imgT
z33.Commands = {}
z33.DistanceRange = Distance(-1, "feet")
z33.ShowObjects = "OnEnter"
z33.ProximityRange = Distance(100, "meters")
z33.AllowSetPositionTo = false
z33.Active = false
z33.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z33.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z33.DistanceRangeUOM = "Feet"
z33.ProximityRangeUOM = "Meters"
z33.OutOfRangeName = ""
z33.InRangeName = ""
z19 = Wherigo.Zone(objKlausraeumtauf)
z19.Id = "3e1871e1-895d-4c56-a936-82fbf0e63441"
z19.Name = "19"
z19.Description = ""
z19.Visible = true
z19.Media = objtest
z19.Icon = imgT
z19.Commands = {}
z19.DistanceRange = Distance(-1, "feet")
z19.ShowObjects = "OnEnter"
z19.ProximityRange = Distance(100, "meters")
z19.AllowSetPositionTo = false
z19.Active = false
z19.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z19.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z19.DistanceRangeUOM = "Feet"
z19.ProximityRangeUOM = "Meters"
z19.OutOfRangeName = ""
z19.InRangeName = ""
z32 = Wherigo.Zone(objKlausraeumtauf)
z32.Id = "288f6520-b009-4f1b-806f-8f270d8afd9e"
z32.Name = "32"
z32.Description = ""
z32.Visible = true
z32.Media = objtest
z32.Icon = imgT
z32.Commands = {}
z32.DistanceRange = Distance(-1, "feet")
z32.ShowObjects = "OnEnter"
z32.ProximityRange = Distance(100, "meters")
z32.AllowSetPositionTo = false
z32.Active = false
z32.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z32.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z32.DistanceRangeUOM = "Feet"
z32.ProximityRangeUOM = "Meters"
z32.OutOfRangeName = ""
z32.InRangeName = ""
z20 = Wherigo.Zone(objKlausraeumtauf)
z20.Id = "eb1f81ba-fb2e-4bbd-a275-ecede39a1ca8"
z20.Name = "20"
z20.Description = ""
z20.Visible = true
z20.Media = objtest
z20.Icon = imgT
z20.Commands = {}
z20.DistanceRange = Distance(0, "meters")
z20.ShowObjects = "OnEnter"
z20.ProximityRange = Distance(100, "meters")
z20.AllowSetPositionTo = false
z20.Active = false
z20.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z20.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z20.DistanceRangeUOM = "Meters"
z20.ProximityRangeUOM = "Meters"
z20.OutOfRangeName = ""
z20.InRangeName = ""
z31 = Wherigo.Zone(objKlausraeumtauf)
z31.Id = "7b8cb6d3-d200-46ac-ad0f-8176a2118c2b"
z31.Name = "31"
z31.Description = ""
z31.Visible = true
z31.Media = objtest
z31.Icon = imgT
z31.Commands = {}
z31.DistanceRange = Distance(-1, "feet")
z31.ShowObjects = "OnEnter"
z31.ProximityRange = Distance(100, "meters")
z31.AllowSetPositionTo = false
z31.Active = false
z31.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z31.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z31.DistanceRangeUOM = "Feet"
z31.ProximityRangeUOM = "Meters"
z31.OutOfRangeName = ""
z31.InRangeName = ""
z21 = Wherigo.Zone(objKlausraeumtauf)
z21.Id = "d5ae668a-553f-426d-a8b8-55aa778ad4c6"
z21.Name = "21"
z21.Description = ""
z21.Visible = true
z21.Media = objtest
z21.Icon = imgT
z21.Commands = {}
z21.DistanceRange = Distance(-1, "feet")
z21.ShowObjects = "OnEnter"
z21.ProximityRange = Distance(100, "meters")
z21.AllowSetPositionTo = false
z21.Active = false
z21.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z21.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z21.DistanceRangeUOM = "Feet"
z21.ProximityRangeUOM = "Meters"
z21.OutOfRangeName = ""
z21.InRangeName = ""
z30 = Wherigo.Zone(objKlausraeumtauf)
z30.Id = "526a5aa0-5b74-4308-9c7a-0513c4ede4e3"
z30.Name = "30"
z30.Description = ""
z30.Visible = true
z30.Media = objtest
z30.Icon = imgT
z30.Commands = {}
z30.DistanceRange = Distance(-1, "feet")
z30.ShowObjects = "OnEnter"
z30.ProximityRange = Distance(100, "meters")
z30.AllowSetPositionTo = false
z30.Active = false
z30.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z30.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z30.DistanceRangeUOM = "Feet"
z30.ProximityRangeUOM = "Meters"
z30.OutOfRangeName = ""
z30.InRangeName = ""
z22 = Wherigo.Zone(objKlausraeumtauf)
z22.Id = "e7062c69-bc01-4420-a4ba-543657eca540"
z22.Name = "22"
z22.Description = ""
z22.Visible = true
z22.Media = objtest
z22.Icon = imgT
z22.Commands = {}
z22.DistanceRange = Distance(-1, "feet")
z22.ShowObjects = "OnEnter"
z22.ProximityRange = Distance(100, "meters")
z22.AllowSetPositionTo = false
z22.Active = false
z22.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z22.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z22.DistanceRangeUOM = "Feet"
z22.ProximityRangeUOM = "Meters"
z22.OutOfRangeName = ""
z22.InRangeName = ""
z29 = Wherigo.Zone(objKlausraeumtauf)
z29.Id = "d9b3bda9-927e-4ec1-8c90-98535d88efa8"
z29.Name = "29"
z29.Description = ""
z29.Visible = true
z29.Media = objtest
z29.Icon = imgT
z29.Commands = {}
z29.DistanceRange = Distance(-1, "feet")
z29.ShowObjects = "OnEnter"
z29.ProximityRange = Distance(100, "meters")
z29.AllowSetPositionTo = false
z29.Active = false
z29.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z29.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z29.DistanceRangeUOM = "Feet"
z29.ProximityRangeUOM = "Meters"
z29.OutOfRangeName = ""
z29.InRangeName = ""
z23 = Wherigo.Zone(objKlausraeumtauf)
z23.Id = "775bca84-2205-4012-88ef-0a75b27e51e1"
z23.Name = "23"
z23.Description = ""
z23.Visible = true
z23.Media = objtest
z23.Icon = imgT
z23.Commands = {}
z23.DistanceRange = Distance(-1, "feet")
z23.ShowObjects = "OnEnter"
z23.ProximityRange = Distance(100, "meters")
z23.AllowSetPositionTo = false
z23.Active = false
z23.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z23.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z23.DistanceRangeUOM = "Feet"
z23.ProximityRangeUOM = "Meters"
z23.OutOfRangeName = ""
z23.InRangeName = ""
z28 = Wherigo.Zone(objKlausraeumtauf)
z28.Id = "28cac515-c83e-4882-92b2-2711ee762e78"
z28.Name = "28"
z28.Description = ""
z28.Visible = true
z28.Media = objtest
z28.Icon = imgT
z28.Commands = {}
z28.DistanceRange = Distance(-1, "feet")
z28.ShowObjects = "OnEnter"
z28.ProximityRange = Distance(100, "meters")
z28.AllowSetPositionTo = false
z28.Active = false
z28.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z28.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z28.DistanceRangeUOM = "Feet"
z28.ProximityRangeUOM = "Meters"
z28.OutOfRangeName = ""
z28.InRangeName = ""
z24 = Wherigo.Zone(objKlausraeumtauf)
z24.Id = "213318ca-a30b-47ce-86c6-60b3d12ca107"
z24.Name = "24"
z24.Description = ""
z24.Visible = true
z24.Media = objtest
z24.Icon = imgT
z24.Commands = {}
z24.DistanceRange = Distance(0, "meters")
z24.ShowObjects = "OnEnter"
z24.ProximityRange = Distance(100, "meters")
z24.AllowSetPositionTo = false
z24.Active = false
z24.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z24.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z24.DistanceRangeUOM = "Meters"
z24.ProximityRangeUOM = "Meters"
z24.OutOfRangeName = ""
z24.InRangeName = ""
z27 = Wherigo.Zone(objKlausraeumtauf)
z27.Id = "cbaf7164-aa6b-466a-9e4a-51c9aee356fc"
z27.Name = "27"
z27.Description = ""
z27.Visible = true
z27.Media = objtest
z27.Icon = imgT
z27.Commands = {}
z27.DistanceRange = Distance(-1, "feet")
z27.ShowObjects = "OnEnter"
z27.ProximityRange = Distance(100, "meters")
z27.AllowSetPositionTo = false
z27.Active = false
z27.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z27.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z27.DistanceRangeUOM = "Feet"
z27.ProximityRangeUOM = "Meters"
z27.OutOfRangeName = ""
z27.InRangeName = ""
z25 = Wherigo.Zone(objKlausraeumtauf)
z25.Id = "05fd0248-eefc-4b41-b2cf-680304259fec"
z25.Name = "25"
z25.Description = ""
z25.Visible = true
z25.Media = objtest
z25.Icon = imgT
z25.Commands = {}
z25.DistanceRange = Distance(-1, "feet")
z25.ShowObjects = "OnEnter"
z25.ProximityRange = Distance(100, "meters")
z25.AllowSetPositionTo = false
z25.Active = false
z25.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z25.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z25.DistanceRangeUOM = "Feet"
z25.ProximityRangeUOM = "Meters"
z25.OutOfRangeName = ""
z25.InRangeName = ""
z26 = Wherigo.Zone(objKlausraeumtauf)
z26.Id = "f01e5781-4b60-4f83-9f6d-794b8abc3225"
z26.Name = "26"
z26.Description = ""
z26.Visible = true
z26.Media = objtest
z26.Icon = imgT
z26.Commands = {}
z26.DistanceRange = Distance(0, "meters")
z26.ShowObjects = "OnEnter"
z26.ProximityRange = Distance(100, "meters")
z26.AllowSetPositionTo = false
z26.Active = false
z26.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z26.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z26.DistanceRangeUOM = "Meters"
z26.ProximityRangeUOM = "Meters"
z26.OutOfRangeName = ""
z26.InRangeName = ""
final = Wherigo.Zone(objKlausraeumtauf)
final.Id = "10d55db4-3a9c-475d-aa2d-696a1ea9be6e"
final.Name = "Final"
final.Description = ""
final.Visible = false
final.Commands = {}
final.DistanceRange = Distance(-1, "feet")
final.ShowObjects = "OnEnter"
final.ProximityRange = Distance(60, "meters")
final.AllowSetPositionTo = false
final.Active = false
final.Points = {
	ZonePoint(52.4788346075238, 13.1547599124275, 0), 
	ZonePoint(52.4786108650691, 13.1547330324707, 0), 
	ZonePoint(52.4786272365068, 13.1550197520102, 0), 
	ZonePoint(52.4788182361633, 13.1550107920244, 0)
}
final.OriginalPoint = ZonePoint(52.4787227363158, 13.1548808722332, 0)
final.DistanceRangeUOM = "Feet"
final.ProximityRangeUOM = "Meters"
final.OutOfRangeName = ""
final.InRangeName = ""

-- Characters --

-- Items --
objMinesweeper = Wherigo.ZItem{
	Cartridge = objKlausraeumtauf, 
	Container = Player
}
objMinesweeper.Id = "3752f428-e9b1-41f2-8458-9b7ec9016860"
objMinesweeper.Name = "Minesweeper"
objMinesweeper.Description = [[Aufaeumen der besonderen Art. 
Aber Vorsicht - nicht zuviel Staub aufwirbeln,]]
objMinesweeper.Visible = true
objMinesweeper.Media = objkartegross
objMinesweeper.Icon = objicoKarte
objMinesweeper.Commands = {
	cmdspielen = Wherigo.ZCommand{
		Text = "spielen", 
		CmdWith = false, 
		Enabled = true, 
		EmptyTargetListText = "Nothing available"
	}
}
objMinesweeper.Commands.cmdspielen.Custom = true
objMinesweeper.Commands.cmdspielen.Id = "9495b409-1e08-4330-8c24-159ade793b46"
objMinesweeper.Commands.cmdspielen.WorksWithAll = true
objMinesweeper.ObjectLocation = Wherigo.INVALID_ZONEPOINT
objMinesweeper.Locked = false
objMinesweeper.Opened = false
objSpoiler1 = Wherigo.ZItem{
	Cartridge = objKlausraeumtauf, 
	Container = Player
}
objSpoiler1.Id = "9ec13d3e-937c-4074-b061-c672f38f58b7"
objSpoiler1.Name = "Spoiler"
objSpoiler1.Description = ""
objSpoiler1.Visible = false
objSpoiler1.Media = objSpoiler
objSpoiler1.Icon = objicoSpoiler
objSpoiler1.Commands = {}
objSpoiler1.ObjectLocation = Wherigo.INVALID_ZONEPOINT
objSpoiler1.Locked = false
objSpoiler1.Opened = false
objKoordinaten1 = Wherigo.ZItem{
	Cartridge = objKlausraeumtauf, 
	Container = Player
}
objKoordinaten1.Id = "00e356b7-de82-4633-8e4f-bbadf36381c6"
objKoordinaten1.Name = "Koordinaten"
objKoordinaten1.Description = "Jetzt auf zum Ziel!"
objKoordinaten1.Visible = false
objKoordinaten1.Media = objKoordinaten
objKoordinaten1.Icon = objicoKoordinaten
objKoordinaten1.Commands = {}
objKoordinaten1.ObjectLocation = Wherigo.INVALID_ZONEPOINT
objKoordinaten1.Locked = false
objKoordinaten1.Opened = false
objFreischaltcode1 = Wherigo.ZItem{
	Cartridge = objKlausraeumtauf, 
	Container = Player
}
objFreischaltcode1.Id = "41663d78-84bd-43ee-ba82-c58c6dd20359"
objFreischaltcode1.Name = "Freischaltcode"
objFreischaltcode1.Description = ""
objFreischaltcode1.Visible = false
objFreischaltcode1.Media = objFreischaltcode
objFreischaltcode1.Icon = objicoFreischaltcode
objFreischaltcode1.Commands = {}
objFreischaltcode1.ObjectLocation = Wherigo.INVALID_ZONEPOINT
objFreischaltcode1.Locked = false
objFreischaltcode1.Opened = false
objAnleitung1 = Wherigo.ZItem{
	Cartridge = objKlausraeumtauf, 
	Container = Player
}
objAnleitung1.Id = "baa9982e-576d-4945-afa1-1ae47e186a8c"
objAnleitung1.Name = "Anleitung"
objAnleitung1.Description = "Minenraeumen im vorbeigehen - oder auch aufraeumen der anderen Art"
objAnleitung1.Visible = true
objAnleitung1.Media = objAnleitung
objAnleitung1.Icon = objicoAnleitung
objAnleitung1.Commands = {
	cmdlesen = Wherigo.ZCommand{
		Text = "lesen", 
		CmdWith = false, 
		Enabled = true, 
		EmptyTargetListText = "Nothing available"
	}
}
objAnleitung1.Commands.cmdlesen.Custom = true
objAnleitung1.Commands.cmdlesen.Id = "7aa0d22f-99db-4013-ae7f-36431909201d"
objAnleitung1.Commands.cmdlesen.WorksWithAll = true
objAnleitung1.ObjectLocation = Wherigo.INVALID_ZONEPOINT
objAnleitung1.Locked = false
objAnleitung1.Opened = false
objKarte = Wherigo.ZItem{
	Cartridge = objKlausraeumtauf, 
	Container = Player
}
objKarte.Id = "f9c949f0-a07f-4aa1-b2c2-7d8787910d54"
objKarte.Name = "Karte"
objKarte.Description = ""
objKarte.Visible = false
objKarte.Icon = objicoKarte
objKarte.Commands = {}
objKarte.ObjectLocation = Wherigo.INVALID_ZONEPOINT
objKarte.Locked = false
objKarte.Opened = false
aktuellesFeld = Wherigo.ZItem{
	Cartridge = objKlausraeumtauf, 
	Container = Player
}
aktuellesFeld.Id = "4875c902-4914-4ef7-8281-68962ff7ef57"
aktuellesFeld.Name = "aktuelles Feld"
aktuellesFeld.Description = ""
aktuellesFeld.Visible = false
aktuellesFeld.Media = objtest
aktuellesFeld.Icon = imgT
aktuellesFeld.Commands = {
	cmdsetzenFahne = Wherigo.ZCommand{
		Text = "setzen Fahne", 
		CmdWith = false, 
		Enabled = true, 
		EmptyTargetListText = "Nothing available"
	}, 
	cmdnehmenFahne = Wherigo.ZCommand{
		Text = "nehmen Fahne", 
		CmdWith = false, 
		Enabled = false, 
		EmptyTargetListText = "Nothing available"
	}, 
	cmdaufdecken = Wherigo.ZCommand{
		Text = "aufdecken", 
		CmdWith = false, 
		Enabled = true, 
		EmptyTargetListText = "Nothing available"
	}
}
aktuellesFeld.Commands.cmdsetzenFahne.Custom = true
aktuellesFeld.Commands.cmdsetzenFahne.Id = "45d7634b-1d50-4f51-8876-9b178ed34062"
aktuellesFeld.Commands.cmdsetzenFahne.WorksWithAll = true
aktuellesFeld.Commands.cmdnehmenFahne.Custom = true
aktuellesFeld.Commands.cmdnehmenFahne.Id = "b6d9b180-3484-44dd-a6bd-cb5c712fac79"
aktuellesFeld.Commands.cmdnehmenFahne.WorksWithAll = true
aktuellesFeld.Commands.cmdaufdecken.Custom = true
aktuellesFeld.Commands.cmdaufdecken.Id = "70fb21ea-40cb-4a3a-b332-b6a566f78c6c"
aktuellesFeld.Commands.cmdaufdecken.WorksWithAll = true
aktuellesFeld.ObjectLocation = Wherigo.INVALID_ZONEPOINT
aktuellesFeld.Locked = false
aktuellesFeld.Opened = false
objMarkierungsfahne = Wherigo.ZItem{
	Cartridge = objKlausraeumtauf, 
	Container = Player
}
objMarkierungsfahne.Id = "2611a5fe-fde7-4eb8-a92c-342516620f5f"
objMarkierungsfahne.Name = "Markierungsfahne"
objMarkierungsfahne.Description = "Du hast noch 10 Fahnen"
objMarkierungsfahne.Visible = false
objMarkierungsfahne.Media = objfahne
objMarkierungsfahne.Icon = objicofahne
objMarkierungsfahne.Commands = {
	cmdsetzen = Wherigo.ZCommand{
		Text = "setzen", 
		CmdWith = false, 
		Enabled = true, 
		EmptyTargetListText = "Nothing available"
	}, 
	cmdnehmen = Wherigo.ZCommand{
		Text = "nehmen", 
		CmdWith = false, 
		Enabled = false, 
		EmptyTargetListText = "Nothing available"
	}
}
objMarkierungsfahne.Commands.cmdsetzen.Custom = true
objMarkierungsfahne.Commands.cmdsetzen.Id = "11b38baf-97a8-4b2a-a55e-9576eb407023"
objMarkierungsfahne.Commands.cmdsetzen.WorksWithAll = true
objMarkierungsfahne.Commands.cmdnehmen.Custom = true
objMarkierungsfahne.Commands.cmdnehmen.Id = "d2376fbb-efff-4b45-874a-2f657f19e525"
objMarkierungsfahne.Commands.cmdnehmen.WorksWithAll = true
objMarkierungsfahne.ObjectLocation = Wherigo.INVALID_ZONEPOINT
objMarkierungsfahne.Locked = false
objMarkierungsfahne.Opened = false
objMarkierung1 = Wherigo.ZItem(objKlausraeumtauf)
objMarkierung1.Id = "5484bd91-caa6-4ef3-b038-0c84bd34a613"
objMarkierung1.Name = "Markierung"
objMarkierung1.Description = [[Hier sollte also eine Mine sein.
Also nicht aufdecken!]]
objMarkierung1.Visible = true
objMarkierung1.Media = objMarkierung
objMarkierung1.Icon = objicomarker
objMarkierung1.Commands = {
	cmdnehmen = Wherigo.ZCommand{
		Text = "nehmen", 
		CmdWith = false, 
		Enabled = false, 
		EmptyTargetListText = "Nothing available"
	}
}
objMarkierung1.Commands.cmdnehmen.Custom = true
objMarkierung1.Commands.cmdnehmen.Id = "8436e692-028a-410d-8ae4-5523d12d32b1"
objMarkierung1.Commands.cmdnehmen.WorksWithAll = true
objMarkierung1.ObjectLocation = Wherigo.INVALID_ZONEPOINT
objMarkierung1.Locked = false
objMarkierung1.Opened = false

-- Tasks --
objspieleMinesweeper = Wherigo.ZTask(objKlausraeumtauf)
objspieleMinesweeper.Id = "02f55d20-fe8a-4d7c-a17f-a41b2405d6ca"
objspieleMinesweeper.Name = "spiele Minesweeper"
objspieleMinesweeper.Description = ""
objspieleMinesweeper.Visible = true
objspieleMinesweeper.Active = true
objspieleMinesweeper.Complete = false
objspieleMinesweeper.CorrectState = "None"
objraeumeauf = Wherigo.ZTask(objKlausraeumtauf)
objraeumeauf.Id = "d19d030e-55b5-4954-b1b7-c9d1ec0b9c3b"
objraeumeauf.Name = "raeume auf"
objraeumeauf.Description = ""
objraeumeauf.Visible = false
objraeumeauf.Active = true
objraeumeauf.Complete = false
objraeumeauf.CorrectState = "None"
objtrageDichinsLogbuchein = Wherigo.ZTask(objKlausraeumtauf)
objtrageDichinsLogbuchein.Id = "3f743bd1-cb50-4b99-9952-d9d25681a1a9"
objtrageDichinsLogbuchein.Name = "trage Dich ins Logbuch ein"
objtrageDichinsLogbuchein.Description = ""
objtrageDichinsLogbuchein.Visible = false
objtrageDichinsLogbuchein.Active = true
objtrageDichinsLogbuchein.Complete = false
objtrageDichinsLogbuchein.CorrectState = "None"

-- Cartridge Variables --
iMinen = 10
iFahnen = 10
iZone = 25
bFlag = false
bMine = false
iSeed = 0
s0 = "     |  1 |  2 |  3 |  4 |  5 |  6 |  7"
sZ = "----------------------------------------"
s1 = ""
s5 = ""
s4 = ""
s2 = ""
s3 = ""
s6 = ""
s7 = ""
objsT = "Aktuelle Position: 4, 4"
iFeldMine = 0
bLoesung = false
sZone = "xx"
x = 0
y = 0
iTimeStart = 0
iTimeStop = 0
objsCR = [[
]]
objiStd = 0
objiMin = 0
objiSek = 0
objbFirst = true
currentZone = "z01"
currentCharacter = "dummy"
currentItem = "objMinesweeper"
currentTask = "objspieleMinesweeper"
currentInput = "dummy"
currentTimer = "objName"
objKlausraeumtauf.ZVariables = {
	iMinen = 10, 
	iFahnen = 10, 
	iZone = 25, 
	bFlag = false, 
	bMine = false, 
	iSeed = 0, 
	s0 = "     |  1 |  2 |  3 |  4 |  5 |  6 |  7", 
	sZ = "----------------------------------------", 
	s1 = "", 
	s5 = "", 
	s4 = "", 
	s2 = "", 
	s3 = "", 
	s6 = "", 
	s7 = "", 
	objsT = "Aktuelle Position: 4, 4", 
	iFeldMine = 0, 
	bLoesung = false, 
	sZone = "xx", 
	x = 0, 
	y = 0, 
	iTimeStart = 0, 
	iTimeStop = 0, 
	objsCR = [[
]], 
	objiStd = 0, 
	objiMin = 0, 
	objiSek = 0, 
	objbFirst = true, 
	currentZone = "z01", 
	currentCharacter = "dummy", 
	currentItem = "objMinesweeper", 
	currentTask = "objspieleMinesweeper", 
	currentInput = "dummy", 
	currentTimer = "objName"
}

-- Timers --
objName = Wherigo.ZTimer(objKlausraeumtauf)
objName.Id = "41b5e123-8fd0-4591-9b86-e0cbc850738e"
objName.Name = "Name"
objName.Description = ""
objName.Visible = true
objName.Duration = 0
objName.Type = "Countdown"

-- Inputs --

-- WorksWithList for object commands --

-- functions --
function objKlausraeumtauf:OnStart()
	local _Urwigo_Date = os.date "*t"
	iZone = 25
	iSeed = _Urwigo.Date_SecondInHour(_Urwigo_Date)
	initZufall()
	
	_Urwigo.OldDialog{
		{
			Text = [[Du willst mir beim aufaeumen helfen? Das finde ich super.

Es ist ganz einfach. In meinem Zimmer sind 10 Dinge versteckt, die ich unbedingt wegraeumen muss. Wenn Du glaubst, eines gefunden zu haben, setze eine Fahne.
Wenn Du alle Fahnen gesetzt hast, lade ich Dich auf einen Drink ein. 
Wenn nicht, dann halt nicht.]], 
			Media = objKlaus
		}, 
		{
			Text = [[Falls Dir etwas unklar ist, lies einfach nochmal die Anleitung durch.

Und ich wuerde mich wirklich freuen, wenn Du mir beim aufaeumen hefen wuerdest!]], 
			Media = objKlaus
		}
	}
end
function objKlausraeumtauf:OnRestore()
end
function z01:OnEnter()
	currentZone = "z01"
	_Urwigo.GlobalZoneEnter()
end
function z02:OnEnter()
	currentZone = "z02"
	_Urwigo.GlobalZoneEnter()
end
function z49:OnEnter()
	currentZone = "z49"
	_Urwigo.GlobalZoneEnter()
end
function z03:OnEnter()
	currentZone = "z03"
	_Urwigo.GlobalZoneEnter()
end
function z48:OnEnter()
	currentZone = "z48"
	_Urwigo.GlobalZoneEnter()
end
function z04:OnEnter()
	currentZone = "z04"
	_Urwigo.GlobalZoneEnter()
end
function z47:OnEnter()
	currentZone = "z47"
	_Urwigo.GlobalZoneEnter()
end
function z05:OnEnter()
	currentZone = "z05"
	_Urwigo.GlobalZoneEnter()
end
function z46:OnEnter()
	currentZone = "z46"
	_Urwigo.GlobalZoneEnter()
end
function z06:OnEnter()
	currentZone = "z06"
	_Urwigo.GlobalZoneEnter()
end
function z45:OnEnter()
	currentZone = "z45"
	_Urwigo.GlobalZoneEnter()
end
function z07:OnEnter()
	currentZone = "z07"
	_Urwigo.GlobalZoneEnter()
end
function z44:OnEnter()
	currentZone = "z44"
	_Urwigo.GlobalZoneEnter()
end
function z08:OnEnter()
	currentZone = "z08"
	_Urwigo.GlobalZoneEnter()
end
function z43:OnEnter()
	currentZone = "z43"
	_Urwigo.GlobalZoneEnter()
end
function z09:OnEnter()
	currentZone = "z09"
	_Urwigo.GlobalZoneEnter()
end
function z42:OnEnter()
	currentZone = "z42"
	_Urwigo.GlobalZoneEnter()
end
function z10:OnEnter()
	currentZone = "z10"
	_Urwigo.GlobalZoneEnter()
end
function z41:OnEnter()
	currentZone = "z41"
	_Urwigo.GlobalZoneEnter()
end
function z11:OnEnter()
	currentZone = "z11"
	_Urwigo.GlobalZoneEnter()
end
function z40:OnEnter()
	currentZone = "z40"
	_Urwigo.GlobalZoneEnter()
end
function z12:OnEnter()
	currentZone = "z12"
	_Urwigo.GlobalZoneEnter()
end
function z39:OnEnter()
	currentZone = "z39"
	_Urwigo.GlobalZoneEnter()
end
function z13:OnEnter()
	currentZone = "z13"
	_Urwigo.GlobalZoneEnter()
end
function z38:OnEnter()
	currentZone = "z38"
	_Urwigo.GlobalZoneEnter()
end
function z14:OnEnter()
	currentZone = "z14"
	_Urwigo.GlobalZoneEnter()
end
function z37:OnEnter()
	currentZone = "z37"
	_Urwigo.GlobalZoneEnter()
end
function z15:OnEnter()
	currentZone = "z15"
	_Urwigo.GlobalZoneEnter()
end
function z36:OnEnter()
	currentZone = "z36"
	_Urwigo.GlobalZoneEnter()
end
function z16:OnEnter()
	currentZone = "z16"
	_Urwigo.GlobalZoneEnter()
end
function z35:OnEnter()
	currentZone = "z35"
	_Urwigo.GlobalZoneEnter()
end
function z17:OnEnter()
	currentZone = "z17"
	_Urwigo.GlobalZoneEnter()
end
function z34:OnEnter()
	currentZone = "z34"
	_Urwigo.GlobalZoneEnter()
end
function z18:OnEnter()
	currentZone = "z18"
	_Urwigo.GlobalZoneEnter()
end
function z33:OnEnter()
	currentZone = "z33"
	_Urwigo.GlobalZoneEnter()
end
function z19:OnEnter()
	currentZone = "z19"
	_Urwigo.GlobalZoneEnter()
end
function z32:OnEnter()
	currentZone = "z32"
	_Urwigo.GlobalZoneEnter()
end
function z20:OnEnter()
	currentZone = "z20"
	_Urwigo.GlobalZoneEnter()
end
function z31:OnEnter()
	currentZone = "z31"
	_Urwigo.GlobalZoneEnter()
end
function z21:OnEnter()
	currentZone = "z21"
	_Urwigo.GlobalZoneEnter()
end
function z30:OnEnter()
	currentZone = "z30"
	_Urwigo.GlobalZoneEnter()
end
function z22:OnEnter()
	currentZone = "z22"
	_Urwigo.GlobalZoneEnter()
end
function z29:OnEnter()
	currentZone = "z29"
	_Urwigo.GlobalZoneEnter()
end
function z23:OnEnter()
	currentZone = "z23"
	_Urwigo.GlobalZoneEnter()
end
function z28:OnEnter()
	currentZone = "z28"
	_Urwigo.GlobalZoneEnter()
end
function z24:OnEnter()
	currentZone = "z24"
	_Urwigo.GlobalZoneEnter()
end
function z27:OnEnter()
	currentZone = "z27"
	_Urwigo.GlobalZoneEnter()
end
function z25:OnEnter()
	currentZone = "z25"
	_Urwigo.GlobalZoneEnter()
end
function z26:OnEnter()
	currentZone = "z26"
	_Urwigo.GlobalZoneEnter()
end
function final:OnEnter()
	currentZone = "final"
	_Urwigo.GlobalZoneEnter()
end
function objMinesweeper:Oncmdspielen(target)
	Wherigo.PlayAudio(obj_intro)
	
	objMinesweeper.Commands.cmdspielen.Enabled = false
	objMarkierungsfahne.Visible = true
	_Urwigo.MessageBox{
		Text = Player.Name..", Du willst mir helfen? Warte - ich schau mal nach ...", 
		Media = objKlaus, 
		Callback = function(action)
			if action ~= nil then
				initFeld()
				
				objspieleMinesweeper.Visible = false
				objraeumeauf.Visible = true
				objKarte.Visible = true
				objMinesweeper.Visible = false
				aktuellesFeld.Visible = true
				AnzeigeInit()
				
				objKarte.Description = ((((((((((((((((((((((((((((((((objsT..objsCR)..objsCR)..s0)..objsCR)..sZ)..objsCR)..s1)..objsCR)..sZ)..objsCR)..s2)..objsCR)..sZ)..objsCR)..s3)..objsCR)..sZ)..objsCR)..s4)..objsCR)..sZ)..objsCR)..s5)..objsCR)..sZ)..objsCR)..s7)..objsCR)..sZ)..objsCR)..s6)..objsCR)..sZ
				iZone = 25
				_Urwigo.MessageBox{
					Text = [[Oh ja!
Hier gibt es einiges zum aufraeumen!]], 
					Media = objKlaus, 
					Callback = function(action)
						if action ~= nil then
							local _Urwigo_Date = os.date "*t"
							iTimeStart = _Urwigo.Date_SecondInYear(_Urwigo_Date)
							Wherigo.ShowScreen(Wherigo.MAINSCREEN)
						end
					end
				}
			end
		end
	}
end
function objAnleitung1:Oncmdlesen(target)
	_Urwigo.Dialog(false, {
		{
			Text = [[Ziel des Spiels

Auf dem 7x7-Spielfeld sind 10 Minen versteckt.
Gehe in die entsprechende Zone und setze eine Fahne.
Wenn Du alle Fahnen verteilt hast, sagt Dir Klaus, ob Du alle Fahnen richtig gesetzt hast.]]
		}, 
		{
			Text = [[Start des Spiels

Suche ein freies Feld mit einer Groesse von 80m x 80m.
Gehe in die Mitte und starte Minesweeper. 
Damit wird das Spielfeld erzeugt und die Minen verteilt.
Du befindest Dich in der Mitte des Spielfeldes.]]
		}, 
		{
			Text = [[Minen suchen

Sobald Du eine Zone betreten hast, kannst Du in der aktuellen Umgebung eine Fahne setzen, eine Fahne nehmen oder aufdecken.
Sollte die Zone eine Mine enthalten, hast Du beim Aufdecken Pech. Andernfalls wird Dir angezeigt, wieviele Minen sich in der Umgebung befinden.]]
		}, 
		{
			Text = [[Karte

Deine Karte zeigt Dir jeweils Deine aktuelle Position sowie de bisher aufgedeckten Zonen an.
Fuer jede aufgedeckte Zone wird angezeigt, wieviele Minen sich in der Umgebung befinden.]]
		}, 
		{
			Text = [[Ende des Spiels

Das Spiel endet automatisch, wenn Du alle Fahnen richtig gesetzt hast.]]
		}
	}, function(action)
		Wherigo.ShowScreen(Wherigo.MAINSCREEN)
	end)
end
function aktuellesFeld:OncmdsetzenFahne(target)
	iZone = tonumber(_G[currentZone].Name)
	_G[currentZone].Media = imgF
	_G[currentZone].Icon = imgF
	aktuellesFeld.Media = imgF
	aktuellesFeld.Icon = imgF
	objMarkierung1:MoveTo(_G[currentZone])
	FahneSetzen(iZone)
	
	objMarkierungsfahne.Description = ("Du hast noch "..iFahnen).." Fahnen."
	aktuellesFeld.Commands.cmdnehmenFahne.Enabled = true
	aktuellesFeld.Commands.cmdsetzenFahne.Enabled = false
	objMarkierungsfahne.Commands.cmdnehmen.Enabled = true
	objMarkierungsfahne.Commands.cmdsetzen.Enabled = false
	objMarkierung1.Commands.cmdnehmen.Enabled = true
	AnzeigeTitel()
	
	objsT = (("Aktuelle Position: "..x)..",")..y
	AnzeigeBody()
	
	objKarte.Description = ((((((((((((((((((((((((((((((((objsT..objsCR)..objsCR)..s0)..objsCR)..sZ)..objsCR)..s7)..objsCR)..sZ)..objsCR)..s6)..objsCR)..sZ)..objsCR)..s5)..objsCR)..sZ)..objsCR)..s4)..objsCR)..sZ)..objsCR)..s3)..objsCR)..sZ)..objsCR)..s2)..objsCR)..sZ)..objsCR)..s1)..objsCR)..sZ
	if iFahnen == 0 then
		CheckLoesung()
		
		_Urwigo.MessageBox{
			Text = Player.Name..", Du hast also alle Fahnen gesetzt. Mal sehen, ob sie auch richtig stecken!", 
			Media = objKlaus, 
			Callback = function(action)
				if action ~= nil then
					local _Urwigo_Date = os.date "*t"
					if bLoesung == true then
						iTimeStop = _Urwigo.Date_SecondInYear(_Urwigo_Date)
						objiSek = iTimeStop - iTimeStart
						objiMin = _Urwigo.Floor(objiSek / 60, 0)
						objiSek = objiSek - (60 * objiMin)
						objiStd = _Urwigo.Floor(objiMin / 60, 0)
						objiMin = objiMin - (60 * objiStd)
						Wherigo.PlayAudio(obj_tusch)
						_Urwigo.MessageBox{
							Text = ((((((Player.Name..[[, Du hast die Fahnen richtig gesetzt!
Herzlichen Glueckwunsch!
Du hast alle Minen gefunden!

Deine Zeit: ]])..objiStd).." Std  ")..objiMin).." Min  ")..objiSek).." Sek", 
							Media = objKlaus, 
							Callback = function(action)
								if action ~= nil then
									final.Active = true
									final.Visible = true
									ZonenAus()
									
									objKoordinaten1.Visible = true
									objraeumeauf.Complete = true
									objKlausraeumtauf.Complete = true
									objAnleitung1.Visible = false
									objtrageDichinsLogbuchein.Visible = true
									aktuellesFeld.Visible = false
									objMarkierungsfahne.Visible = false
									objKarte.Visible = false
									objKlausraeumtauf:RequestSync()
									objFreischaltcode1.Description = (Player.Name..", Dein Freischaltcode ist ")..string.sub(Player.CompletionCode, 1, 15)
									objFreischaltcode1.Visible = true
									Wherigo.ShowScreen(Wherigo.MAINSCREEN)
								end
							end
						}
					else
						_Urwigo.MessageBox{
							Text = Player.Name..[[, Du hast die Fahnen leider nicht richtig gesetzt!
Irgendwo ist noch eine Mine nicht gefunden!]], 
							Media = objKlaus, 
							Callback = function(action)
								if action ~= nil then
									Wherigo.ShowScreen(Wherigo.MAINSCREEN)
								end
							end
						}
					end
				end
			end
		}
	else
		Wherigo.ShowScreen(Wherigo.MAINSCREEN)
	end
end
function aktuellesFeld:OncmdnehmenFahne(target)
	iZone = tonumber(_G[currentZone].Name)
	FahneNehmen(iZone)
	
	objMarkierung1:MoveTo(final)
	objMarkierungsfahne.Description = ("Du hast noch "..iFahnen).." Fahnen."
	_G[currentZone].Media = objtest
	_G[currentZone].Icon = imgT
	aktuellesFeld.Media = objtest
	aktuellesFeld.Icon = imgT
	aktuellesFeld.Commands.cmdsetzenFahne.Enabled = true
	aktuellesFeld.Commands.cmdnehmenFahne.Enabled = false
	objMarkierungsfahne.Commands.cmdsetzen.Enabled = true
	objMarkierungsfahne.Commands.cmdnehmen.Enabled = false
	objMarkierung1.Commands.cmdnehmen.Enabled = false
	AnzeigeTitel()
	
	objsT = (("Aktuelle Position: "..x)..",")..y
	AnzeigeBody()
	
	objKarte.Description = ((((((((((((((((((((((((((((((((objsT..objsCR)..objsCR)..s0)..objsCR)..sZ)..objsCR)..s7)..objsCR)..sZ)..objsCR)..s6)..objsCR)..sZ)..objsCR)..s5)..objsCR)..sZ)..objsCR)..s4)..objsCR)..sZ)..objsCR)..s3)..objsCR)..sZ)..objsCR)..s2)..objsCR)..sZ)..objsCR)..s1)..objsCR)..sZ
	Wherigo.ShowScreen(Wherigo.MAINSCREEN)
end
function aktuellesFeld:Oncmdaufdecken(target)
	CheckZone()
	
	if objbFirst == true then
		objbFirst = false
		if bMine == false then
			if iFeldMine == 0 then
				z25.Icon = img0
				z25.Description = "0 Minen in der Umgebung"
				Aufdecken(25)
				
			elseif iFeldMine == 1 then
				z25.Icon = img1
				z25.Description = "1 Mine in der Umgebung"
			elseif iFeldMine == 2 then
				z25.Icon = img2
				z25.Description = "2 Minen in der Umgebung"
			elseif iFeldMine == 3 then
				z25.Icon = img3
				z25.Description = "3 Minen in der Umgebung"
			elseif iFeldMine == 4 then
				z25.Icon = img4
				z25.Description = "4 Minen in der Umgebung"
			elseif iFeldMine == 5 then
				z25.Icon = img5
				z25.Description = "5 Minen in der Umgebung"
			elseif iFeldMine == 6 then
				z25.Icon = img6
				z25.Description = "6 Minen in der Umgebung"
			elseif iFeldMine == 7 then
				z25.Icon = img7
				z25.Description = "7 Minen in der Umgebung"
			else
				z25.Icon = img8
				z25.Description = "8 Minen in der Umgebung"
			end
			z25.Media = z25.Icon
			aktuellesFeld.Description = z25.Description
			aktuellesFeld.Media = z25.Icon
			aktuellesFeld.Icon = z25.Icon
			AnzeigeTitel()
			
			objsT = (("Aktuelle Position: "..x)..",")..y
			AnzeigeBody()
			
			objKarte.Description = ((((((((((((((((((((((((((((((((objsT..objsCR)..objsCR)..s0)..objsCR)..sZ)..objsCR)..s7)..objsCR)..sZ)..objsCR)..s6)..objsCR)..sZ)..objsCR)..s5)..objsCR)..sZ)..objsCR)..s4)..objsCR)..sZ)..objsCR)..s3)..objsCR)..sZ)..objsCR)..s2)..objsCR)..sZ)..objsCR)..s1)..objsCR)..sZ
			_Urwigo.MessageBox{
				Text = [[Glueckwunsch - keine Mine.
und ]]..z25.Description, 
				Media = objKlaus, 
				Callback = function(action)
					if action ~= nil then
						Wherigo.ShowScreen(Wherigo.MAINSCREEN)
					end
				end
			}
		else
			Wherigo.PlayAudio(obj_explosion)
			objraeumeauf.Visible = false
			objKarte.Visible = false
			objMarkierungsfahne.Visible = false
			aktuellesFeld.Visible = false
			_Urwigo.Dialog(false, {
				{
					Text = "", 
					Media = objexplosion
				}, 
				{
					Text = "Schade. Leider verloren!", 
					Media = objKlaus
				}
			}, function(action)
				ZonenAus()
				
				Wherigo.ShowScreen(Wherigo.MAINSCREEN)
			end)
		end
	else
		if bMine == false then
			if iFeldMine == 0 then
				_G[currentZone].Icon = img0
				_G[currentZone].Description = "0 Minen in der Umgebung"
				Aufdecken(iZone)
				
			elseif iFeldMine == 1 then
				_G[currentZone].Icon = img1
				_G[currentZone].Description = "1 Mine in der Umgebung"
			elseif iFeldMine == 2 then
				_G[currentZone].Icon = img2
				_G[currentZone].Description = "2 Minen in der Umgebung"
			elseif iFeldMine == 3 then
				_G[currentZone].Icon = img3
				_G[currentZone].Description = "3 Minen in der Umgebung"
			elseif iFeldMine == 4 then
				_G[currentZone].Icon = img4
				_G[currentZone].Description = "4 Minen in der Umgebung"
			elseif iFeldMine == 5 then
				_G[currentZone].Icon = img5
				_G[currentZone].Description = "5 Minen in der Umgebung"
			elseif iFeldMine == 6 then
				_G[currentZone].Icon = img6
				_G[currentZone].Description = "6 Minen in der Umgebung"
			elseif iFeldMine == 7 then
				_G[currentZone].Icon = img7
				_G[currentZone].Description = "7 Minen in der Umgebung"
			else
				_G[currentZone].Icon = img8
				_G[currentZone].Description = "8 Minen in der Umgebung"
			end
			_G[currentZone].Media = _G[currentZone].Icon
			aktuellesFeld.Description = _G[currentZone].Description
			aktuellesFeld.Media = _G[currentZone].Icon
			aktuellesFeld.Icon = _G[currentZone].Icon
			AnzeigeTitel()
			
			objsT = (("Aktuelle Position: "..x)..",")..y
			AnzeigeBody()
			
			objKarte.Description = ((((((((((((((((((((((((((((((((objsT..objsCR)..objsCR)..s0)..objsCR)..sZ)..objsCR)..s7)..objsCR)..sZ)..objsCR)..s6)..objsCR)..sZ)..objsCR)..s5)..objsCR)..sZ)..objsCR)..s4)..objsCR)..sZ)..objsCR)..s3)..objsCR)..sZ)..objsCR)..s2)..objsCR)..sZ)..objsCR)..s1)..objsCR)..sZ
			_Urwigo.MessageBox{
				Text = [[Glueckwunsch - keine Mine.
und ]].._G[currentZone].Description, 
				Media = objKlaus, 
				Callback = function(action)
					if action ~= nil then
						Wherigo.ShowScreen(Wherigo.MAINSCREEN)
					end
				end
			}
		else
			Wherigo.PlayAudio(obj_explosion)
			objraeumeauf.Visible = false
			objKarte.Visible = false
			objMarkierungsfahne.Visible = false
			aktuellesFeld.Visible = false
			_Urwigo.Dialog(false, {
				{
					Text = "", 
					Media = objexplosion
				}, 
				{
					Text = "Schade. Leider verloren!", 
					Media = objKlaus
				}
			}, function(action)
				ZonenAus()
				
				Wherigo.ShowScreen(Wherigo.MAINSCREEN)
			end)
		end
	end
end
function objMarkierungsfahne:Oncmdsetzen(target)
	iZone = tonumber(_G[currentZone].Name)
	_G[currentZone].Icon = imgF
	_G[currentZone].Media = imgF
	aktuellesFeld.Icon = imgF
	aktuellesFeld.Media = imgF
	objMarkierung1:MoveTo(_G[currentZone])
	FahneSetzen(iZone)
	
	objMarkierungsfahne.Description = ("Du hast noch "..iFahnen).." Fahnen."
	aktuellesFeld.Commands.cmdnehmenFahne.Enabled = true
	aktuellesFeld.Commands.cmdsetzenFahne.Enabled = false
	objMarkierungsfahne.Commands.cmdnehmen.Enabled = true
	objMarkierungsfahne.Commands.cmdsetzen.Enabled = false
	objMarkierung1.Commands.cmdnehmen.Enabled = true
	AnzeigeTitel()
	
	objsT = (("Aktuelle Position: "..x)..",")..y
	AnzeigeBody()
	
	objKarte.Description = ((((((((((((((((((((((((((((((((objsT..objsCR)..objsCR)..s0)..objsCR)..sZ)..objsCR)..s7)..objsCR)..sZ)..objsCR)..s6)..objsCR)..sZ)..objsCR)..s5)..objsCR)..sZ)..objsCR)..s4)..objsCR)..sZ)..objsCR)..s3)..objsCR)..sZ)..objsCR)..s2)..objsCR)..sZ)..objsCR)..s1)..objsCR)..sZ
	if iFahnen == 0 then
		CheckLoesung()
		
		_Urwigo.MessageBox{
			Text = Player.Name..", Du hast also alle Fahnen gesetzt. Mal sehen, ob sie auch richtig stecken!", 
			Media = objKlaus, 
			Callback = function(action)
				if action ~= nil then
					local _Urwigo_Date = os.date "*t"
					if bLoesung == true then
						iTimeStop = _Urwigo.Date_SecondInYear(_Urwigo_Date)
						objiSek = iTimeStop - iTimeStart
						objiMin = _Urwigo.Floor(objiSek / 60, 0)
						objiSek = objiSek - (60 * objiMin)
						objiStd = _Urwigo.Floor(objiMin / 60, 0)
						objiMin = objiMin - (60 * objiStd)
						Wherigo.PlayAudio(obj_tusch)
						_Urwigo.MessageBox{
							Text = ((((((Player.Name..[[, Du hast die Fahnen richtig gesetzt!
Herzlichen Glueckwunsch!
Du hast alle Minen gefunden!

Deine Zeit: ]])..objiStd).." Std  ")..objiMin).." Min  ")..objiSek).." Sek", 
							Media = objKlaus, 
							Callback = function(action)
								if action ~= nil then
									final.Active = true
									final.Visible = true
									ZonenAus()
									
									objKoordinaten1.Visible = true
									objMarkierungsfahne.Visible = false
									aktuellesFeld.Visible = false
									objraeumeauf.Complete = true
									objKlausraeumtauf.Complete = true
									objtrageDichinsLogbuchein.Visible = true
									objAnleitung1.Visible = false
									objKarte.Visible = false
									objKlausraeumtauf:RequestSync()
									objFreischaltcode1.Description = (Player.Name..", Dein Freischaltcode ist ")..string.sub(Player.CompletionCode, 1, 15)
									objFreischaltcode1.Visible = true
									Wherigo.ShowScreen(Wherigo.MAINSCREEN)
								end
							end
						}
					else
						_Urwigo.MessageBox{
							Text = Player.Name..[[, Du hast die Fahnen leider nicht richtig gesetzt!
Irgendwo ist noch eine Mine nicht gefunden!]], 
							Media = objKlaus, 
							Callback = function(action)
								if action ~= nil then
									Wherigo.ShowScreen(Wherigo.MAINSCREEN)
								end
							end
						}
					end
				end
			end
		}
	else
		Wherigo.ShowScreen(Wherigo.MAINSCREEN)
	end
end
function objMarkierungsfahne:Oncmdnehmen(target)
	iZone = tonumber(_G[currentZone].Name)
	FahneNehmen(iZone)
	
	objMarkierung1:MoveTo(final)
	objMarkierungsfahne.Description = ("Du hast noch "..iFahnen).." Fahnen."
	_G[currentZone].Icon = imgT
	aktuellesFeld.Icon = imgT
	_G[currentZone].Media = objtest
	aktuellesFeld.Media = objtest
	aktuellesFeld.Commands.cmdsetzenFahne.Enabled = true
	aktuellesFeld.Commands.cmdnehmenFahne.Enabled = false
	objMarkierungsfahne.Commands.cmdsetzen.Enabled = true
	objMarkierungsfahne.Commands.cmdnehmen.Enabled = false
	objMarkierung1.Commands.cmdnehmen.Enabled = false
	AnzeigeTitel()
	
	objsT = (("Aktuelle Position: "..x)..",")..y
	AnzeigeBody()
	
	objKarte.Description = ((((((((((((((((((((((((((((((((objsT..objsCR)..objsCR)..s0)..objsCR)..sZ)..objsCR)..s7)..objsCR)..sZ)..objsCR)..s6)..objsCR)..sZ)..objsCR)..s5)..objsCR)..sZ)..objsCR)..s4)..objsCR)..sZ)..objsCR)..s3)..objsCR)..sZ)..objsCR)..s2)..objsCR)..sZ)..objsCR)..s1)..objsCR)..sZ
	Wherigo.ShowScreen(Wherigo.MAINSCREEN)
end
function objMarkierung1:Oncmdnehmen(target)
	iZone = tonumber(_G[currentZone].Name)
	FahneNehmen(iZone)
	
	objMarkierung1:MoveTo(final)
	objMarkierungsfahne.Description = ("Du hast noch "..iFahnen).." Fahnen."
	_G[currentZone].Icon = imgT
	aktuellesFeld.Icon = imgT
	_G[currentZone].Media = objtest
	aktuellesFeld.Media = objtest
	aktuellesFeld.Commands.cmdsetzenFahne.Enabled = true
	aktuellesFeld.Commands.cmdnehmenFahne.Enabled = false
	objMarkierungsfahne.Commands.cmdsetzen.Enabled = true
	objMarkierungsfahne.Commands.cmdnehmen.Enabled = false
	objMarkierung1.Commands.cmdnehmen.Enabled = false
	AnzeigeTitel()
	
	objsT = (("Aktuelle Position: "..x)..",")..y
	AnzeigeBody()
	
	objKarte.Description = ((((((((((((((((((((((((((((((((objsT..objsCR)..objsCR)..s0)..objsCR)..sZ)..objsCR)..s7)..objsCR)..sZ)..objsCR)..s6)..objsCR)..sZ)..objsCR)..s5)..objsCR)..sZ)..objsCR)..s4)..objsCR)..sZ)..objsCR)..s3)..objsCR)..sZ)..objsCR)..s2)..objsCR)..sZ)..objsCR)..s1)..objsCR)..sZ
	Wherigo.ShowScreen(Wherigo.MAINSCREEN)
end
function _Urwigo.GlobalZoneEnter()
	sZone = _G[currentZone].Name
	if Wherigo.NoCaseEquals(sZone, "final") then
		objSpoiler1.Visible = true
		Wherigo.PlayAudio(obj_tusch)
	else
		BestimmeZone(sZone)
		
		CheckFahne(iZone)
		
		AnzeigeTitel()
		
		objsT = (("Aktuelle Position: "..x)..",")..y
		AnzeigeBody()
		
		objKarte.Description = ((((((((((((((((((((((((((((((((objsT..objsCR)..objsCR)..s0)..objsCR)..sZ)..objsCR)..s7)..objsCR)..sZ)..objsCR)..s6)..objsCR)..sZ)..objsCR)..s5)..objsCR)..sZ)..objsCR)..s4)..objsCR)..sZ)..objsCR)..s3)..objsCR)..sZ)..objsCR)..s2)..objsCR)..sZ)..objsCR)..s1)..objsCR)..sZ
		aktuellesFeld.Icon = _G[currentZone].Icon
		aktuellesFeld.Media = _G[currentZone].Media
		aktuellesFeld.Description = "Aktuelle Zone: ".._G[currentZone].Name
		if bFlag == false then
			aktuellesFeld.Commands.cmdnehmenFahne.Enabled = false
			objMarkierungsfahne.Commands.cmdnehmen.Enabled = false
			if iFahnen == 0 then
				aktuellesFeld.Commands.cmdsetzenFahne.Enabled = false
				objMarkierungsfahne.Commands.cmdsetzen.Enabled = false
			else
				aktuellesFeld.Commands.cmdsetzenFahne.Enabled = true
				objMarkierungsfahne.Commands.cmdsetzen.Enabled = true
			end
		else
			aktuellesFeld.Commands.cmdnehmenFahne.Enabled = true
			aktuellesFeld.Commands.cmdsetzenFahne.Enabled = false
			objMarkierung1:MoveTo(_G[currentZone])
			objMarkierungsfahne.Commands.cmdnehmen.Enabled = true
			objMarkierungsfahne.Commands.cmdsetzen.Enabled = false
			objMarkierung1.Commands.cmdnehmen.Enabled = true
		end
	end
end

-- Urwigo functions --

-- Begin user functions --
i = 0
m = 0
p = ZonePoint(0, 0, 0)
feldM = {
	[1] = 0, 
	[2] = 0, 
	[3] = 0, 
	[4] = 0, 
	[5] = 0, 
	[6] = 0, 
	[7] = 0, 
	[8] = 0, 
	[9] = 0, 
	[10] = 0, 
	[11] = 0, 
	[12] = 0, 
	[13] = 0, 
	[14] = 0, 
	[15] = 0, 
	[16] = 0, 
	[17] = 0, 
	[18] = 0, 
	[19] = 0, 
	[20] = 0, 
	[21] = 0, 
	[22] = 0, 
	[23] = 0, 
	[24] = 0, 
	[25] = 0, 
	[26] = 0, 
	[27] = 0, 
	[28] = 0, 
	[29] = 0, 
	[30] = 0, 
	[31] = 0, 
	[32] = 0, 
	[33] = 0, 
	[34] = 0, 
	[35] = 0, 
	[36] = 0, 
	[37] = 0, 
	[38] = 0, 
	[39] = 0, 
	[40] = 0, 
	[41] = 0, 
	[42] = 0, 
	[43] = 0, 
	[44] = 0, 
	[45] = 0, 
	[46] = 0, 
	[47] = 0, 
	[48] = 0, 
	[49] = 0, 
	[50] = 0
}
feldK = {
	[1] = p, 
	[2] = p, 
	[3] = p, 
	[4] = p, 
	[5] = p, 
	[6] = p, 
	[7] = p, 
	[8] = p, 
	[9] = p, 
	[10] = p, 
	[11] = p, 
	[12] = p, 
	[13] = p, 
	[14] = p, 
	[15] = p, 
	[16] = p, 
	[17] = p, 
	[18] = p, 
	[19] = p, 
	[20] = p, 
	[21] = p, 
	[22] = p, 
	[23] = p, 
	[24] = p, 
	[25] = p, 
	[26] = p, 
	[27] = p, 
	[28] = p, 
	[29] = p, 
	[30] = p, 
	[31] = p, 
	[32] = p, 
	[33] = p, 
	[34] = p, 
	[35] = p, 
	[36] = p, 
	[37] = p, 
	[38] = p, 
	[39] = p, 
	[40] = p, 
	[41] = p, 
	[42] = p, 
	[43] = p, 
	[44] = p, 
	[45] = p, 
	[46] = p, 
	[47] = p, 
	[48] = p, 
	[49] = p, 
	[50] = p
}
feldC = {
	[1] = 0, 
	[2] = 0, 
	[3] = 0, 
	[4] = 0, 
	[5] = 0, 
	[6] = 0, 
	[7] = 0, 
	[8] = 0, 
	[9] = 0, 
	[10] = 0, 
	[11] = 0, 
	[12] = 0, 
	[13] = 0, 
	[14] = 0, 
	[15] = 0, 
	[16] = 0, 
	[17] = 0, 
	[18] = 0, 
	[19] = 0, 
	[20] = 0, 
	[21] = 0, 
	[22] = 0, 
	[23] = 0, 
	[24] = 0, 
	[25] = 0, 
	[26] = 0, 
	[27] = 0, 
	[28] = 0, 
	[29] = 0, 
	[30] = 0, 
	[31] = 0, 
	[32] = 0, 
	[33] = 0, 
	[34] = 0, 
	[35] = 0, 
	[36] = 0, 
	[37] = 0, 
	[38] = 0, 
	[39] = 0, 
	[40] = 0, 
	[41] = 0, 
	[42] = 0, 
	[43] = 0, 
	[44] = 0, 
	[45] = 0, 
	[46] = 0, 
	[47] = 0, 
	[48] = 0, 
	[49] = 0, 
	[50] = 0
}
feldA = {
	[1] = "   ", 
	[2] = "   ", 
	[3] = "   ", 
	[4] = "   ", 
	[5] = "   ", 
	[6] = "   ", 
	[7] = "   ", 
	[8] = "   ", 
	[9] = "   ", 
	[10] = "   ", 
	[11] = "   ", 
	[12] = "   ", 
	[13] = "   ", 
	[14] = "   ", 
	[15] = "   ", 
	[16] = "   ", 
	[17] = "   ", 
	[18] = "   ", 
	[19] = "   ", 
	[20] = "   ", 
	[21] = "   ", 
	[22] = "   ", 
	[23] = "   ", 
	[24] = "   ", 
	[25] = "   ", 
	[26] = "   ", 
	[27] = "   ", 
	[28] = "   ", 
	[29] = "   ", 
	[30] = "   ", 
	[31] = "   ", 
	[32] = "   ", 
	[33] = "   ", 
	[34] = "   ", 
	[35] = "   ", 
	[36] = "   ", 
	[37] = "   ", 
	[38] = "   ", 
	[39] = "   ", 
	[40] = "   ", 
	[41] = "   ", 
	[42] = "   ", 
	[43] = "   ", 
	[44] = "   ", 
	[45] = "   ", 
	[46] = "   ", 
	[47] = "   ", 
	[48] = "   ", 
	[49] = "   ", 
	[50] = "   "
}
feldF = {
	[1] = 0, 
	[2] = 0, 
	[3] = 0, 
	[4] = 0, 
	[5] = 0, 
	[6] = 0, 
	[7] = 0, 
	[8] = 0, 
	[9] = 0, 
	[10] = 0, 
	[11] = 0, 
	[12] = 0, 
	[13] = 0, 
	[14] = 0, 
	[15] = 0, 
	[16] = 0, 
	[17] = 0, 
	[18] = 0, 
	[19] = 0, 
	[20] = 0, 
	[21] = 0, 
	[22] = 0, 
	[23] = 0, 
	[24] = 0, 
	[25] = 0, 
	[26] = 0, 
	[27] = 0, 
	[28] = 0, 
	[29] = 0, 
	[30] = 0, 
	[31] = 0, 
	[32] = 0, 
	[33] = 0, 
	[34] = 0, 
	[35] = 0, 
	[36] = 0, 
	[37] = 0, 
	[38] = 0, 
	[39] = 0, 
	[40] = 0, 
	[41] = 0, 
	[42] = 0, 
	[43] = 0, 
	[44] = 0, 
	[45] = 0, 
	[46] = 0, 
	[47] = 0, 
	[48] = 0, 
	[49] = 0, 
	[50] = 0
}
function initZufall()
	math.randomseed(iSeed)
end
function initFeld()
	local dist = Wherigo.Distance(0, "m")
	-- Mittelpunktkoordinaten der Zonen festlegen
	feldK[25] = Player.ObjectLocation
	feldK[22] = GetPoint(feldK[25], 30, 270)
	feldK[1] = GetPoint(feldK[22], 30, 180)
	for y = 1, 7, 1 do
		for x = 2, 7, 1 do
			feldK[((y - 1) * 7) + x] = GetPoint(feldK[(((y - 1) * 7) + x) - 1], 10, 90)
		end
		-- for x
		feldK[(y * 7) + 1] = GetPoint(feldK[((y - 1) * 7) + 1], 10, 0)
	end
	-- for y
	-- Minen verteilen
	for x = 1, 49, 1 do
		feldM[x] = 0
		feldA[x] = " "
		-- 1 Leerzeichen
	end
	iMinen = 10
	while iMinen > 0 do
		y = math.random(49)
		if y ~= 25 then
			if feldM[y] == 0 then
				feldM[y] = 1
				iMinen = iMinen - 1
			end
			-- if
		end
		-- if
	end
	-- while 
	iMinen = 10
	-- Ecken   
	feldC[1] = (feldM[8] + feldM[9]) + feldM[2]
	feldC[43] = (feldM[36] + feldM[37]) + feldM[44]
	feldC[49] = (feldM[48] + feldM[41]) + feldM[42]
	feldC[7] = (feldM[6] + feldM[13]) + feldM[14]
	-- unterste Zeile	
	feldC[2] = (((feldM[1] + feldM[8]) + feldM[9]) + feldM[10]) + feldM[3]
	feldC[3] = (((feldM[2] + feldM[9]) + feldM[10]) + feldM[11]) + feldM[4]
	feldC[4] = (((feldM[3] + feldM[10]) + feldM[11]) + feldM[12]) + feldM[5]
	feldC[5] = (((feldM[4] + feldM[11]) + feldM[12]) + feldM[13]) + feldM[6]
	feldC[6] = (((feldM[5] + feldM[12]) + feldM[13]) + feldM[14]) + feldM[7]
	-- linke spalte		
	feldC[8] = (((feldM[1] + feldM[2]) + feldM[9]) + feldM[15]) + feldM[16]
	feldC[15] = (((feldM[8] + feldM[9]) + feldM[16]) + feldM[22]) + feldM[23]
	feldC[22] = (((feldM[15] + feldM[16]) + feldM[23]) + feldM[29]) + feldM[30]
	feldC[29] = (((feldM[22] + feldM[23]) + feldM[30]) + feldM[36]) + feldM[37]
	feldC[36] = (((feldM[29] + feldM[30]) + feldM[37]) + feldM[43]) + feldM[44]
	-- oberste zeile	
	feldC[44] = (((feldM[43] + feldM[45]) + feldM[36]) + feldM[37]) + feldM[38]
	feldC[45] = (((feldM[44] + feldM[46]) + feldM[37]) + feldM[38]) + feldM[39]
	feldC[46] = (((feldM[45] + feldM[47]) + feldM[38]) + feldM[39]) + feldM[40]
	feldC[47] = (((feldM[46] + feldM[48]) + feldM[39]) + feldM[40]) + feldM[41]
	feldC[48] = (((feldM[47] + feldM[49]) + feldM[40]) + feldM[41]) + feldM[42]
	-- rechte spalte
	feldC[14] = (((feldM[6] + feldM[7]) + feldM[13]) + feldM[20]) + feldM[21]
	feldC[21] = (((feldM[13] + feldM[14]) + feldM[20]) + feldM[27]) + feldM[28]
	feldC[28] = (((feldM[20] + feldM[21]) + feldM[27]) + feldM[34]) + feldM[35]
	feldC[35] = (((feldM[27] + feldM[28]) + feldM[34]) + feldM[41]) + feldM[42]
	feldC[42] = (((feldM[34] + feldM[35]) + feldM[41]) + feldM[48]) + feldM[49]
	-- sonstige Felder
	for y = 2, 6, 1 do
		for x = 2, 6, 1 do
			i = ((y - 1) * 7) + x
			feldC[i] = ((((((feldM[i - 1] + feldM[i + 1]) + feldM[i + 7]) + feldM[i - 7]) + feldM[i - 8]) + feldM[i + 8]) + feldM[i - 6]) + feldM[i + 6]
		end
		-- x
	end
	-- y
	-- Zonen festlegen
	z01.Active = false
	z01.OriginalPoint = Wherigo.TranslatePoint(feldK[1], dist, 0)
	z01.Points = GetZonePoints(feldK[1])
	z01.Active = true
	z02.Active = false
	z02.OriginalPoint = Wherigo.TranslatePoint(feldK[2], dist, 0)
	z02.Points = GetZonePoints(feldK[2])
	z02.Active = true
	z03.Active = false
	z03.OriginalPoint = Wherigo.TranslatePoint(feldK[3], dist, 0)
	z03.Points = GetZonePoints(feldK[3])
	z03.Active = true
	z04.Active = false
	z04.OriginalPoint = Wherigo.TranslatePoint(feldK[4], dist, 0)
	z04.Points = GetZonePoints(feldK[4])
	z04.Active = true
	z05.Active = false
	z05.OriginalPoint = Wherigo.TranslatePoint(feldK[5], dist, 0)
	z05.Points = GetZonePoints(feldK[5])
	z05.Active = true
	z06.Active = false
	z06.OriginalPoint = Wherigo.TranslatePoint(feldK[6], dist, 0)
	z06.Points = GetZonePoints(feldK[6])
	z06.Active = true
	z07.Active = false
	z07.OriginalPoint = Wherigo.TranslatePoint(feldK[7], dist, 0)
	z07.Points = GetZonePoints(feldK[7])
	z07.Active = true
	z08.Active = false
	z08.OriginalPoint = Wherigo.TranslatePoint(feldK[8], dist, 0)
	z08.Points = GetZonePoints(feldK[8])
	z08.Active = true
	z09.Active = false
	z09.OriginalPoint = Wherigo.TranslatePoint(feldK[9], dist, 0)
	z09.Points = GetZonePoints(feldK[9])
	z09.Active = true
	z10.Active = false
	z10.OriginalPoint = Wherigo.TranslatePoint(feldK[10], dist, 0)
	z10.Points = GetZonePoints(feldK[10])
	z10.Active = true
	z11.Active = false
	z11.OriginalPoint = Wherigo.TranslatePoint(feldK[11], dist, 0)
	z11.Points = GetZonePoints(feldK[11])
	z11.Active = true
	z12.Active = false
	z12.OriginalPoint = Wherigo.TranslatePoint(feldK[12], dist, 0)
	z12.Points = GetZonePoints(feldK[12])
	z12.Active = true
	z13.Active = false
	z13.OriginalPoint = Wherigo.TranslatePoint(feldK[13], dist, 0)
	z13.Points = GetZonePoints(feldK[13])
	z13.Active = true
	z14.Active = false
	z14.OriginalPoint = Wherigo.TranslatePoint(feldK[14], dist, 0)
	z14.Points = GetZonePoints(feldK[14])
	z14.Active = true
	z15.Active = false
	z15.OriginalPoint = Wherigo.TranslatePoint(feldK[15], dist, 0)
	z15.Points = GetZonePoints(feldK[15])
	z15.Active = true
	z16.Active = false
	z16.OriginalPoint = Wherigo.TranslatePoint(feldK[16], dist, 0)
	z16.Points = GetZonePoints(feldK[16])
	z16.Active = true
	z17.Active = false
	z17.OriginalPoint = Wherigo.TranslatePoint(feldK[17], dist, 0)
	z17.Points = GetZonePoints(feldK[17])
	z17.Active = true
	z18.Active = false
	z18.OriginalPoint = Wherigo.TranslatePoint(feldK[18], dist, 0)
	z18.Points = GetZonePoints(feldK[18])
	z18.Active = true
	z19.Active = false
	z19.OriginalPoint = Wherigo.TranslatePoint(feldK[19], dist, 0)
	z19.Points = GetZonePoints(feldK[19])
	z19.Active = true
	z20.Active = false
	z20.OriginalPoint = Wherigo.TranslatePoint(feldK[20], dist, 0)
	z20.Points = GetZonePoints(feldK[20])
	z20.Active = true
	z21.Active = false
	z21.OriginalPoint = Wherigo.TranslatePoint(feldK[21], dist, 0)
	z21.Points = GetZonePoints(feldK[21])
	z21.Active = true
	z22.Active = false
	z22.OriginalPoint = Wherigo.TranslatePoint(feldK[22], dist, 0)
	z22.Points = GetZonePoints(feldK[22])
	z22.Active = true
	z23.Active = false
	z23.OriginalPoint = Wherigo.TranslatePoint(feldK[23], dist, 0)
	z23.Points = GetZonePoints(feldK[23])
	z23.Active = true
	z24.Active = false
	z24.OriginalPoint = Wherigo.TranslatePoint(feldK[24], dist, 0)
	z24.Points = GetZonePoints(feldK[24])
	z24.Active = true
	z25.Active = false
	z25.OriginalPoint = Wherigo.TranslatePoint(feldK[25], dist, 0)
	z25.Points = GetZonePoints(feldK[25])
	z25.Active = true
	z26.Active = false
	z26.OriginalPoint = Wherigo.TranslatePoint(feldK[26], dist, 0)
	z26.Points = GetZonePoints(feldK[26])
	z26.Active = true
	z27.Active = false
	z27.OriginalPoint = Wherigo.TranslatePoint(feldK[27], dist, 0)
	z27.Points = GetZonePoints(feldK[27])
	z27.Active = true
	z28.Active = false
	z28.OriginalPoint = Wherigo.TranslatePoint(feldK[28], dist, 0)
	z28.Points = GetZonePoints(feldK[28])
	z28.Active = true
	z29.Active = false
	z29.OriginalPoint = Wherigo.TranslatePoint(feldK[29], dist, 0)
	z29.Points = GetZonePoints(feldK[29])
	z29.Active = true
	z30.Active = false
	z30.OriginalPoint = Wherigo.TranslatePoint(feldK[30], dist, 0)
	z30.Points = GetZonePoints(feldK[30])
	z30.Active = true
	z31.Active = false
	z31.OriginalPoint = Wherigo.TranslatePoint(feldK[31], dist, 0)
	z31.Points = GetZonePoints(feldK[31])
	z31.Active = true
	z32.Active = false
	z32.OriginalPoint = Wherigo.TranslatePoint(feldK[32], dist, 0)
	z32.Points = GetZonePoints(feldK[32])
	z32.Active = true
	z33.Active = false
	z33.OriginalPoint = Wherigo.TranslatePoint(feldK[33], dist, 0)
	z33.Points = GetZonePoints(feldK[33])
	z33.Active = true
	z34.Active = false
	z34.OriginalPoint = Wherigo.TranslatePoint(feldK[34], dist, 0)
	z34.Points = GetZonePoints(feldK[34])
	z34.Active = true
	z35.Active = false
	z35.OriginalPoint = Wherigo.TranslatePoint(feldK[35], dist, 0)
	z35.Points = GetZonePoints(feldK[35])
	z35.Active = true
	z36.Active = false
	z36.OriginalPoint = Wherigo.TranslatePoint(feldK[36], dist, 0)
	z36.Points = GetZonePoints(feldK[36])
	z36.Active = true
	z37.Active = false
	z37.OriginalPoint = Wherigo.TranslatePoint(feldK[37], dist, 0)
	z37.Points = GetZonePoints(feldK[37])
	z37.Active = true
	z38.Active = false
	z38.OriginalPoint = Wherigo.TranslatePoint(feldK[38], dist, 0)
	z38.Points = GetZonePoints(feldK[38])
	z38.Active = true
	z39.Active = false
	z39.OriginalPoint = Wherigo.TranslatePoint(feldK[39], dist, 0)
	z39.Points = GetZonePoints(feldK[39])
	z39.Active = true
	z40.Active = false
	z40.OriginalPoint = Wherigo.TranslatePoint(feldK[40], dist, 0)
	z40.Points = GetZonePoints(feldK[40])
	z40.Active = true
	z41.Active = false
	z41.OriginalPoint = Wherigo.TranslatePoint(feldK[41], dist, 0)
	z41.Points = GetZonePoints(feldK[41])
	z41.Active = true
	z42.Active = false
	z42.OriginalPoint = Wherigo.TranslatePoint(feldK[42], dist, 0)
	z42.Points = GetZonePoints(feldK[42])
	z42.Active = true
	z43.Active = false
	z43.OriginalPoint = Wherigo.TranslatePoint(feldK[43], dist, 0)
	z43.Points = GetZonePoints(feldK[43])
	z43.Active = true
	z44.Active = false
	z44.OriginalPoint = Wherigo.TranslatePoint(feldK[44], dist, 0)
	z44.Points = GetZonePoints(feldK[44])
	z44.Active = true
	z45.Active = false
	z45.OriginalPoint = Wherigo.TranslatePoint(feldK[45], dist, 0)
	z45.Points = GetZonePoints(feldK[45])
	z45.Active = true
	z46.Active = false
	z46.OriginalPoint = Wherigo.TranslatePoint(feldK[46], dist, 0)
	z46.Points = GetZonePoints(feldK[46])
	z46.Active = true
	z47.Active = false
	z47.OriginalPoint = Wherigo.TranslatePoint(feldK[47], dist, 0)
	z47.Points = GetZonePoints(feldK[47])
	z47.Active = true
	z48.Active = false
	z48.OriginalPoint = Wherigo.TranslatePoint(feldK[48], dist, 0)
	z48.Points = GetZonePoints(feldK[48])
	z48.Active = true
	z49.Active = false
	z49.OriginalPoint = Wherigo.TranslatePoint(feldK[49], dist, 0)
	z49.Points = GetZonePoints(feldK[49])
	z49.Active = true
end
function GetPoint(refPt, entf, winkel)
	local dist = Wherigo.Distance(entf, "m")
	return Wherigo.TranslatePoint(refPt, dist, winkel)
end
function GetZonePoints(refPt)
	local dist = Wherigo.Distance(4, "m")
	local pts = {
		Wherigo.TranslatePoint(refPt, dist, 0), 
		Wherigo.TranslatePoint(refPt, dist, 45), 
		Wherigo.TranslatePoint(refPt, dist, 90), 
		Wherigo.TranslatePoint(refPt, dist, 135), 
		Wherigo.TranslatePoint(refPt, dist, 180), 
		Wherigo.TranslatePoint(refPt, dist, 225), 
		Wherigo.TranslatePoint(refPt, dist, 270), 
		Wherigo.TranslatePoint(refPt, dist, 315)
	}
	return pts
end
function CheckZone()
	iFeldMine = feldC[iZone]
	-- Anzahl der Minen in der Umgebung
	feldA[iZone] = tostring(feldC[iZone])
	bMine = false
	if feldM[iZone] == 1 then
		-- Mine auf dem aktuellen Feld
		bMine = true
	end
end
function CheckFahne()
	bFlag = false
	if feldF[iZone] == 1 then
		bFlag = true
	end
end
function FahneSetzen(Zone)
	feldF[Zone] = 1
	iFahnen = iFahnen - 1
	feldA[Zone] = "x"
end
function FahneNehmen(Zone)
	feldF[Zone] = 0
	iFahnen = iFahnen + 1
	feldA[Zone] = " "
	-- 1 Leerzeichen
end
function ZonenAus()
	z01.Active = false
	z02.Active = false
	z03.Active = false
	z04.Active = false
	z05.Active = false
	z06.Active = false
	z07.Active = false
	z08.Active = false
	z09.Active = false
	z10.Active = false
	z11.Active = false
	z12.Active = false
	z13.Active = false
	z14.Active = false
	z15.Active = false
	z16.Active = false
	z17.Active = false
	z18.Active = false
	z19.Active = false
	z20.Active = false
	z21.Active = false
	z22.Active = false
	z23.Active = false
	z24.Active = false
	z25.Active = false
	z26.Active = false
	z27.Active = false
	z28.Active = false
	z29.Active = false
	z30.Active = false
	z31.Active = false
	z32.Active = false
	z33.Active = false
	z34.Active = false
	z35.Active = false
	z36.Active = false
	z37.Active = false
	z38.Active = false
	z39.Active = false
	z40.Active = false
	z41.Active = false
	z42.Active = false
	z43.Active = false
	z44.Active = false
	z45.Active = false
	z46.Active = false
	z47.Active = false
	z48.Active = false
	z49.Active = false
end
function AnzeigeInit()
	sT = "Aktuelle Position:  4, 4"
	s1 = "1  |     |     |     |     |     |     |"
	s2 = "2  |     |     |     |     |     |     |"
	s3 = "3  |     |     |     |     |     |     |"
	s4 = "4  |     |     |     |     |     |     |"
	s5 = "5  |     |     |     |     |     |     |"
	s6 = "6  |     |     |     |     |     |     |"
	s7 = "7  |     |     |     |     |     |     |"
end
function BestimmeZone(paramsz)
	iZone = tonumber(paramsz)
end
function AnzeigeTitel()
	x = iZone % 7
	if x == 0 then
		x = 7
	end
	y = iZone - x
	y = y / 7
	y = y + 1
end
function AnzeigeBody()
	s1 = "1  |  "..feldA[1]
	s1 = (s1.."  |  ")..feldA[2]
	s1 = (s1.."  |  ")..feldA[3]
	s1 = (s1.."  |  ")..feldA[4]
	s1 = (s1.."  |  ")..feldA[5]
	s1 = (s1.."  |  ")..feldA[6]
	s1 = (s1.."  |  ")..feldA[7]
	-- s1 = s1 .. " | "
	s2 = "2  |  "..feldA[8]
	s2 = (s2.."  |  ")..feldA[9]
	s2 = (s2.."  |  ")..feldA[10]
	s2 = (s2.."  |  ")..feldA[11]
	s2 = (s2.."  |  ")..feldA[12]
	s2 = (s2.."  |  ")..feldA[13]
	s2 = (s2.."  |  ")..feldA[14]
	-- s2 = s2 .. " | "
	s3 = "3  |  "..feldA[15]
	s3 = (s3.."  |  ")..feldA[16]
	s3 = (s3.."  |  ")..feldA[17]
	s3 = (s3.."  |  ")..feldA[18]
	s3 = (s3.."  |  ")..feldA[19]
	s3 = (s3.."  |  ")..feldA[20]
	s3 = (s3.."  |  ")..feldA[21]
	--  s3 = s3 .. " | "
	s4 = "4  |  "..feldA[22]
	s4 = (s4.."  |  ")..feldA[23]
	s4 = (s4.."  |  ")..feldA[24]
	s4 = (s4.."  |  ")..feldA[25]
	s4 = (s4.."  |  ")..feldA[26]
	s4 = (s4.."  |  ")..feldA[27]
	s4 = (s4.."  |  ")..feldA[28]
	--  s4 = s4 .. " | "
	s5 = "5  |  "..feldA[29]
	s5 = (s5.."  |  ")..feldA[30]
	s5 = (s5.."  |  ")..feldA[31]
	s5 = (s5.."  |  ")..feldA[32]
	s5 = (s5.."  |  ")..feldA[33]
	s5 = (s5.."  |  ")..feldA[34]
	s5 = (s5.."  |  ")..feldA[35]
	--  s5 = s5 .. " | "
	s6 = "6  |  "..feldA[36]
	s6 = (s6.."  |  ")..feldA[37]
	s6 = (s6.."  |  ")..feldA[38]
	s6 = (s6.."  |  ")..feldA[39]
	s6 = (s6.."  |  ")..feldA[40]
	s6 = (s6.."  |  ")..feldA[41]
	s6 = (s6.."  |  ")..feldA[42]
	-- s6 = s6 ..  " | "
	s7 = "7  |  "..feldA[43]
	s7 = (s7.."  |  ")..feldA[44]
	s7 = (s7.."  |  ")..feldA[45]
	s7 = (s7.."  |  ")..feldA[46]
	s7 = (s7.."  |  ")..feldA[47]
	s7 = (s7.."  |  ")..feldA[48]
	s7 = (s7.."  |  ")..feldA[49]
	--  s7 = s7 .. " | "
end
function CheckLoesung()
	local richtig = 0
	bLoesung = false
	for i = 1, 49, 1 do
		if (feldM[i] == 1) and (feldF[i] == 1) then
			richtig = richtig + 1
		end
	end
	if richtig == 10 then
		bLoesung = true
	end
end
function Aufdecken(aktzone)
	if feldC[aktzone] == 0 then
		--nichts in der Umgebung
		feldA[aktzone] = "-"
		x = aktzone % 7
		if x == 0 then
			x = 7
		end
		y = aktzone - x
		y = y / 7
		y = y + 1
		if (y == 7) and (x == 1) then
			-- linke  obere Ecke -> 43 => 36, 37, 44
			if feldC[44] == 0 then
				feldA[44] = "-"
			else
				feldA[44] = tostring(feldC[44])
			end
			if feldC[36] == 0 then
				feldA[36] = "-"
			else
				feldA[36] = tostring(feldC[36])
			end
			if feldC[37] == 0 then
				feldA[37] = "-"
			else
				feldA[37] = tostring(feldC[37])
			end
		elseif (y == 7) and (x == 7) then
			-- rechte  obere Ecke -> 49 => 48, 41, 42
			if feldC[48] == 0 then
				feldA[48] = "-"
			else
				feldA[48] = tostring(feldC[48])
			end
			if feldC[41] == 0 then
				feldA[41] = "-"
			else
				feldA[41] = tostring(feldC[41])
			end
			if feldC[42] == 0 then
				feldA[42] = "-"
			else
				feldA[42] = tostring(feldC[42])
			end
		elseif (y == 1) and (x == 1) then
			--  linke untere Ecke -> 1 => 8, 9, 2           
			if feldC[8] == 0 then
				feldA[8] = "-"
			else
				feldA[8] = tostring(feldC[8])
			end
			if feldC[9] == 0 then
				feldA[9] = "-"
			else
				feldA[9] = tostring(feldC[9])
			end
			if feldC[2] == 0 then
				feldA[2] = "-"
			else
				feldA[2] = tostring(feldC[2])
			end
		elseif (y == 1) and (x == 7) then
			--  rechte untere Ecke -> 7 => 6, 13, 14
			if feldC[6] == 0 then
				feldA[6] = "-"
			else
				feldA[6] = tostring(feldC[6])
			end
			if feldC[13] == 0 then
				feldA[13] = "-"
			else
				feldA[13] = tostring(feldC[13])
			end
			if feldC[14] == 0 then
				feldA[14] = "-"
			else
				feldA[14] = tostring(feldC[14])
			end
		elseif y == 7 then
			-- oberste Zeile -> 44, 45, 46, 47, 48
			if feldC[(42 + x) - 1] == 0 then
				feldA[(42 + x) - 1] = "-"
			else
				feldA[(42 + x) - 1] = tostring(feldC[(42 + x) - 1])
			end
			if feldC[(42 + x) + 1] == 0 then
				feldA[(42 + x) + 1] = "-"
			else
				feldA[(42 + x) + 1] = tostring(feldC[(42 + x) + 1])
			end
			if feldC[(35 + x) - 1] == 0 then
				feldA[(35 + x) - 1] = "-"
			else
				feldA[(35 + x) - 1] = tostring(feldC[(35 + x) - 1])
			end
			if feldC[35 + x] == 0 then
				feldA[35 + x] = "-"
			else
				feldA[35 + x] = tostring(feldC[35 + x])
			end
			if feldC[(35 + x) + 1] == 0 then
				feldA[(35 + x) + 1] = "-"
			else
				feldA[(35 + x) + 1] = tostring(feldC[(35 + x) + 1])
			end
		elseif y == 1 then
			-- unterste Zeile
			if feldC[x - 1] == 0 then
				feldA[x - 1] = "-"
			else
				feldA[x - 1] = tostring(feldC[x - 1])
			end
			if feldC[x + 1] == 0 then
				feldA[x + 1] = "-"
			else
				feldA[x + 1] = tostring(feldC[x + 1])
			end
			if feldC[(7 + x) - 1] == 0 then
				feldA[(7 + x) - 1] = "-"
			else
				feldA[(7 + x) - 1] = tostring(feldC[(7 + x) - 1])
			end
			if feldC[7 + x] == 0 then
				feldA[7 + x] = "-"
			else
				feldA[7 + x] = tostring(feldC[7 + x])
			end
			if feldC[(7 + x) + 1] == 0 then
				feldA[(7 + x) + 1] = "-"
			else
				feldA[(7 + x) + 1] = tostring(feldC[(7 + x) + 1])
			end
		elseif x == 1 then
			-- erste Spalte
			if feldC[((y(y - 1) * 7) + 1) - 7] == 0 then
				feldA[((y(y - 1) * 7) + 1) - 7] = "-"
			else
				feldA[(((y - 1) * 7) + 1) - 7] = tostring(feldC[(((y - 1) * 7) + 1) - 7])
			end
			if feldC[(((y - 1) * 7) + 1) + 7] == 0 then
				feldA[(((y - 1) * 7) + 1) + 7] = "-"
			else
				feldA[(((y - 1) * 7) + 1) + 7] = tostring(feldC[(((y - 1) * 7) + 1) + 7])
			end
			if feldC[((((y - 1) * 7) + 1) - 7) + 1] == 0 then
				feldA[((((y - 1) * 7) + 1) - 7) + 1] = "-"
			else
				feldA[((((y - 1) * 7) + 1) - 7) + 1] = tostring(feldC[((((y - 1) * 7) + 1) - 7) + 1])
			end
			if feldC[((((y - 1) * 7) + 1) + 7) + 1] == 0 then
				feldA[((((y - 1) * 7) + 1) + 7) + 1] = "-"
			else
				feldA[((((y - 1) * 7) + 1) + 7) + 1] = tostring(feldC[((((y - 1) * 7) + 1) + 7) + 1])
			end
			if feldC[((y - 1) * 7) + 1] == 0 then
				feldA[((y - 1) * 7) + 1] = "-"
			else
				feldA[((y - 1) * 7) + 1] = tostring(feldC[((y - 1) * 7) + 1])
			end
		elseif x == 7 then
			-- letzte Spalte
			if feldC[(y * 7) - 7] == 0 then
				feldA[(y * 7) - 7] = "-"
			else
				feldA[(y * 7) - 7] = tostring(feldC[(y * 7) - 7])
			end
			if feldC[(y * 7) + 7] == 0 then
				feldA[(y * 7) + 7] = "-"
			else
				feldA[(y * 7) + 7] = tostring(feldC[(y * 7) + 7])
			end
			if feldC[(y * 7) - 1] == 0 then
				feldA[(y * 7) - 1] = "-"
			else
				feldA[(y * 7) - 1] = tostring(feldC[(y * 7) - 1])
			end
			if feldC[((y * 7) + 7) - 1] == 0 then
				feldA[((y * 7) + 7) - 1] = "-"
			else
				feldA[((y * 7) + 7) - 1] = tostring(feldC[((y * 7) + 7) - 1])
			end
			if feldC[(y * 7) - 1] == 0 then
				feldA[(y * 7) - 1] = "-"
			else
				feldA[(y * 7) - 1] = tostring(feldC[(y * 7) - 1])
			end
		else
			-- Mittendrin, damit sind 8 Felder zu pruefen
			if feldC[((y * 7) + x) - 1] == 0 then
				feldA[((y * 7) + x) - 1] = "-"
			else
				feldA[((y * 7) + x) - 1] = tostring(feldC[((y * 7) + x) - 1])
			end
			if feldC[(y * 7) + x] == 0 then
				feldA[(y * 7) + x] = "-"
			else
				feldA[(y * 7) + x] = tostring(feldC[(y * 7) + x])
			end
			if feldC[((y * 7) + x) + 1] == 0 then
				feldA[((y * 7) + x) + 1] = "-"
			else
				feldA[((y * 7) + x) + 1] = tostring(feldC[((y * 7) + x) + 1])
			end
			if feldC[(((y - 1) * 7) + x) - 1] == 0 then
				feldA[(((y - 1) * 7) + x) - 1] = "-"
			else
				feldA[(((y - 1) * 7) + x) - 1] = tostring(feldC[(((y - 1) * 7) + x) - 1])
			end
			if feldC[(((y - 1) * 7) + x) + 1] == 0 then
				feldA[(((y - 1) * 7) + x) + 1] = "-"
			else
				feldA[(((y - 1) * 7) + x) + 1] = tostring(feldC[(((y - 1) * 7) + x) + 1])
			end
			if feldC[(((y - 2) * 7) + x) - 1] == 0 then
				feldA[(((y - 2) * 7) + x) - 1] = "-"
			else
				feldA[(((y - 2) * 7) + x) - 1] = tostring(feldC[(((y - 2) * 7) + x) - 1])
			end
			if feldC[((y - 2) * 7) + x] == 0 then
				feldA[((y - 2) * 7) + x] = "-"
			else
				feldA[((y - 2) * 7) + x] = tostring(feldC[((y - 2) * 7) + x])
			end
			if feldC[(((y - 2) * 7) + x) + 1] == 0 then
				feldA[(((y - 2) * 7) + x) + 1] = "-"
			else
				feldA[(((y - 2) * 7) + x) + 1] = tostring(feldC[(((y - 2) * 7) + x) + 1])
			end
		end
	end
end

-- End user functions --
return objKlausraeumtauf
