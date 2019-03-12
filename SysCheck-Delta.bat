CHCP 1252

@+
::[ENGLISH]
::SysCheck-Delta By Lucas "Lucaspec72" Pecquenard
::This customized version of SysCheck was made for employees of "Delta Technologies", and based of SysCheck v1.4

::[FRANCAIS]
::SysCheck-Delta Par Lucas "Lucaspec72" Pecquenard
::Cette version de SysCheck est désignée aux employés de l'entreprise "Delta Technologies", et est basée de SysCheck v1.4


::{THE NOTES IN THE PROGRAM ARE IN FRENCH, SORRY FOR THE INCOVENIENCE}
::change le mode d'encryption en sortie du programme
::cette commande cache les commandes effectuées
@echo off
::des commandes supplémentaires sont nécéssaires, elles sonts chargées avec un délai
setlocal enabledelayedexpansion
::cette commande définit le nom de la fenêtre
title SysCheck-Delta
::cette commande définit la taille de la fenetre
mode con: cols=35 lines=10
::les commandes echo Scan de : sont juste là pour savoir ou en est le programme pendant le scan
echo Scan De : bios
::les commandes avec >>SysCheckdelta.log à la fin mettent les informations dans un fichier temporaire appelé "SysCheckdelta.log" (cette commande ci n'a qu'un ">" car elle ecrase un potentiel scan précédent)
::les commandes echo avec []NOM[] sonts juste des séparateurs pour le fichier log
echo []BIOS[] >SysCheckdelta.log
::les commandes wmic récupèrent diverses informations sur la configuration de l'ordinateur (Le scan est local, aucun fichier ne passe par internet)
wmic bios get serialnumber /format:List | more >>SysCheckdelta.log
echo Scan De : computersystem
echo []Modele De L'Ordinateur[] >>SysCheckdelta.log
wmic computersystem get Model /format:List | more >>SysCheckdelta.log
echo Scan De : cpu
echo []Processeur[] >>SysCheckdelta.log
wmic cpu get Name, Caption /format:List | more >>SysCheckdelta.log
echo Scan De : memorychip
echo []Memoire Vive[] >>SysCheckdelta.log
::les sous-programmes si-dessous sonts interresants, car ils récupèrent l'information "totalphysicalmemory" de la section computersystem de wmic pour ensuite la convertir pour obtenir le nombre de Gigaoctets de mémoire vive
::celui ci récupère la valeur de "totalphysicalmemory" et donne cette valeur à la variable "ram"
for /f "tokens=2 delims==" %%f in ('wmic computersystem get totalphysicalmemory /value ^| find "="') do set ram=%%f
::cette commande définit que la variable "advanced" est égale à la variable "ram" pour basiquement lui donner la même valeur
set "advanced=%ram%"
::cette commande crée un fichier "temp.tmp" pour stocker la valeur "advanced" plus facilement
echo %advanced%>temp.tmp
::ce sous-programme inverse la valeur de la variable stockée dans "temp.tmp" (exemple: 123 deviendrait 321)
for %%l in (temp.tmp) do set /a len=%%~zl
set /a len-=2
set "reverse="
set "char="
for /l %%i in (0,1,%len%) do (
  for /f "usebackq" %%a in (temp.tmp) do (
    set "char=%%a"
    set "reverse=!char:~%%i,1!!reverse!"
  )
)
::ce sous-programme récupère la valeur "!reverse!" et insère un "+" tout les trois caractères (exemple: 987654321 devient 987+654+321)
SET Text=!reverse!
SET Return=
FOR /L %%I IN (0,3,100) DO (
    CALL SET Letter=!Text:~%%I,3!
    IF NOT "!Letter!" == "" (
        SET Return=!Return!+!Letter!
    ) ELSE (
        goto loopdone
    )
)
::ce programme fait la même chose que le programme cité avant, il inverse l'ordre des charactères de la valeur "!reverse!" pour remetre la valeur dans le "bon sens" (exemple: 987+654+321 devient 123+456+789)
:loopdone
SET Return=%Return:~1,999%
set "advanced=%Return%"
echo %advanced%>temp.tmp
for %%l in (temp.tmp) do set /a len=%%~zl
set /a len-=2
set "reverse="
set "char="
for /l %%i in (0,1,%len%) do (
  for /f "usebackq" %%a in (temp.tmp) do (
    set "char=%%a"
    set "reverse=!char:~%%i,1!!reverse!"
  )
)
::la valeur est en suite placée dans le fichier "temp.tmp"
echo !reverse!>temp.tmp
::ici un programme sépare la valeur dans "temp.tmp" pour calculer la valeur en gigaoctets (ou gigabytes selon votre préférence) de la mémoire vive de l'ordinateur
for /f "tokens=1 delims=+" %%f in (temp.tmp) do set "myVar=%%f"
::cette commande supprime le fichier "temp.tmp" car il n'est plus nécéssaire
del temp.tmp
::cette commande sort (ENFIN) la valeur en Go/Gb de la mémoire vive
echo Valeur De La Memoire Vive = %myVar%Gb (%ram% Bytes)>>SysCheckdelta.log
echo Scan De : diskdrive
echo []Peripheriques De Stockage[] >>SysCheckdelta.log
wmic diskdrive get Name, Manufacturer, Model, InterfaceType, MediaLoaded, MediaType | more >>SysCheckdelta.log
echo Scan De : logicaldisk
echo []Partitions[] >>SysCheckdelta.log
::ce sous-programme récupère les données relative aux partitions de stockages des péripheriques tel que clés usb, disques durs physiques HDD et disques à état solide SSD ou possiblement dans certains cas même des disques optiques tel que des CD roms ou DvD
(for /f "tokens=1-3" %%a in ('
  WMIC LOGICALDISK GET FreeSpace^,Name^,Size ^|FINDSTR /I /V "Name"
  ') do (
    if not "%%c"=="" (
      echo wsh.echo vbNewLine ^& "%%b" ^& " free=" ^& FormatNumber^(cdbl^(%%a^)/1024/1024/1024, 2^)^& " GB"^& " size=" ^& FormatNumber^(cdbl^(%%c^)/1024/1024/1024, 2^)^& " GB"
    )
  )
) > tmp.vbs
cscript //nologo tmp.vbs >>SysCheckdelta.log
del tmp.vbs
echo.>>SysCheckdelta.log
wmic logicaldisk get Name, Compressed, Description, DriveType, FileSystem, SupportsDiskQuotas, VolumeDirty, VolumeName | more >>SysCheckdelta.log
echo Scan De : os
echo []Systeme D'Exploitation[] >>SysCheckdelta.log
wmic os get Version, Caption /format:list | more >>SysCheckdelta.log
::cette commande récupère tout les fichiers de "SysCheckdelta.log" et les met dans le fichier texte(txt) "SysCheck-Delta_Log.txt" en enlevant la plupart des espaces vide prenant de la place pour rien, cette étape peut paraitre inutile ou avoir peut d'utilitée pratique, mais détrompez vous car cette petite commande libère au moins une trentaine de lignes !
findstr /v /r /c:"^$" /c:"^[\ \	]*$"  "SysCheckdelta.log" > "SysCheck-Delta_Log.txt"
::cette commande efface le fichier temporaire "SysTechdelta.log"
del SysCheckdelta.log
echo Merci D'utiliser SysCheck-Delta
::cette commande définit un temps d'attente de 1 seconde
timeout /t 1 /nobreak>null
::cette commande supprime le fichier temporaire utilisé ci-dessus
del null
::cette commande change la taille de la fenetre
mode con: cols=47 lines=4
::cette petite commande enlève tout le texte
cls
::cette commande echo est juste un support graphique pour la commande en dessous
echo Voulez vous faire un test de connection ? [O/N]
::cette commande définit un choix Oui/Non en sortant une valeur ERRORLEVEL
Choice /N
::cette commande est un passage vers un autre endroit du script (par exemple speedtest-1 ou speedtest-2)
goto speedtest-%ERRORLEVEL%
::une ligne qui commence par ":"puis d'un nom est le point de référence de la commande goto
:speedtest-2
::cette commande ouvre le fichier log crée par le programme
start SysCheck-Delta_Log.txt
exit
:speedtest-1
::cette commande ouvre le site "www.speedtest.net/fr"
start https://www.speedtest.net/fr
::cette commande indique une pause de 2 secondes dans l'execution du programme
timeout /t 2 /nobreak>null
::cette commande efface le fichier temporaire "null"
del null
::cette boucle ouvre une boite messagebox graçe à Cscript et attend sa fermeture pour passer à la suite
(
echo MsgBox "Si une boite avec du texte apparait, appuyez sur 'I Concent' puis sur 'GO', sinon appuyez juste sur 'GO'",vbInformation+vbSystemModal,"SysCheck-Delta"> msgbox.vbs
cscript msgbox.vbs
del msgbox.vbs
) | pause
echo MsgBox "Quand le test est fini, transmettre les resultats a un employe de Delta Technologies",vbInformation+vbSystemModal,"SysCheck-Delta"> msgbox.vbs
cscript msgbox.vbs
del msgbox.vbs
start SysCheck-Delta_Log.txt
exit