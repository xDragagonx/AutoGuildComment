Global("locales", {})
--create tables of each language
locales["eng_eu"]={}
locales["rus"]={}
locales["fr"]={}
locales["ger"]={}
locales["tr"]={}

--Name of dropped Insignia's in compass allod.
locales["eng_eu"][ "itemName" ] = "Packed Hero's Insignia"
locales["fr"][ "itemName" ] = "a ete ressuscite"
locales["rus"][ "itemName" ] = "возрождался"
locales["ger"][ "itemName" ] = "wurde"
locales["tr"][ "itemName" ] = "Paketlenmi? Kahraman?n Muskas?"

locales = locales[common.GetLocalization()] -- trims all other languages except the one that common.getlocal got.