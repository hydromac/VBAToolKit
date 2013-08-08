Attribute VB_Name = "vtkImportExportUtilities"
'---------------------------------------------------------------------------------------
' Module    : vtkImportExportUtilities
' Author    : Jean-Pierre Imbert
' Date      : 07/08/2013
' Purpose   : Group utilitiy functions for Modules Import/Export management
'---------------------------------------------------------------------------------------

Option Explicit

Private vbaUnitModules As Collection

'---------------------------------------------------------------------------------------
' Function  : VBComponentTypeAsString
' Author    : Jean-Pierre Imbert
' Date      : 07/08/2013
' Purpose   : Convert a VBComponent type into a readable string
'             - ActiveX for ActiveX component
'             - Class for VBA class module component
'             - Document for VBA code part of worksheets and workbooks (ThisWorkbook)
'             - Form for User Forms
'             - Standard for a standard (not a class) VBA code module
'---------------------------------------------------------------------------------------
'
Private Function VBComponentTypeAsString(ctype As Integer)
    Select Case ctype
        Case vbext_ct_ActiveXDesigner
            VBComponentTypeAsString = "ActiveX"
        Case vbext_ct_ClassModule
            VBComponentTypeAsString = "Class"
        Case vbext_ct_Document
            VBComponentTypeAsString = "Document"
        Case vbext_ct_MSForm
            VBComponentTypeAsString = "Form"
        Case vbext_ct_StdModule
            VBComponentTypeAsString = "Standard"
        Case Else
            VBComponentTypeAsString = "Unknown"
    End Select
End Function

'---------------------------------------------------------------------------------------
' Function  : extensionForVBComponentType
' Author    : Jean-Pierre Imbert
' Date      : 07/08/2013
' Purpose   : Convert a VBComponent type into a file extension for export
'             - ".cls" for VBA class module and VBA Document modules
'             - ".frm" for User Forms
'             - ".bas" for a standard (not a class) VBA code module
'             - ".???" for ActiveX or Unknown type modules
'---------------------------------------------------------------------------------------
'
Private Function extensionForVBComponentType(ctype As Integer)
    Select Case ctype
        Case vbext_ct_ActiveXDesigner
            extensionForVBComponentType = ".???"
        Case vbext_ct_ClassModule
            extensionForVBComponentType = ".cls"
        Case vbext_ct_Document
            extensionForVBComponentType = ".cls"
        Case vbext_ct_MSForm
            extensionForVBComponentType = ".frm"
        Case vbext_ct_StdModule
            extensionForVBComponentType = ".bas"
        Case Else
            extensionForVBComponentType = ".???"
    End Select
End Function

'---------------------------------------------------------------------------------------
' Function  : vtkStandardCategoryForModuleName
' Author    : Jean-Pierre Imbert
' Date      : 08/08/2013
' Purpose   : return the standard category for a module depending on its name
'             - "VBAUnit" if the module belongs to the VBAUnit list
'             - "Test" if the module name ends with "Tester"
'             - "Prod" if none of the above
'             The standard category is a proposed one, it's not mandatory
'---------------------------------------------------------------------------------------
'
Public Function vtkStandardCategoryForModuleName(moduleName As String) As String
   
   On Error Resume Next
    Dim ret As String
    ret = vtkVBAUnitModulesList.Item(moduleName)
    If err.Number = 0 Then
        vtkStandardCategoryForModuleName = "VBAUnit"
       On Error GoTo 0
        Exit Function
        End If
   On Error GoTo 0
   
    If Right(moduleName, 6) Like "Tester" Then
        vtkStandardCategoryForModuleName = "Test"
       Else
        vtkStandardCategoryForModuleName = "Prod"
    End If

End Function

