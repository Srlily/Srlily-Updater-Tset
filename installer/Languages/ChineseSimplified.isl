; *** Inno Setup 6 简体中文语言文件 ***
; 必须以 UTF-8 with BOM 保存，否则 LanguageName 会乱码/回退为 English。
; 含完整 [Messages]，保证向导界面本身为中文，而不只是 [CustomMessages]。

[LanguageSetup]
LanguageName=简体中文 (Chinese Simplified)
LanguageID=$0804
LanguageCodePage=936
DialogFontName=Microsoft YaHei UI
DialogFontSize=9
WelcomeFontName=Segoe UI
WelcomeFontSize=12
TitleFontName=Segoe UI
TitleFontSize=29
CopyrightFontName=Segoe UI
CopyrightFontSize=8
RightToLeft=no

[Messages]

SetupAppTitle=安装
SetupWindowTitle=安装 - %1
ClickNext=单击“下一步”继续，或单击“取消”退出安装程序。
BeveledLabel=
BrowseDialogTitle=浏览文件夹
BrowseDialogLabel=在下列列表中选择一个文件夹，然后单击“确定”。
NewFolderName=新建文件夹

WizardSelectDir=选择安装位置
SelectDirLabel=请选择 %1 的安装路径。
SelectDirLabel3=安装程序将把 %1 安装在下列文件夹中。要安装到不同文件夹，请单击“浏览”。
SelectDirBrowseLabel=单击“下一步”继续。要选择其他文件夹，请单击“浏览”。
DiskSpaceMBLabel=至少需要有 [mb] MB 的可用磁盘空间。

WizardSelectComponents=选择组件
SelectComponentsLabel=请选择要安装的组件，以及要卸载的组件。
SelectComponentsLabel2=选择您想要安装的组件，清除您不想安装的组件。单击“下一步”继续。
FullInstallation=完全安装
CompactInstallation=简洁安装
CustomInstallation=自定义安装
NoUninstallWarningLabel=以下组件已安装在您的电脑中，将不会被卸载：%n%n%1%n%n您要继续吗？

WizardSelectTasks=选择附加任务
SelectTasksLabel=请选择安装程序在安装 %1 时要执行的附加任务。
SelectTasksLabel2=请选择要执行的附加任务，然后单击“下一步”。

WizardReady=准备安装
ReadyLabel1=安装程序现在准备好开始安装 %1。
ReadyLabel2a=单击“安装”继续安装，或单击“上一步”返回并修改设置。
ReadyLabel2b=单击“安装”继续安装。
ReadyMemoUserInfo=用户信息：
ReadyMemoDir=目标位置：
ReadyMemoType=安装类型：
ReadyMemoComponents=所选组件：
ReadyMemoGroup=开始菜单文件夹：
ReadyMemoTasks=附加任务：

WizardPreparing=正在准备安装
PreparingLabel=安装程序正在准备将 %1 安装到您的电脑中，请稍候。
PreparingMemoInstall=正在安装：
PreparingMemoInstallApp=正在安装 %1：

WizardInstalling=正在安装
InstallingLabel=安装程序正在将 %1 安装到您的电脑中，请稍候。

WizardFinished=安装完成
FinishedHeadingLabel=[name] 安装完成
FinishedLabelNoIcons=安装程序已在您的电脑中安装了 %1。
FinishedLabel=安装程序已在您的电脑中安装了 %1。可通过已创建的快捷方式启动该应用程序。
ClickFinish=单击“完成”退出安装程序。
FinishedRestartLabel=要完成 %1 的安装，安装程序必须重新启动您的电脑。您想要现在重新启动吗？
FinishedRestartMessage=要完成 %1 的安装，安装程序必须重新启动您的电脑。%n%n您想要现在重新启动吗？
ShowReadmeCheck=是，我想查看自述文件
YesRadio=是，立即重新启动电脑
NoRadio=否，我稍后重新启动电脑
RunEntryExec=启动 %1
RunEntryShellExec=查看 %1

WizardUninstalling=正在卸载
UninstallingLabel=正在从您的电脑中删除 %1，请稍候。

AboutSetupMenuItem=关于安装程序(&A)...
AboutSetupTitle=关于安装程序
AboutSetupMessage=%1 %2%n%3%n%n%1 主页：%n%4
AboutSetupNote=
TranslatorNote=

