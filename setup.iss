[Setup]
; REMARQUE : La valeur de AppId identifie l'application. Ne la modifiez pas si vous publiez des mises à jour !
AppId={{D3B3C842-83A5-4874-90BC-68C1B6CA11C2}
AppName=VIV Formation Toolbox
AppVersion=0.1.1
AppPublisher=VIV
; Installation au niveau utilisateur pour éviter l'UAC (nécessaire pour les MAJ automatiques silencieuses)
DefaultDirName={userpf}\VIVFormationToolbox
DefaultGroupName=VIV Formation
SetupIconFile=windows\runner\resources\app_icon.ico
PrivilegesRequired=lowest
OutputDir=Output
OutputBaseFilename=viv_formation_toolbox_setup_v0.1.1
Compression=lzma
SolidCompression=yes
; Force la fermeture de l'application Flutter en cours d'exécution
CloseApplications=force

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "build\windows\x64\runner\Release\viv_formation_toolbox.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\VIV Formation Toolbox"; Filename: "{app}\viv_formation_toolbox.exe"
Name: "{autodesktop}\VIV Formation Toolbox"; Filename: "{app}\viv_formation_toolbox.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\viv_formation_toolbox.exe"; Description: "{cm:LaunchProgram,VIV Formation Toolbox}"; Flags: nowait postinstall skipifsilent
