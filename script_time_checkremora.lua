-- Gestion du chauffage

-- Version 1.2 du 30/11/2017 
-- Modification des appels command array qui paralysent domoticz

-- Ce script permet de vérifier l'état des chauffages dans Remora et de reporter la valeur dans Domoticz
-- Idée originale développée ici http://domoticz.blogspot.fr/2014/07/un-exemple-de-script-lua-time-coherence.html

-- Ajout d'une notification en cas de détection d'un écart entre le remora et les valeurs Domoticz

-- Necessitesde positionner la librairie JSON (http://regex.info/blog/lua/json) dans /home/pi/domoticz/scripts/lua

-- Positionner l'adresse de Domoticz (utile pour les requêtes json de création de variables
local ip = '127.0.0.1:8080'   -- user:pass@ip:port de domoticz

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

json=(assert(loadfile "/home/pi/domoticz/scripts/lua/JSON.lua"))()

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

   if ( RemoraLevels[FilsPilotes["fp"..i]] == tonumber(otherdevices_svalues[ListeChauffages["fp"..i]]) ) then

      if (DEBUG) then print("valeur cohérente"..ListeChauffages["fp"..i]) end

   else

      date=os.date("%Y%m%d-%X")
      print(date.." : valeur incohérente entre Remora et Domoticz, mise à jour de la valeur dans Domoticz pour "..ListeChauffages["fp"..i]) 
      local cmd=ip..'/json.htm?type=command&param=switchlight&idx='..otherdevices_idx[ListeChauffages["fp"..i]]..'&switchcmd=Set%20Level&level='..RemoraLevels[FilsPilotes["fp"..i]]..'&passcode='
      if (DEBUG) then print(cmd) end
      table.insert (commandArray, { ['OpenURL'] = cmd} )

   end
end

return commandArray