'---------------------------------------------------------------------------------------
' Function  : vtkStandardPathForModule
' Author    : Jean-Pierre Imbert
' Date      : 08/08/2013
' Purpose   : return the standard relative path to export a module given as a VBComponent
'---------------------------------------------------------------------------------------
'
Public Function vtkStandardPathForModule(module As VBComponent) As String

    Dim path As String
    Select Case vtkStandardCategoryForModuleName(moduleName:=module.name)
        Case "VBAUnit"
            path = "Source\VbaUnit\"
        Case "Prod"
            path = "Source\ConfProd\"
        Case "Test"
            path = "Source\ConfTest\"
    End Select
    
    vtkStandardPathForModule = path & module.name & extensionForVBComponentType(ctype:=module.Type)
    
End Function

'---------------------------------------------------------------------------------------
' Function  : vtkVBAUnitModulesList
' Author    : Jean-Pierre Imbert
' Date      : 07/08/2013
' Purpose   : return a collection initialized with the list of the VBAUnit Modules
'---------------------------------------------------------------------------------------
'
Public Function vtkVBAUnitModulesList() As Collection
    If vbaUnitModules Is Nothing Then
        Set vbaUnitModules = New Collection
        With vbaUnitModules
            .Add Item:="VbaUnitMain", Key:="VbaUnitMain"
            .Add Item:="Assert", Key:="Assert"
            .Add Item:="AutoGen", Key:="AutoGen"
            .Add Item:="IAssert", Key:="IAssert"
            .Add Item:="IResultUser", Key:="IResultUser"
            .Add Item:="IRunManager", Key:="IRunManager"
            .Add Item:="ITest", Key:="ITest"
            .Add Item:="ITestCase", Key:="ITestCase"
            .Add Item:="ITestManager", Key:="ITestManager"
            .Add Item:="RunManager", Key:="RunManager"
            .Add Item:="TestCaseManager", Key:="TestCaseManager"
            .Add Item:="TestClassLister", Key:="TestClassLister"
            .Add Item:="TesterTemplate", Key:="TesterTemplate"
            .Add Item:="TestFailure", Key:="TestFailure"
            .Add Item:="TestResult", Key:="TestResult"
            .Add Item:="TestRunner", Key:="TestRunner"
            .Add Item:="TestSuite", Key:="TestSuite"
            .Add Item:="TestSuiteManager", Key:="TestSuiteManager"
        End With
    End If
    Set vtkVBAUnitModulesList = vbaUnitModules
End Function

