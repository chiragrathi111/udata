Validation :-

1. For AD_InfoWindow_Access (Info Window)
Table/Column to apply: AD_InfoWindow_Access -> AD_InfoWindow_ID

AD_InfoWindow.AD_InfoWindow_ID IN (
    SELECT DISTINCT x.AD_InfoWindow_ID
    FROM AD_InfoWindow x
    LEFT JOIN AD_Role r ON (r.AD_Role_ID = @AD_Role_ID@)
    LEFT JOIN AD_InfoWindow_Access acc ON (acc.AD_Role_ID = r.Parent_AD_Role_ID)
    WHERE (r.Parent_AD_Role_ID IS NULL) 
       OR (x.AD_InfoWindow_ID = acc.AD_InfoWindow_ID)
)

2. For AD_Form_Access (Form)

AD_Form.AD_Form_ID IN (
    SELECT DISTINCT x.AD_Form_ID
    FROM AD_Form x
    LEFT JOIN AD_Role r ON (r.AD_Role_ID = @AD_Role_ID@)
    LEFT JOIN AD_Form_Access acc ON (acc.AD_Role_ID = r.Parent_AD_Role_ID)
    WHERE (r.Parent_AD_Role_ID IS NULL) 
       OR (x.AD_Form_ID = acc.AD_Form_ID)
)

3. For AD_Process_Access (Process / Report)

AD_Process.AD_Process_ID IN (
    SELECT DISTINCT x.AD_Process_ID
    FROM AD_Process x
    LEFT JOIN AD_Role r ON (r.AD_Role_ID = @AD_Role_ID@)
    LEFT JOIN AD_Process_Access acc ON (acc.AD_Role_ID = r.Parent_AD_Role_ID)
    WHERE (r.Parent_AD_Role_ID IS NULL) 
       OR (x.AD_Process_ID = acc.AD_Process_ID)
)

4. For AD_Document_Action_Access (Document Action)
Table/Column to apply: AD_Document_Action_Access -> C_DocType_ID (or whichever column maps to the document/action configuration dropdown in your screen)

C_DocType.C_DocType_ID IN (
    SELECT DISTINCT x.C_DocType_ID
    FROM C_DocType x
    LEFT JOIN AD_Role r ON (r.AD_Role_ID = @AD_Role_ID@)
    LEFT JOIN AD_Document_Action_Access acc ON (acc.AD_Role_ID = r.Parent_AD_Role_ID)
    WHERE (r.Parent_AD_Role_ID IS NULL) 
       OR (x.C_DocType_ID = acc.C_DocType_ID)
)

5.For Ad_Window_Access (Window)

AD_Window.AD_Window_ID IN (
    SELECT DISTINCT w.AD_Window_ID
    FROM AD_Window w
    LEFT JOIN AD_Role r ON (r.AD_Role_ID = @AD_Role_ID@)
    LEFT JOIN AD_Window_Access wa ON (wa.AD_Role_ID = r.Parent_AD_Role_ID)
    WHERE (r.Parent_AD_Role_ID IS NULL ) OR w.AD_Window_ID = wa.AD_Window_ID AND AD_Window.Name != 'Role'
)