-- Gestion du chauffage

-- Version 1.0 du 15/10/2016
-- Gestion de groupes de chauffages dans Domoticz sous forme de "Dummy" interrupteurs ("Selector Switch")
-- Pilotant des chauffages individuels disposant des mêmes défintions de niveau

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
            'Chauffage-SdB',
            'ChauffageSejouretChambre4'
        }
}


-- Positionner les niveaux associés dans Domoticz (on suppose que pour chaque chauffage on a decrit les memes niveaux
-- DomoLevels = { ["OfF"]=0, ["Level1"]=10, ["Level2"]=20, ["Level3"]=30 }
-- Par défaut : 'Level1', 'Level2', 'Level3'

-- Les libellés sont associés ici : 'Off', 'HorsGel', 'Economique', 'Confort'
DomoLevels = { ["Off"]=0, ["HorsGel"]=10, ["Economique"]=20, ["Confort"]=30 }

-- Debuggage (FALSE ou 1)
-- Creer un Dummy interrupteur TestScript pour visualisation directement dans l'interface Domoticz
DEBUG=FALSE


commandArray = {}


if (DEBUG) then
   for deviceName,deviceValue in pairs(devicechanged) do
      print ("Device based event fired on '"..deviceName.."', value '"..tostring(deviceValue).."'")
   end
end


for macrochauffage in pairs(MacroChauffages) do

   if (DEBUG) then print ('Test du macrochauffage : ' .. macrochauffage) end

   if (devicechanged[macrochauffage]) then
      print ("LUA Device based event fired on '"..macrochauffage.."', value '"..devicechanged[macrochauffage].."'")

      for level in pairs(DomoLevels) do
         if (DEBUG) then print('Test du nivau ' .. level .. ': valeur ' .. DomoLevels[level]) end
         if (devicechanged[macrochauffage] == level ) then
         if (DEBUG) then print ('Found mode to apply : '.. level ) end
            for chauffage in pairs(MacroChauffages[macrochauffage]) do
               if (DEBUG) then print ('Application du niveau' .. level .. 'au chauffage suivant :' .. MacroChauffages[macrochauffage][chauffage]) end
               if (DEBUG) then print('Applying Set Level '..tostring(DomoLevels[level])) end
               commandArray[ MacroChauffages[macrochauffage][chauffage]]='Set Level '..tostring(DomoLevels[level])
            end
            if (DEBUG) then commandArray['TestScript']='On' end
         end
      end

   end 

end

return commandArray

