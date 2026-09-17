; *** Inno Setup 6 Chinese Simplified language file ***
; Bundled with this project so CI runners without the official
; language pack can still compile the installer.

[LanguageSetup]
LanguageName=简体中文
LanguageID=$0804
LanguageCodePage=936
RightToLeft=no

[CustomMessages]

NameAndVersion=%1 %2
AdditionalIcons=附加图标:
CreateDesktopIcon=创建桌面快捷方式(&D)
CreateQuickLaunchIcon=创建快速启动栏快捷方式(&Q)
ProgramOnTheWeb=%1 网站
UninstallProgram=卸载 %1
LaunchProgram=启动 %1
AssocFileExtension=将 %2 文件扩展名与 %1 关联(&A)
AssocingFileExtension=正在将 %2 文件扩展名与 %1 关联...
AutoStartProgramGroupDescription=启动(&S):
AutoStartProgram=自动启动 %1
AddonHostProgramNotFound=%1 无法在您选择的目录中找到。%n%n您仍要继续吗？

WizardSelectDir=选择安装位置
WizardSelectComponents=选择组件
WizardSelectTasks=选择附加任务
WizardReady=准备安装
WizardPreparing=正在准备安装
WizardInstalling=正在安装
WizardFinished=安装完成
WizardUninstalling=正在卸载

SelectDirLabel=请选择 %1 的安装路径。
SelectDirLabel3=安装程序将把 %1 安装在下列文件夹中。若要安装到其他文件夹，请单击 [浏览(B)]。
SelectDirBrowseLabel=单击 [下一步(N)] 继续。若要选择其他文件夹，请单击 [浏览(B)]。
DiskSpaceMBLabel=至少需要有 [mb] MB 的可用磁盘空间。

SelectComponentsLabel=请选择要安装的组件。
SelectComponentsLabel2=选择您想要安装的组件，清除您不想安装的组件。单击 [下一步(N)] 继续。
FullInstallation=完全安装
CompactInstallation=简洁安装
CustomInstallation=自定义安装

WizardSelectTasksLabel=请选择要执行的附加任务。
WizardSelectTasksLabel2=请选择要执行的附加任务，然后单击 [下一步(N)]。

ReadyLabel1=安装程序现在准备好开始安装 %1。
ReadyLabel2a=单击 [安装(I)] 继续，或单击 [上一步(B)] 返回并修改设置。
ReadyLabel2b=单击 [安装(I)] 继续。
ReadyMemoUserInfo=用户信息：
ReadyMemoDir=目标位置：
ReadyMemoType=安装类型：
ReadyMemoComponents=所选组件：
ReadyMemoGroup=开始菜单文件夹：
ReadyMemoTasks=附加任务：

PreparingLabel=安装程序正在准备安装 %1 到您的电脑中，请稍候...
InstallingLabel=安装程序正在将 %1 安装到您的电脑中，请稍候...

FinishedHeadingLabel=完成 %1 安装向导
FinishedLabelNoIcons=安装程序已在您的电脑中安装了 %1。
FinishedLabel=安装程序已在您的电脑中安装了 %1。可通过已创建的快捷方式启动该应用程序。
ClickFinish=单击 [完成(F)] 退出安装程序。
FinishedRestartLabel=要完成 %1 的安装，安装程序必须重新启动您的电脑。您想要现在重新启动吗？
FinishedRestartMessage=要完成 %1 的安装，安装程序必须重新启动您的电脑。%n%n您想要现在重新启动吗？
ShowReadmeCheck=是，我想查看自述文件
YesRadio=是，立即重新启动电脑(&Y)
NoRadio=否，我稍后重新启动电脑(&N)
RunEntryExec=启动 %1
RunEntryShellExec=查看 %1

ErrorTitle=安装错误
SetupLdrStartupMessage=安装程序将安装 %1。您想要继续吗？
LdrCannotCreateTemp=无法创建临时文件。安装程序已中止
LdrCannotExecTemp=无法执行临时目录中的文件。安装程序已中止

