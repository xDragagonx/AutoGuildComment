Global("locales", {})
--create tables of each language
locales["eng_eu"]={}
locales["rus"]={}
locales["fr"]={}
locales["ger"]={}
locales["tr"]={}

-- \n is used as a newline indicator
locales["eng_eu"][ "DominionPrepText" ] = "\nDear Avarice gamers,\nDominion(s) are starting in less than 1 hour. Please prepare the following:\nPvP food of 10%'s | 3x3 vendor\nAlchemy potions +50 | Alchemy or playertrading, check Auction House\nPotents +40 | 3x3 vendor, Relic Master NPC\nMana Batteries | 3x3 vendor\nLegendary or Fabled Dragon Tears | Embrium vendor in Private Allod or at Auction House"
locales["fr"][ "DominionPrepText" ] = "\nDear Avarice gamers,\nDominion(s) are starting in less than 1 hour. Please prepare the following:\nPvP food of 10%'s | 3x3 vendor\nAlchemy potions +50 | Alchemy or playertrading, check Auction House\nPotents +40 | 3x3 vendor, Relic Master NPC\nMana Batteries | 3x3 vendor\nLegendary or Fabled Dragon Tears | Embrium vendor in Private Allod or at Auction House"
locales["rus"][ "DominionPrepText" ] = "\nDear Avarice gamers,\nDominion(s) are starting in less than 1 hour. Please prepare the following:\nPvP food of 10%'s | 3x3 vendor\nAlchemy potions +50 | Alchemy or playertrading, check Auction House\nPotents +40 | 3x3 vendor, Relic Master NPC\nMana Batteries | 3x3 vendor\nLegendary or Fabled Dragon Tears | Embrium vendor in Private Allod or at Auction House"
locales["ger"][ "DominionPrepText" ] = "\nDear Avarice gamers,\nDominion(s) are starting in less than 1 hour. Please prepare the following:\nPvP food of 10%'s | 3x3 vendor\nAlchemy potions +50 | Alchemy or playertrading, check Auction House\nPotents +40 | 3x3 vendor, Relic Master NPC\nMana Batteries | 3x3 vendor\nLegendary or Fabled Dragon Tears | Embrium vendor in Private Allod or at Auction House"
locales["tr"][ "DominionPrepText" ] = "\nDear Avarice gamers,\nDominion(s) are starting in less than 1 hour. Please prepare the following:\nPvP food of 10%'s | 3x3 vendor\nAlchemy potions +50 | Alchemy or playertrading, check Auction House\nPotents +40 | 3x3 vendor, Relic Master NPC\nMana Batteries | 3x3 vendor\nLegendary or Fabled Dragon Tears | Embrium vendor in Private Allod or at Auction House"

locales["eng_eu"][ "GuildLevelled" ] = "\nWe levelled up today, reason to celebrate!"
locales["fr"][ "GuildLevelled" ] = "\nNous avons progress\233 aujourd'hui, c'est une bonne raison de f\234ter \231a !"
locales["rus"][ "GuildLevelled" ] = "\nСегодня мы повысили уровень, повод для праздника!"
locales["ger"][ "GuildLevelled" ] = "\nWir sind heute aufgestiegen, ein Grund zum Feiern!"
locales["tr"][ "GuildLevelled" ] = "\nBug\252n seviye atladik, kutlamak i\231in bir sebep!"

locales["eng_eu"][ "RecruitmentButtonText" ] = "Open your chat input and click to recruit"
locales["fr"][ "RecruitmentButtonText" ] = "Ouvrez votre entr\233e de chat et cliquez pour recruter"
locales["rus"][ "RecruitmentButtonText" ] = "Откройте вход в чат и нажмите на кнопку набора"
locales["ger"][ "RecruitmentButtonText" ] = "?ffnen Sie Ihre Chateingabe und klicken um zu rekrutieren"
locales["tr"][ "RecruitmentButtonText" ] = "Sohbet girisinizi a\231in ve ise almak i\231in tiklayin"

locales["eng_eu"][ "NoTabardsLeft" ] = "There are no regular tabards left to give. Check if inactives can be reclaimed and assign them to the new guild member, please."
locales["fr"][ "NoTabardsLeft" ] = "There are no regular tabards left to give. Check if inactives can be reclaimed and assign them to the new guild member, please."
locales["rus"][ "NoTabardsLeft" ] = "There are no regular tabards left to give. Check if inactives can be reclaimed and assign them to the new guild member, please."
locales["ger"][ "NoTabardsLeft" ] = "There are no regular tabards left to give. Check if inactives can be reclaimed and assign them to the new guild member, please."
locales["tr"][ "NoTabardsLeft" ] = "There are no regular tabards left to give. Check if inactives can be reclaimed and assign them to the new guild member, please."

locales["eng_eu"][ "ReturnGuildMessage" ] = "No daily message stored to put back."
locales["fr"][ "ReturnGuildMessage" ] = "No daily message stored to put back."
locales["rus"][ "ReturnGuildMessage" ] = "No daily message stored to put back."
locales["ger"][ "ReturnGuildMessage" ] = "No daily message stored to put back."
locales["tr"][ "ReturnGuildMessage" ] = "No daily message stored to put back."

locales["eng_eu"][ "Astral Megaphone" ] =  "Astral Megaphone"
locales["fr"][ "Astral Megaphone" ] =      "Astral Megaphone"
locales["rus"][ "Astral Megaphone" ] =     "Astral Megaphone"
locales["ger"][ "Astral Megaphone" ] =     "Astral Megaphone"
locales["tr"][ "Astral Megaphone" ] =      "Astral Megaphone"

locales["eng_eu"][ "NoMegaphonesLeft" ] =   "No Astral Megaphones available. Used /zone. Update your Astral Megaphones."
locales["fr"][ "NoMegaphonesLeft" ] =       "No Astral Megaphones available. Used /zone. Update your Astral Megaphones."
locales["rus"][ "NoMegaphonesLeft" ] =      "No Astral Megaphones available. Used /zone. Update your Astral Megaphones."
locales["ger"][ "NoMegaphonesLeft" ] =      "No Astral Megaphones available. Used /zone. Update your Astral Megaphones."
locales["tr"][ "NoMegaphonesLeft" ] =       "No Astral Megaphones available. Used /zone. Update your Astral Megaphones."



locales = locales[common.GetLocalization()] -- trims all other languages except the one that common.getlocal got.