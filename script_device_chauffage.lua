-- Gestion du chauffage

-- Gestion de groupes de chauffages dans Domoticz sous forme de "Dummy" interrupteurs ("Selector Switch")
-- Pilotant des chauffages individuels disposant des mêmes défintions de niveau

-- Version 2.1 du 30/11/2017
-- Modification des appels command array qui paralysent domoticz

-- Debuggage (FALSE ou true)
DEBUG=FALSE

-- Positionner l'adresse de Domoticz (utile pour les requêtes json de création de variables
local ip = '127.0.0.1:8080'   -- user:pass@ip:port de domoticz

-- Positionner les "Macro"-chauffages tels que decrits dans Domoticz 
-- en reprenant EXACTEMENT les libellés mis en place dans Domoticz
-- attention aux virgules et accolades dans la declartion du tableau

MacroChauffages =   {
	["ChauffageSejouretChambre4"]={ 
            'Chauffage-Sejour', 
            'Chauffage-Chambre4' 
        },
	["Chauffages-Tous"]={ 
            'Chauffage-Chambre1', 
            'Chauffage-Chambre2', 
            'Chauffage-Chambre3', 
            'Chauffage-Chambre4',
            'Chauffage-Sejour',
            'Chauffage-Cuisine',
            'Chauffage-SdB'
        },
        ["Chauffages-ToutesChambres"]={
            'Chauffage-Chambre1',
            'Chauffage-Chambre2',
            'Chauffage-Chambre3',
            'Chauffage-Chambre4'
        }
}


