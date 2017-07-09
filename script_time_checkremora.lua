-- Gestion du chauffage

-- Version 1.1 du 9/7/2017

-- Ce script permet de vérifier l'état des chauffages dans Remora et de reporter la valeur dans Domoticz
-- Idée originale développée ici http://domoticz.blogspot.fr/2014/07/un-exemple-de-script-lua-time-coherence.html

-- Ajout d'une notification en cas de détection d'un écart

-- Necessite de positionner la librairie JSON (http://regex.info/blog/lua/json) dans /home/pi/domoticz/scripts/lua

-- Positionner la liste des associations fil pilote / interrupteur Domoticz 
-- en reprenant EXACTEMENT les libellés mis en place dans Domoticz
-- attention aux virgules et accolades dans la declartion du tableau

ListeChauffages =   {
            fp1='Chauffage-Chambre1', 
            fp2='Chauffage-Chambre2', 
            fp3='Chauffage-Chambre3', 
            fp4='Chauffage-Chambre4',
            fp5='Chauffage-Cuisine',
            fp6='Chauffage-Sejour',
            fp7='Chauffage-SdB'
}


-- Positionner les niveaux associés des valeurs de Remora avec les niveaux dans Domoticz (on suppose que pour chaque chauffage on a decrit les memes niveaux) avec les 
RemoraLevels = { ["A"]=0, ["H"]=10, ["E"]=20, ["C"]=30 }

-- Debuggage (FALSE ou true)
DEBUG=FALSE

commandArray = {}

-- json = (loadfile "lua/JSON.lua")() -- put the lib in "lua" folder
json = (loadfile "/home/pi/domoticz/scripts/lua/JSON.lua")() -- put the lib in "lua" folder

-- Recuperation de l'état de tous les fils pilotes
-- Requête JSON via CURL interprétée
-- par librairie http://regex.info/blog/lua/json
--
if (DEBUG) then print ('curl http://remora/fp 2>/dev/null ') end

local query=assert(io.popen('curl http://remora/fp 2>/dev/null'))
local config = query:read('*all')
query:close()
if (DEBUG) then print (config) end

local FilsPilotes = json:decode(config)
 
-- Recupération du statut de chaque fil pilote
for i = 1,7,1 do

   
   if (DEBUG) then print("Remora : Fil Pilote "..i.." :état " .. FilsPilotes["fp"..i]) end
   if (DEBUG) then print("Remora : Fil Pilote "..i.." :valeur " .. RemoraLevels[FilsPilotes["fp"..i]])  end
   if (DEBUG) then print("Domoticz : Chauffage  ".. ListeChauffages["fp"..i] ..": état: " .. otherdevices_svalues[ListeChauffages["fp"..i]]) end

   if ( RemoraLevels[FilsPilotes["fp"..i]] == tonumber(otherdevices_svalues[ListeChauffages["fp"..i]]) ) then
      if (DEBUG) then print("valeur cohérente entre Remora et Domoticz, pas de mise à jour de la valeur dans Domoticz pour "..ListeChauffages["fp"..i]) end
   else
      print("valeur incohérente entre Remora et Domoticz, mise à jour de la valeur dans Domoticz pour "..ListeChauffages["fp"..i]) 
      if (DEBUG) then print ( ListeChauffages["fp"..i]..':'..'Set Level '..tostring( RemoraLevels[FilsPilotes["fp"..i]]) ) end
      date=os.date("%Y%m%d-%X")
      commandArray[ListeChauffages["fp"..i]]='Set Level '..tostring( RemoraLevels[FilsPilotes["fp"..i]] )
      commandArray['SendNotification']=date.." : valeur incohérente entre Remora et Domoticz, mise à jour faite  dans Domoticz pour "..ListeChauffages["fp"..i]

   end

end

return commandArray



