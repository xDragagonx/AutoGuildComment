Global("locales", {})
--create tables of each language
locales["eng_eu"]={}
locales["rus"]={}
locales["fr"]={}
locales["ger"]={}
locales["tr"]={}

--used as test \n is used as a newline
locales["eng_eu"][ "DominionText" ] = "\nDear Avarice gamers,\nDominion(s) are starting in less than 1 hour. Please prepare the following:\nPvP food of 10%'s | 3x3 vendor\nAlchemy potions +50 | Alchemy or playertrading, check Auction House\nPotents +40 | 3x3 vendor, Relic Master NPC\nMana Batteries | 3x3 vendor\nLegendary or Fabled Dragon Tears | Embrium vendor in Private Allod or at Auction House"
locales["fr"][ "DominionText" ] = "\nDear Avarice gamers,\nDominion(s) are starting in less than 1 hour. Please prepare the following:\nPvP food of 10%'s | 3x3 vendor\nAlchemy potions +50 | Alchemy or playertrading, check Auction House\nPotents +40 | 3x3 vendor, Relic Master NPC\nMana Batteries | 3x3 vendor\nLegendary or Fabled Dragon Tears | Embrium vendor in Private Allod or at Auction House"
locales["rus"][ "DominionText" ] = "\nDear Avarice gamers,\nDominion(s) are starting in less than 1 hour. Please prepare the following:\nPvP food of 10%'s | 3x3 vendor\nAlchemy potions +50 | Alchemy or playertrading, check Auction House\nPotents +40 | 3x3 vendor, Relic Master NPC\nMana Batteries | 3x3 vendor\nLegendary or Fabled Dragon Tears | Embrium vendor in Private Allod or at Auction House"
locales["ger"][ "DominionText" ] = "\nDear Avarice gamers,\nDominion(s) are starting in less than 1 hour. Please prepare the following:\nPvP food of 10%'s | 3x3 vendor\nAlchemy potions +50 | Alchemy or playertrading, check Auction House\nPotents +40 | 3x3 vendor, Relic Master NPC\nMana Batteries | 3x3 vendor\nLegendary or Fabled Dragon Tears | Embrium vendor in Private Allod or at Auction House"
locales["tr"][ "DominionText" ] = "\nDear Avarice gamers,\nDominion(s) are starting in less than 1 hour. Please prepare the following:\nPvP food of 10%'s | 3x3 vendor\nAlchemy potions +50 | Alchemy or playertrading, check Auction House\nPotents +40 | 3x3 vendor, Relic Master NPC\nMana Batteries | 3x3 vendor\nLegendary or Fabled Dragon Tears | Embrium vendor in Private Allod or at Auction House"

locales["eng_eu"][ "GuildLevelled" ] = "\nWe levelled up today, reason to celebrate!"
locales["fr"][ "GuildLevelled" ] = "\nNous avons progress\233 aujourd'hui, c'est une bonne raison de f\234ter \231a !"
locales["rus"][ "GuildLevelled" ] = "\nСегодня мы повысили уровень, повод для праздника!"
locales["ger"][ "GuildLevelled" ] = "\nWir sind heute aufgestiegen, ein Grund zum Feiern!"
locales["tr"][ "GuildLevelled" ] = "\nBug\252n seviye atladik, kutlamak i\231in bir sebep!"

locales = locales[common.GetLocalization()] -- trims all other languages except the one that common.getlocal got.