ErrorCreateDir=安装程序无法创建目录："%1"
ErrorCreateDest=安装程序无法创建目标文件：%n%n%1
ErrorCreateTemp=安装程序无法创建临时文件：%1
ErrorExitSetupTitle=安装程序错误
ErrorExitSetupMessage=安装尚未完成。如果您现在退出，程序将不会被安装。%n%n您可以稍后重新运行安装程序以完成安装。%n%n您要退出安装程序吗？
ErrorFileExists1=文件已存在，无法覆盖：%n%n%1%n%n您要覆盖它吗？
ErrorFileExists2=文件已存在，无法覆盖：%n%n%1%n%n请删除该文件，或选择其他目录。
ErrorFileExistsTitle=文件已存在
ErrorFolderExists=文件夹已存在：%n%n%1%n%n您要继续安装吗？
ErrorFolderExistsTitle=文件夹已存在
ErrorInvalidName=文件名无效："%1"
ErrorInvalidNameTitle=文件名无效
ErrorInvalidDir=文件夹名无效："%1"
ErrorInvalidDirTitle=文件夹名无效
ErrorInternal2=内部错误：%1
ErrorInternalTitle=内部错误
ErrorMissingFile=缺少文件：%1
ErrorMissingFileTitle=缺少文件
ErrorReadingSource=读取源文件时出错：%n%n%1
ErrorReadingSourceTitle=读取源文件错误
ErrorRunningApp=运行应用程序时出错：%n%n%1
ErrorRunningAppTitle=运行应用程序错误
ErrorTooManyFilesInDir=文件夹 "%1" 中文件太多，无法创建文件
ErrorTooManyFilesInDirTitle=文件夹中文件太多

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
StatusUninstallingApp=正在卸载 %1...

UninstallOpenError=无法打开文件："%1"%n%n无法卸载
UninstallUnsupportedVer=卸载日志文件 "%1" 与此版本的卸载程序不兼容。无法继续卸载
UninstallUnsupportedVerTitle=卸载日志版本不兼容
ConfirmUninstall=您确定要完全删除 %1 及其所有组件吗？
UninstallOnlyOnWin64=此安装程序只能在 64 位 Windows 上卸载
OnlyAdminCanUninstall=此安装程序只能由具有管理员权限的用户卸载
UninstallStatusLabel=正在从您的电脑中删除 %1，请稍候...
UninstalledAll=%1 已成功从您的电脑中删除。
UninstalledMost=%1 卸载完成。%n%n部分元素无法删除。您可以手动删除它们。
UninstalledNeedRestart=要完成 %1 的卸载，必须重新启动您的电脑。%n%n您想现在重新启动吗？
UninstallDataCorrupted=文件 "%1" 已损坏，无法卸载

AboutSetupMenuItem=关于安装程序(&A)...
AboutSetupTitle=关于安装程序
AboutSetupMessage=%1 %2%n%3%n%n%1 主页：%n%4
AboutSetupNote=

WizardButtonBack=< 上一步(&B)
WizardButtonNext=下一步(&N) >
WizardButtonInstall=安装(&I)
WizardButtonCancel=取消
WizardButtonFinish=完成(&F)
WizardButtonNo=否(&N)
WizardButtonYes=是(&Y)
WizardButtonBrowse=浏览(&B)...
BrowseDialogLabel=在下列列表中选择一个文件夹，然后单击 [确定]。
BrowseDialogTitle=浏览文件夹
NewFolderName=新建文件夹

SelectLanguageTitle=选择安装语言
SelectLanguageLabel=请选择安装时要使用的语言：

ClickNext=单击 [下一步(N)] 继续，或单击 [取消(C)] 退出安装程序。
BeveledLabel=
ExitSetupTitle=退出安装程序
ExitSetupMessage=安装尚未完成。如果您现在退出，程序将不会被安装。%n%n您可以稍后重新运行安装程序以完成安装。%n%n您要退出安装程序吗？