ErrorTitle=安装错误
SetupLdrStartupMessage=安装程序将安装 %1。您想要继续吗？
LdrCannotCreateTemp=无法创建临时文件。安装程序已中止
LdrCannotExecTemp=无法执行临时目录中的文件。安装程序已中止
HelpTextNoFilename=找不到帮助文件。
HelpTextNoTopic=找不到帮助主题。
ErrorAbort=安装已中止
ErrorAbortTitle=安装已中止
ErrorCreateDir=安装程序无法创建目录："%1"
ErrorCreateDest=安装程序无法创建目标文件：%n%n%1
ErrorCreateTemp=安装程序无法创建临时文件：%1
ErrorExitSetupTitle=安装程序错误
ErrorExitSetupMessage=安装尚未完成。如果您现在退出，程序将不会被安装。%n%n您可以稍后重新运行安装程序以完成安装。%n%n您要退出安装程序吗？
ErrorFileExists1=文件已存在，无法覆盖：%n%n%1%n%n您要覆盖它吗？
ErrorFileExists2=文件已存在，无法覆盖：%n%n%1%n%n请删除该文件，或选择其他文件夹。
ErrorFileExists3=文件已存在，无法覆盖：%n%n%1%n%n请选择其他文件夹。
ErrorFolderExists=文件夹已存在：%n%n%1%n%n您要继续安装吗？
ErrorFolderExists2=文件夹已存在：%n%n%1%n%n请选择其他文件夹。
ErrorFolderExists3=文件夹已存在：%n%n%1%n%n请选择其他文件夹。
ErrorInvalidName=文件名无效："%1"
ErrorInvalidDir=文件夹名无效："%1"
ErrorInternal2=内部错误：%1
ErrorInternal3=内部错误：%1
ErrorMissingFile=缺少文件：%1
ErrorMissingFile3=缺少文件：%1%n%n请使用正确的安装包重新安装。
ErrorReadingSource=读取源文件时出错：%n%n%1
ErrorReadingSource2=读取源文件时出错：%n%n%1%n%n请重试或选择其他文件夹。
ErrorRunningApp=运行应用程序时出错：%n%n%1
ErrorRunningApp2=运行应用程序时出错：%n%n%1%n%n请重试或选择其他文件夹。
ErrorRegisteringLib=注册文件时出错：%n%n%1
ErrorRegisteringLib2=注册文件时出错：%n%n%1%n%n请重试或选择其他文件夹。
ErrorRegisterTypeLib=注册类型库时出错：%n%n%1
ErrorRegisterTypeLib2=注册类型库时出错：%n%n%1%n%n请重试或选择其他文件夹。
ErrorChangingUX=更改用户体验设置时出错：%n%n%1
ErrorChangingUX2=更改用户体验设置时出错：%n%n%1%n%n请重试或选择其他文件夹。
ErrorOutput=输出错误：%n%n%1
ErrorOutput2=输出错误：%n%n%1%n%n请重试或选择其他文件夹。
ErrorRenaming=重命名文件时出错：%n%n%1%n%n请重试或选择其他文件夹。
ErrorRenaming2=重命名文件时出错：%n%n%1%n%n请重试或选择其他文件夹。
ErrorDeletingUninstall=删除卸载记录时出错：%n%n%1
ErrorRestartReplace=RestartReplace 失败：%n%n%1
ErrorRestartReplace2=RestartReplace 失败：%n%n%1%n%n请重试或选择其他文件夹。
ErrorTooManyFilesInDir=文件夹 "%1" 中文件太多，无法创建文件
ErrorDownloading1=下载文件时出错：%n%1
ErrorDownloading2=下载文件时出错（错误代码 %1）：%n%2
ErrorDownload1=下载文件时出错：%n%1
ErrorDownload2=下载文件时出错（错误代码 %1）：%n%2

StatusClosingApplications=正在关闭应用程序...
StatusCreateDirs=正在创建目录...
StatusExtractFiles=正在解压文件...
StatusCreateIcons=正在创建快捷方式...
StatusCreateIniEntries=正在创建 INI 条目...
StatusCreateRegistryEntries=正在创建注册表条目...
StatusRegisterFiles=正在注册文件...
StatusRestartingApplications=正在重新启动应用程序...
StatusRollback=正在回滚更改...
StatusRunProgram=正在完成安装...
StatusSaveUninstall=正在保存卸载信息...
StatusUninstallingApp=正在卸载 %1...

UninstallOpenError=无法打开文件："%1"%n%n无法卸载。
UninstallUnsupportedVer=卸载日志文件 "%1" 与此版本的卸载程序不兼容。无法继续卸载。
UninstallUnsupportedVerTitle=卸载日志版本不兼容
UninstallUnknownEntry=卸载日志中发现未知条目 (%1)
ConfirmUninstall=您确定要完全删除 %1 及其所有组件吗？
UninstallOnlyOnWin64=此安装程序只能在 64 位 Windows 上卸载。
OnlyAdminCanUninstall=此安装程序只能由具有管理员权限的用户卸载。
UninstallStatusLabel=正在从您的电脑中删除 %1，请稍候...
UninstalledAll=%1 已成功从您的电脑中删除。
UninstalledMost=%1 卸载完成。%n%n部分元素无法删除。您可以手动删除它们。
UninstalledNeedRestart=要完成 %1 的卸载，必须重新启动您的电脑。%n%n您想现在重新启动吗？
UninstallDataCorrupted=文件 "%1" 已损坏，无法卸载。

WizardButtonBack=< 上一步(&B)
WizardButtonNext=下一步(&N) >
WizardButtonInstall=安装(&I)
WizardButtonCancel=取消
WizardButtonFinish=完成(&F)
WizardButtonNo=否(&N)
WizardButtonYes=是(&Y)
WizardButtonBrowse=浏览(&B)...
WizardButtonWizardBrowse=浏览(&R)...

SelectLanguageTitle=选择安装语言
SelectLanguageLabel=请选择安装时要使用的语言：

ExitSetupTitle=退出安装程序
ExitSetupMessage=安装尚未完成。如果您现在退出，程序将不会被安装。%n%n您可以稍后重新运行安装程序以完成安装。%n%n您要退出安装程序吗？

[CustomMessages]

NameAndVersion=%1 %2
AdditionalIcons=附加图标：
CreateDesktopIcon=创建桌面快捷方式(&D)
CreateQuickLaunchIcon=创建快速启动栏快捷方式(&Q)
ProgramOnTheWeb=%1 网站
UninstallProgram=卸载 %1
LaunchProgram=启动 %1
AssocFileExtension=将 %2 文件扩展名与 %1 关联(&A)
AssocingFileExtension=正在将 %2 文件扩展名与 %1 关联...
AutoStartProgramGroupDescription=启动(&S)：
AutoStartProgram=自动启动 %1
AddonHostProgramNotFound=%1 无法在您选择的目录中找到。%n%n您仍要继续吗？
OpenInstallFolder=打开安装目录