-- Positionner les niveaux associés dans Domoticz (on suppose que pour chaque chauffage on a decrit les memes niveaux
-- DomoLevels = { ["OfF"]=0, ["Level1"]=10, ["Level2"]=20, ["Level3"]=30 ["Unused"]=40 }
-- Par défaut : 'Level1', 'Level2', 'Level3', 'Level4'

-- Les libellés sont associés ici : 'Off', 'HorsGel', 'Economique', 'Confort'
DomoLevels = { ["Off"]=0, ["HorsGel"]=10, ["Economique"]=20, ["Confort"]=30 , ["Unused"]=40 }

-- Ne rien mettre dans le tableau ci-dessous. Un calcul permet de determiner le rattachement des chauffages au macro
ChauffagesInverses =  { }


---------------
-- Fonctions --
---------------

function evaluate_macro(chauffagemacro,statutmicro)
    local constant=true
    local DEBUG=false

    if (DEBUG) then print('evaluating macro chauffage '..chauffagemacro..' statutmicro : '..statutmicro ) end
    for c,autrechauffage in pairs(MacroChauffages[chauffagemacro]) do 
      if (DEBUG) then print(c .. '.....' .. autrechauffage .. '... level ...' .. otherdevices_svalues[autrechauffage] ) end
      constant = constant and (otherdevices_svalues[autrechauffage]==statutmicro) 
    end

    if constant then 
       return (statutmicro) else return(DomoLevels["Unused"]) 
    end

end


function timedifference(s)
   year = string.sub(s, 1, 4)
   month = string.sub(s, 6, 7)
   day = string.sub(s, 9, 10)
   hour = string.sub(s, 12, 13)
   minutes = string.sub(s, 15, 16)
   seconds = string.sub(s, 18, 19)
   t1 = os.time()
   t2 = os.time{year=year, month=month, day=day, hour=hour, min=minutes, sec=seconds}
   difference = os.difftime (t1, t2)
   return difference
end

function urlencode(str)
   if (str) then
   str = string.gsub (str, "\n", "\r\n")
   str = string.gsub (str, "([^%w ])",
   function (c) return string.format ("%%%02X", string.byte(c)) end)
   str = string.gsub (str, " ", "+")
   end
   return str
end

-----------------------
-- Fin des fonctions --
-----------------------


commandArray = {}

print('Script fired script_device_chauffage.lua')


if (DEBUG) then
   for deviceName,deviceValue in pairs(devicechanged) do
      print ("LUA Device based event fired on '"..deviceName.."', value '"..tostring(deviceValue).."'")
   end
end


for macrochauffage in pairs(MacroChauffages) do

   if (DEBUG) then print ('Test du macrochauffage : '  .. macrochauffage ) end

   if (devicechanged[macrochauffage]) then 
      print ("LUA Macrochauffage '"..macrochauffage.."', value '"..devicechanged[macrochauffage].."' level '"..otherdevices_svalues[macrochauffage].."'")

      level=devicechanged[macrochauffage]
      valeur=otherdevices_svalues[macrochauffage]

      -- on crée dynamiquement une variable pour stocker le dernier raffraichissement du macrochauffage pour le statut donné
      if(uservariables['CHAUFF_'.. macrochauffage ..'_'.. otherdevices[macrochauffage]] == nil) then

          print('   CHAUFF : creation variable manquante CHAUFF_'..macrochauffage..'_'.. otherdevices[macrochauffage])
          local cmd=ip..'/json.htm?type=command&param=saveuservariable&vname=CHAUFF_'..urlencode(macrochauffage)..'_'.. otherdevices[macrochauffage] ..'&vtype=2&vvalue='..urlencode(otherdevices_lastupdate[macrochauffage])
	  if (DEBUG) then print (cmd) end
          table.insert (commandArray, { ['OpenURL'] = cmd} )
 
      elseif (timedifference(uservariables['CHAUFF_'..macrochauffage..'_'..otherdevices[macrochauffage]]) < 3) then

         print('    Reentrance pour :' .. macrochauffage ..' Statut: ' .. otherdevices[macrochauffage] )

      else
   
         if (DEBUG) then print ('level to apply : '.. level .. ' value :' .. valeur ) end
   
         if ( level ~='Unused' ) then
   
            for chauffage in pairs(MacroChauffages[macrochauffage]) do
   
               if (DEBUG) then print ('Evaluation du chauffage : ' .. MacroChauffages[macrochauffage][chauffage] .. ' old level  : '..tostring(otherdevices_svalues[MacroChauffages[macrochauffage][chauffage]])  ) end
   
               if ( tostring(DomoLevels[level])~=otherdevices_svalues[MacroChauffages[macrochauffage][chauffage]] ) then
   
                  if (DEBUG) then print ('...Application du niveau ' .. level .. ' au chauffage : ' .. MacroChauffages[macrochauffage][chauffage] .. ' : Set level : ' .. tostring(DomoLevels[level]) ) end
                  local cmd=ip..'/json.htm?type=command&param=switchlight&idx='..otherdevices_idx[MacroChauffages[macrochauffage][chauffage]]..'&switchcmd=Set%20Level&level='..DomoLevels[level]..'&passcode='
		  if (DEBUG) then print (cmd) end
                  table.insert (commandArray, { ['OpenURL'] = cmd} )

   	       else

                  if (DEBUG) then print ('...Niveau inchange ' .. level .. ' du chauffage : ' .. MacroChauffages[macrochauffage][chauffage]  ) end
               end
   
            end

         end

         commandArray['Variable:CHAUFF_'..macrochauffage..'_'..otherdevices[macrochauffage]]=otherdevices_lastupdate[macrochauffage]

      end 
   
   end

end


-- inversion du tableau chauffagemacros, on cherche a trouver pour chaque chauffage micro les chauffages macros auxquels il appartient
for cle,valeur in pairs(MacroChauffages) do
   for chauffagemacro,chauffagemicro in pairs(valeur)
   do
      -- print(chauffagemicro..':'..cle)
      if ( ChauffagesInverses[chauffagemicro] == nil ) then
          ChauffagesInverses[chauffagemicro]= cle
      else
          ChauffagesInverses[chauffagemicro]= ChauffagesInverses[chauffagemicro] ..' '.. cle
      end
   end
end


for micro,listemacros in pairs(ChauffagesInverses) do

   if (devicechanged[micro]) then

      print ("LUA Device based event fired on micro : '"..micro.."', value : '"..devicechanged[micro].."'")
      -- print('   ' .. micro.. ' is in ')

      for macro in string.gmatch(listemacros, "[^%s]+") do

         if (DEBUG) then print ( '   '.. macro .. ' last update : '.. uservariables['CHAUFF_'.. macro ..'_'.. otherdevices[macro]] ) end

         -- on ne fait le calcul que si la veleur du chauffage micro pourrait changer la valeur du macro
         if ( devicechanged[micro] ~= otherdevices[macro] ) then

            level =  evaluate_macro(macro,otherdevices_svalues[micro])
   
            if level~=otherdevices_svalues[macro] then

               print('Application au macro chauffage :' .. macro .. ' valeur :' .. evaluate_macro(macro,otherdevices_svalues[micro]))
               local cmd=ip..'/json.htm?type=command&param=switchlight&idx='..otherdevices_idx[macro]..'&switchcmd=Set%20Level&level='..level..'&passcode='
	       if (DEBUG) then print (cmd) end
               table.insert (commandArray, { ['OpenURL'] = cmd} )

            end

         end

      end

   end

end


return commandArray