''---------------------------------------------------------------------------------------
'' Procedure : vtkIsVbaUnit
'' Author    : user
'' Date      : 17/05/2013
'' Purpose   : - take name in parameter and verify if the module is a vbaunit module
''---------------------------------------------------------------------------------------
''
'Public Function vtkIsVbaUnit(modulename As String) As Boolean
'Dim i As Integer
'Dim valinit As Integer
'Dim valfin As Integer
'    valinit = vtkFirstLine
'    valfin = vtkFirstLine + 17
'    vtkIsVbaUnit = False
' For i = vtkFirstLine To valfin
'  If modulename = Range(vtkModuleNameRange & i) And modulename <> "" Then
'     vtkIsVbaUnit = True
'  Exit For
'  End If
' Next
'End Function
'
''---------------------------------------------------------------------------------------
'' Procedure : vtkListAllModules
'' Author    : user
'' Date      : 17/05/2013
'' Purpose   : - call VtkInitializeExcelfileWithVbaUnitModuleName and use his return value
''             - list all module of current project , verify that the module
''              is not a vbaunit and write his name in the range
''
''---------------------------------------------------------------------------------------
''
'Public Function vtkListAllModules() As Integer
'Dim i As Integer
'Dim j As Integer
'Dim k As Integer
'Dim t As Integer
'
't = VtkInitializeExcelfileWithVbaUnitModuleName()
'k = 0
'  For i = 1 To ActiveWorkbook.VBProject.VBComponents.Count
'    If vtkIsVbaUnit(ActiveWorkbook.VBProject.VBComponents.Item(i).name) = False Then
'        ActiveWorkbook.Sheets(vtkConfSheet).Range(vtkModuleNameRange & t + k) = ActiveWorkbook.VBProject.VBComponents.Item(i).name
'        ActiveWorkbook.Sheets(vtkConfSheet).Range(vtkModuleNameRange & t + k).Interior.ColorIndex = 8
'        k = k + 1
'    End If
'  Next
'vtkListAllModules = k
'End Function
'
''---------------------------------------------------------------------------------------
'' Procedure : vtkCreateModuleFile
'' Author    : user
'' Date      : 17/05/2013
'' Purpose   : - this function allow to create a file
''             - return message contain informations: time , file created or replaced
''---------------------------------------------------------------------------------------
''
'Public Function vtkCreateModuleFile(fullPath As String) As String
'
'Dim fso As New FileSystemObject
'
'If fso.FileExists(fullPath) = False Then
'    fso.CreateTextFile (fullPath)
'vtkCreateModuleFile = "File created successfully at" & Now
'Else
'vtkCreateModuleFile = "File last update at" & Now
'End If
'End Function
'
'
'
''---------------------------------------------------------------------------------------
'' Procedure : vtkExportModule
'' Author    : user
'' Date      : 14/05/2013
'' Purpose   : - function take modulename , and line number , and workbookSource Name
''             - create files of modules if they don't exist ,or update it
''             - export module to the right folders  (documents , worksheets)
''             - write creation file informations
''             - write exported file location
''
''  if "vbaunitclass" then
''       if vbaUnitMain then ===================>path= vbaunit ".bas"
''       else                ===================>path= vbaunit ".cls"
''       endif
''  else
''     case module.type
''
''       1.module ,to ===========================>path= confprod ".BAS"
''       2.classmodule, if---nameTester to ======>path= ConfTest ".CLS"
''                      else ====================>path= ConfProd ".CLS"
''       3.Form   ,to ===========================>path= confprod ".FRM"
''     sheet ,worksheet, workbook ===============> do nothing
''  endif
''  vtkCreateModuleFile(path)
''  sheet.range = path
''---------------------------------------------------------------------------------------
''
'Public Function vtkExportModule(modulename As String, lineNumber As Integer, sourceworkbook As String) As String
'
' Dim fullPath As String
' Dim path As String
' Dim MsgCreationFile As String
' Dim Test As String
' Dim DevPath As String
' Dim DelivPath As String
' Dim color As Integer
' color = 2
' Dim fso As New FileSystemObject
' path = fso.GetParentFolderName(ActiveWorkbook.path)
'
'
'    If vtkIsVbaUnit(modulename) = True Then
'          If modulename = "VbaUnitMain" Then
'                fullPath = path & "\Source\VbaUnit\" & modulename & ".bas"  'full path of file that will be created
'                DevPath = fullPath
'                DelivPath = ""
'                color = 3
'          Else
'                fullPath = path & "\Source\VbaUnit\" & modulename & ".cls"  'full path of file that will be created
'                DevPath = fullPath
'                DelivPath = ""
'                color = 3
'          End If
'    Else
'
'        On Error Resume Next
'
'
'    Select Case Workbooks(sourceworkbook).VBProject.VBComponents(modulename).Type
'
'        Case 1 '1module : export to confprod
'
'           fullPath = path & "\Source\ConfProd\" & modulename & ".bas"  'full path of file that will be created
'            DevPath = fullPath
'            DelivPath = fullPath
'
'
'        Case 2 '2 class module : export to ConfTest or ConfProd
'
'            If Right(modulename, 6) Like "Tester" Then ' verify if modulename end is like Tester
'
'                ' This Document is a test module export to confTest
'                fullPath = path & "\Source\ConfTest\" & modulename & ".CLS"
'                DevPath = fullPath
'                DelivPath = ""
'                color = 3
'            Else
'
'                'the document is a classmodule export to confprod
'                fullPath = path & "\Source\ConfProd\" & modulename & ".CLS"
'                DevPath = fullPath
'                DelivPath = fullPath
'            End If
'        Case 3 '3 forms
'
'                'the document is a classmodule export to confprod
'                fullPath = path & "\Source\ConfProd\" & modulename & ".FRM"
'                DevPath = fullPath
'                DelivPath = fullPath
'
'        Case 100 'excel sheets , we will not export them for the moment
'                DevPath = ""
'                DelivPath = ""
'                color = 3
'                ActiveWorkbook.Sheets(vtkConfSheet).Range(vtkModuleDevRange & lineNumber).Interior.ColorIndex = color
'
'        Case Else 'normally we haven't other type but if we find another type we will export it to main project folder
'                DevPath = ""
'                DelivPath = ""
'                color = 3
'                ActiveWorkbook.Sheets(vtkConfSheet).Range(vtkModuleDevRange & lineNumber).Interior.ColorIndex = color
'          Exit Function
'
'      End Select
'    End If
'
'   MsgCreationFile = vtkCreateModuleFile(fullPath)
'   Workbooks(sourceworkbook).VBProject.VBComponents(modulename).Export (fullPath) 'export module to the right folder
'
'   ActiveWorkbook.Sheets(vtkConfSheet).Range(vtkModuleDevRange & lineNumber) = DevPath
'
'   ActiveWorkbook.Sheets(vtkConfSheet).Range(vtkModuleDeliveryRange & lineNumber) = DelivPath
'   ActiveWorkbook.Sheets(vtkConfSheet).Range(vtkModuleDeliveryRange & lineNumber).Interior.ColorIndex = color
'
'   ActiveWorkbook.Sheets(vtkConfSheet).Range(vtkInformationRange & lineNumber) = MsgCreationFile
'
'   On Error GoTo 0
'End Function
'
''---------------------------------------------------------------------------------------
'' Procedure : vtkExportAll
'' Author    : user
'' Date      : 16/05/2013
'' Purpose   : - call function how list all module
''             -
''---------------------------------------------------------------------------------------
''
'Public Function vtkExportAll(sourceworkbookname As String)
'Dim i As Integer
'Dim ttt As String
'Dim a As String
'
'a = vtkListAllModules()
'i = 0
'
'    While ActiveWorkbook.Sheets(vtkConfSheet).Range(vtkModuleNameRange & vtkFirstLine + i) <> ""
'        a = vtkExportModule(Range(vtkModuleNameRange & vtkFirstLine + i), vtkFirstLine + i, sourceworkbookname)
'        i = i + 1
'    Wend
'End Function
'
''---------------------------------------------------------------------------------------
'' Procedure : vtkImportModule
'' Author    : user
'' Date      : 17/05/2013
'' Purpose   : - import module to a workbook
''             - Return number of imported modules
''---------------------------------------------------------------------------------------
''
'Public Function vtkImportTestConfig() As Integer
'Dim i As Integer
'
'
'        i = 0
'    While ActiveWorkbook.Sheets(vtkConfSheet).Range(vtkModuleNameRange & vtkFirstLine + i) <> ""
'
'        On Error Resume Next
'             ' if the module is a class or module
'             If (ActiveWorkbook.VBProject.VBComponents(ActiveWorkbook.Sheets(vtkConfSheet).Range(vtkModuleNameRange & vtkFirstLine + i)).Type = 1 Or ActiveWorkbook.VBProject.VBComponents(ActiveWorkbook.Sheets(vtkConfSheet).Range(vtkModuleNameRange & vtkFirstLine + i)).Type = 2) Then
'                'if the module exist we will delete it and we will replace it
'                ActiveWorkbook.VBProject.VBComponents.Remove ActiveWorkbook.VBProject.VBComponents(ActiveWorkbook.Sheets(vtkConfSheet).Range(vtkModuleNameRange & vtkFirstLine + i))
'                ActiveWorkbook.VBProject.VBComponents.Import ActiveWorkbook.Sheets(vtkConfSheet).Range(vtkModuleDevRange & vtkFirstLine + i)
'                ActiveWorkbook.Sheets(vtkConfSheet).Range(vtkModuleInformationsRange & vtkFirstLine + i) = "module imported at " & Now
'
'             End If
'
'        i = i + 1
'    Wend
'vtkImportTestConfig = i
'On Error GoTo 0
'End Function