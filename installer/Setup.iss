; Inno Setup 6 script — Srlily Updater Test
; Build:
;   iscc installer\Setup.iss /DAppVersion=1.0.2 /DAppArch=win-x64 /DPublishDir=..\publish\win-x64 /O..\artifacts /FSrlily.UpdaterTset-v1.0.2-win-x64-setup

#ifndef AppVersion
  #define AppVersion "0.0.0"
#endif
#ifndef AppArch
  #define AppArch "win-x64"
#endif
#ifndef PublishDir
  #define PublishDir "..\publish\win-x64"
#endif
#ifndef OutputBaseName
  #define OutputBaseName "Srlily.UpdaterTset-v" + AppVersion + "-" + AppArch + "-setup"
#endif
#ifndef OutputDir
  #define OutputDir "..\artifacts"
#endif

#if AppArch == "win-x64"
  #define ArchId "x64compatible"
  #define ArchInstall64 "x64compatible"
  #define ArchLabel "x64"
#elif AppArch == "win-arm64"
  #define ArchId "arm64"
  #define ArchInstall64 "arm64"
  #define ArchLabel "ARM64"
#elif AppArch == "win-x86"
  #define ArchId "x86compatible"
  #define ArchInstall64 ""
  #define ArchLabel "x86"
#else
  #define ArchId "x64compatible"
  #define ArchInstall64 "x64compatible"
  #define ArchLabel "x64"
#endif

#define AppName "Srlily Updater Test"
#define AppId "Srlily.UpdaterTset"
#define AppExeName "Srlily.UpdaterTset.exe"
#define AppPublisher "Srlily"
#define AppURL "https://github.com/Srlily/Srlily-Updater-Tset"

[Setup]
AppId={{6B8E2C4A-9F1D-4E7B-A3C5-8D0F2A6B4E9C}
AppName={#AppName}
AppVersion={#AppVersion}
AppVerName={#AppName} v{#AppVersion} ({#ArchLabel})
AppPublisher={#AppPublisher}
AppPublisherURL={#AppURL}
AppSupportURL={#AppURL}/issues
AppUpdatesURL={#AppURL}/releases
DefaultDirName={autopf}\{#AppId}
DefaultGroupName={#AppName}
DisableProgramGroupPage=yes
OutputDir={#OutputDir}
OutputBaseFilename={#OutputBaseName}
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog commandline
ArchitecturesAllowed={#ArchId}
#if ArchInstall64 != ""
ArchitecturesInstallIn64BitMode={#ArchInstall64}
#endif
UninstallDisplayIcon={app}\{#AppExeName}
UninstallDisplayName={#AppName}
SetupIconFile=..\src\Srlily.UpdaterTset\Assets\app.ico
VersionInfoVersion={#AppVersion}
VersionInfoCompany={#AppPublisher}
VersionInfoDescription={#AppName} Setup ({#AppArch})
VersionInfoProductName={#AppName}
VersionInfoProductVersion={#AppVersion}
CloseApplications=yes
RestartApplications=no
AllowNoIcons=yes
LicenseFile=..\LICENSE
ChangesAssociations=no

[[Languages]
; Chinese first so it is pre-selected on zh-CN systems; file must be UTF-8 with BOM.
Name: "chinesesimplified"; MessagesFile: "Languages\ChineseSimplified.isl"
Name: "english"; MessagesFile: "compiler:Default.isl"

[CustomMessages]
chinesesimplified.OpenInstallFolder=打开安装目录
english.OpenInstallFolder=Open install folder

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{#PublishDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#AppName}"; Filename: "{app}\{#AppExeName}"
Name: "{group}\{cm:OpenInstallFolder}"; Filename: "{app}"
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\{#AppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#AppExeName}"; Description: "{cm:LaunchProgram,{#AppName}}"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: filesandordirs; Name: "{app}\.srlily-updater"
