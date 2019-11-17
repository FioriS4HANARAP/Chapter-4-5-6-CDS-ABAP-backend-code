CLASS lhc_PurchaseDocument DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE PurchaseDocument.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE PurchaseDocument.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE PurchaseDocument.

    METHODS read FOR READ
      IMPORTING keys FOR READ PurchaseDocument RESULT result.

    METHODS cba_PURCHASEDOCUMENTITEM FOR MODIFY
      IMPORTING entities_cba FOR CREATE PurchaseDocument\_purchasedocumentitem.

    METHODS rba_PURCHASEDOCUMENTITEM FOR READ
      IMPORTING keys_rba FOR READ PurchaseDocument\_purchasedocumentitem FULL result_requested RESULT result LINK association_links.

    METHODS Approve_Order FOR MODIFY
      IMPORTING keys FOR ACTION PurchaseDocument~Approve_Order RESULT result.

    METHODS Reject_Order FOR MODIFY
      IMPORTING keys FOR ACTION PurchaseDocument~Reject_Order RESULT result.

    DATA et_messages        TYPE zif_prchdc_logic=>tt_if_t100_message.

ENDCLASS.

CLASS lhc_PurchaseDocument IMPLEMENTATION.

  METHOD create.
    TYPES tt_message TYPE STANDARD TABLE OF symsg.
    CLEAR et_messages.
    DATA: ls_purchdocument      TYPE zpurchdocument,
          lt_purchdocument      TYPE zif_prchdc_logic=>tt_purchasedocument,
          lv_purchasedocument   TYPE ZPURCHASEDOCUMENTDTEL,
          lv_cid                TYPE string.
* Selecting the highest PurchaseDocument number from the DB table to assign the next PurchaseDocument Number
    SELECT FROM zpurchdocument FIELDS MAX( purchasedocument ) INTO @lv_purchasedocument.
* Loop at the importing parameter of the method to retrieve the PurchaseDocument details for creation
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<fs_PurchaseDocument_Create>).
      CLEAR ls_purchdocument.
*The incoming PurchaseDocument structure is not an 1:1 match with the DB table structure for PurchaseDocument
*Hence, we need to map the relevant fields of the incoming structure to the compatible DB Structure.
      ls_purchdocument = CORRESPONDING #( zcl_prchdc_logic=>get_instance( )->map_purchdoc_cds_to_db( CORRESPONDING #( <fs_PurchaseDocument_Create> ) ) ).
      lv_cid = <fs_PurchaseDocument_Create>-%cid.
      if <fs_PurchaseDocument_Create>-PurchaseDocument > lv_purchasedocument .
      lv_purchasedocument = <fs_PurchaseDocument_Create>-PurchaseDocument.
      ENDIF.
      lv_purchasedocument = lv_purchasedocument + 1.
      condense lv_purchasedocument.
      ls_purchdocument-purchasedocument = lv_purchasedocument.
* Setting the Time Stamp Field for Created Date Time and Last Changed Date Time
      GET TIME STAMP FIELD ls_purchdocument-crea_date_time.
      GET TIME STAMP FIELD ls_purchdocument-lchg_date_time.
* Details of the Created and Last changed User name is also added
      ls_purchdocument-crea_uname               = sy-uname.
      ls_purchdocument-lchg_uname               = sy-uname.
      ls_purchdocument-status                   = 1.
* You can make the ImageURL dynamic for your example, For this example.
* We are giving a hard-coded value of one of the existing MIME objects in the BSP application source code of this project
      ls_purchdocument-purchasedocumentimageurl = './images/book.jpg'.
      APPEND ls_purchdocument TO lt_purchdocument.
    ENDLOOP.
* Calling up the relevant method from the ZCL_PRCHDC_LOGIC class to store the PurchaseDocument details in the Buffer Table,
* This Class method will also do some validations on the incoming Purchase Document data and it will will its Exporting Parameter
* et_messages with the relevant error message
    zcl_prchdc_logic=>get_instance( )->create_purchasedocument( EXPORTING it_purchasedocument = lt_purchdocument
                                                                IMPORTING et_messages = et_messages ).

    IF et_messages IS INITIAL.
* If there is no errors returned by the create_purchasedocument method, then we set the success message to the REPORTED
* Parameter with new purchaseDocument number to be displayed as a Toast message in the Application
      INSERT VALUE #(   purchasedocument = ls_purchdocument-purchasedocument
                        %msg = new_message( id = 'ZPURCHDOC_EXCEPTIONS' number = '000' v1 = ls_purchdocument-purchasedocument
                                            severity = if_abap_behv_message=>severity-success )
                        %element-purchasedocument = cl_abap_behv=>flag_changed
                        %cid = lv_cid   )
                        INTO TABLE reported-PurchaseDocument.

    ELSE.

      LOOP AT et_messages INTO DATA(ls_message).
* In case of a Failed Scenario, the FAILED Parameter is filled with the relevant PurchaseDocument number, This will stop any further execution of the Class methods
        INSERT VALUE #( %cid = lv_cid  purchasedocument = ls_purchdocument-purchasedocument )
               INTO TABLE failed-purchasedocument.
* We will also push the relevant error message to REPORTED parameter so that it is displayed in the front-end application as a toast message
        INSERT zcl_prchdc_logic=>map_purchasedoc_message(
                                            iv_purchasedocument = ls_purchdocument-purchasedocument
                                            is_message   = ls_message
                                            is_messagetype = 'E' ) INTO TABLE reported-purchasedocument.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.

  METHOD delete.
    DATA: ls_purchdocument    TYPE zpurchdocument,
          lv_purchasedocumentItem TYPE ZPURCHASEDOCUMENTDTEL,
          ls_purchdocumentkey    TYPE zif_prchdc_logic=>ts_purchdocitem_key,
          lt_purchdocumentKey TYPE zif_prchdc_logic=>tt_purchasedocumentkey,
          lt_purchdocitemKey TYPE zif_prchdc_logic=>tt_purchdocitem_key.
    CLEAR et_messages.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<fs_PurchaseDocument_Delete>).
      MOVE-CORRESPONDING <fs_PurchaseDocument_Delete> TO ls_purchdocument.
* The relevant PurchaseDocument number for deletion is retrieved
      APPEND VALUE #( purchasedocument =  ls_purchdocument-purchasedocument ) TO lt_purchdocumentKey.
    ENDLOOP.
    IF lt_purchdocumentKey is NOT INITIAL.
* If any PurchaseDocument Items exists for this Document, those items will be fetched and passed to the relevant delete method as well.
      SELECT  * FROM zpurchdocitem into CORRESPONDING FIELDS OF TABLE lt_purchdocitemKey
      FOR ALL ENTRIES IN lt_purchdocumentKey
      where purchasedocument =  lt_purchdocumentKey-purchasedocument.
* The delete_purchasedocument method is called by passing the relevant PurchaseDocument and PurchaseDocument Item numbers
      zcl_prchdc_logic=>get_instance( )->delete_purchasedocument( EXPORTING it_purchasedocumentkey = lt_purchdocumentKey
                                                                            it_purchdocitemkey     = lt_purchdocitemKey
                                                                IMPORTING et_messages = et_messages ).
      IF  et_messages IS INITIAL.
* If no errors are returned, then the REPORTED parameter is filled with the relevant success message
        APPEND VALUE #(  purchasedocument = ls_purchdocument-purchasedocument
                           %msg = new_message( id = 'ZPURCHDOC_EXCEPTIONS' number = '004' v1 = ls_purchdocument-purchasedocument    severity = if_abap_behv_message=>severity-success )
                          %element-purchasedocument = cl_abap_behv=>flag_changed ) TO reported-PurchaseDocument.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD update.

    DATA: ls_purchdocument           TYPE zpurchdocument,
          ls_purchdocumentControl    TYPE zif_prchdc_logic=>ts_purchdocumentControl,
          lt_purchasedocument        TYPE zif_prchdc_logic=>tt_purchasedocument,
          lt_purchasedocumentControl TYPE zif_prchdc_logic=>tt_purchdocumentcontrol.

* The incoming structure containing the PurchaseDocument Details to be updated is looped
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<fs_PurchaseDocument_Create>).
* Here the relevant fields of the incoming Structure is mapped to the compatible structure of the PurchaseDocument DB table.
      ls_purchdocument = CORRESPONDING #( zcl_prchdc_logic=>get_instance( )->map_purchdoc_cds_to_db( CORRESPONDING #( <fs_PurchaseDocument_Create> ) ) ).
* As mentioned in chapter 4, the incoming Structure also has some column %CONTROL which contains the
* flag against all the fields of the PurchaseDocuments that were modified by the user and hence we need to store them in a separate structure so that it can be used as
* a reference later to determine which fields from the DB needs to be updated
      ls_purchdocumentControl-action                     = 'U'.
      ls_purchdocumentControl-purchasedocument           = ls_purchdocument-purchasedocument.
      ls_purchdocumentControl-description                = xsdbool( <fs_PurchaseDocument_Create>-%control-Description                = cl_abap_behv=>flag_changed ).
      ls_purchdocumentControl-status                     = xsdbool( <fs_PurchaseDocument_Create>-%control-Status                     = cl_abap_behv=>flag_changed ).
      ls_purchdocumentControl-priority                   = xsdbool( <fs_PurchaseDocument_Create>-%control-Priority                   = cl_abap_behv=>flag_changed ).
      ls_purchdocumentControl-purchasingorganization     = xsdbool( <fs_PurchaseDocument_Create>-%control-PurchasingOrganization     = cl_abap_behv=>flag_changed ).
      ls_purchdocumentControl-purchasedocumentimageurl   = xsdbool( <fs_PurchaseDocument_Create>-%control-PurchaseDocumentImageURL   = cl_abap_behv=>flag_changed ).
      ls_purchdocumentControl-crea_date_time             = xsdbool( <fs_PurchaseDocument_Create>-%control-crea_date_time             = cl_abap_behv=>flag_changed ).
      ls_purchdocumentControl-crea_uname                 = xsdbool( <fs_PurchaseDocument_Create>-%control-crea_uname                 = cl_abap_behv=>flag_changed ).
      ls_purchdocumentControl-lchg_date_time             = 'X'.
      ls_purchdocumentControl-lchg_uname                 = 'X'.

* The last change date time needs to be updated as well
      GET TIME STAMP FIELD ls_purchdocument-lchg_date_time.
* Also the details about the user who made the changes needs to be stored
      ls_purchdocument-lchg_uname       = sy-uname.

      APPEND ls_purchdocument        TO lt_purchasedocument.
      APPEND ls_purchdocumentControl TO lt_purchasedocumentControl.
    ENDLOOP.

    IF lt_purchasedocument IS NOT INITIAL.
* The method update_purchasedocument is called to update the relevant PurchaseDocument Buffer table
* which will be later referred to update the relevant DB table
      zcl_prchdc_logic=>get_instance( )->update_purchasedocument(  EXPORTING it_purchasedocument     =  lt_purchasedocument
                                                                             it_purchdocumentcontrol = lt_purchasedocumentcontrol
                                                                   IMPORTING et_messages = et_messages ).
      IF  et_messages IS INITIAL.
* If no error messages are returned from the update_purchasedocument method, then the relevant success message is pushed to the REPORTED parameter
        APPEND VALUE #(  purchasedocument = ls_purchdocument-purchasedocument
                           %msg = new_message( id = 'ZPURCHDOC_EXCEPTIONS' number = '011' v1 = ls_purchdocument-purchasedocument    severity = if_abap_behv_message=>severity-success )
                          %element-purchasedocument = cl_abap_behv=>flag_changed ) TO reported-PurchaseDocument.
      ENDIF.

    ENDIF.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD cba_PURCHASEDOCUMENTITEM.
    DATA: ls_purchdocument     TYPE zpurchdocument,
          ls_purchdocumentItem TYPE zpurchdocitem,
          lt_purchdocumentItem TYPE zif_prchdc_logic=>tt_purchdocumentitem,
          lv_purchdocitem      TYPE zpurchasedocumentdtel.
* In this Create By Association method for creating the PurchaseDocument Item in relation with the parent PurchaseDocument,
* The highest value of the current PurchaseDocumentItem for the respective PurchaseDocument is retrieved to determine the next number
 SELECT FROM zpurchdocitem FIELDS MAX( purchasedocumentitem ) INTO @lv_purchdocitem.
* The incoming parameter is looped to retrieve the PurchaseDocumentItem details
    LOOP AT entities_cba ASSIGNING FIELD-SYMBOL(<fs_PurchaseDocument>).
        ls_purchdocument-purchasedocument         = <fs_PurchaseDocument>-PurchaseDocument.
* As explained in Chapter 4, the incoming parameter also has a field %TARGET which contains the Parent View Key fields,
* We need these key field values to create the Items in the PurchaseDocumentItem DB table with the correct PurchaseDocument Number
      LOOP AT <fs_PurchaseDocument>-%target ASSIGNING FIELD-SYMBOL(<fs_PurchaseDocumentItem>).
        MOVE-CORRESPONDING <fs_PurchaseDocumentItem> TO ls_purchdocumentItem.

      if <fs_PurchaseDocumentItem>-Purchasedocumentitem > lv_purchdocitem .
        lv_purchdocitem = <fs_PurchaseDocumentItem>-Purchasedocumentitem.
      ENDIF.
        lv_purchdocitem = lv_purchdocitem + 1.
        condense lv_purchdocitem.
        ls_purchdocumentItem-purchasedocumentitem         = lv_purchdocitem.
        ls_purchdocumentItem-purchasedocument             = ls_purchdocument-purchasedocument.
        ls_purchdocumentItem-lchg_uname                   = sy-uname.
        ls_purchdocumentItem-crea_uname                   = sy-uname.
* You can make the ImageURL dynamic for your example, For this example.
* We are giving a hard-coded value of one of the existing MIME objects in the BSP application source code of this project
        ls_purchdocumentItem-purchasedocumentitemimageurl = './images/book.jpg'.
* Setting the Time Stamp Field for Created Date Time and Last Changed Date Time
        GET TIME STAMP FIELD ls_purchdocumentItem-lchg_date_time.
        GET TIME STAMP FIELD ls_purchdocumentItem-crea_date_time.
        APPEND ls_purchdocumentItem to lt_purchdocumentItem.
      ENDLOOP.
    ENDLOOP.
    IF lt_purchdocumentItem IS NOT INITIAL.
* The create_purchasedocitem method of the ZCL_PRCHDC_LOGIC is called to store the relevant PurchaseDocument Items in the buffer table
    zcl_prchdc_logic=>get_instance( )->create_purchasedocitem( EXPORTING it_purchasedocItem = lt_purchdocumentItem
                                                               IMPORTING et_messages = et_messages ).
    ENDIF.
  ENDMETHOD.

  METHOD rba_PURCHASEDOCUMENTITEM.
  ENDMETHOD.

  METHOD Approve_Order.
    DATA ls_purchdocument TYPE zpurchdocument.
    CLEAR result.
* In the custom Action method for Approving a PurchaseDocument,
* The incoming parameter is looped and the relevant PurchaseDocument status is set as approved and details of the Action is store in the RESULT parameter of the method
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<fs_PurchaseDocument>).
      UPDATE zpurchdocument SET status = 2 WHERE purchasedocument = <fs_PurchaseDocument>-PurchaseDocument.
      if sy-subrc eq 0.
      APPEND VALUE #(   purchasedocument        = <fs_PurchaseDocument>-PurchaseDocument
                        %param-purchasedocument = <fs_PurchaseDocument>-PurchaseDocument
                        %param-status           = '2')
               TO result.
      endif.
    ENDLOOP.
* The relevant Success Message is mapped to the REPORTED parameter of the method
    APPEND VALUE #(  purchasedocument = ls_purchdocument-purchasedocument
                         %msg = new_message( id = 'ZPURCHDOC_EXCEPTIONS' number = '002' v1 = <fs_PurchaseDocument>-PurchaseDocument    severity = if_abap_behv_message=>severity-success )
                        %element-purchasedocument = cl_abap_behv=>flag_changed ) TO reported-PurchaseDocument.
  ENDMETHOD.

  METHOD Reject_Order.
    DATA ls_purchdocument TYPE zpurchdocument.
* In the custom Action method for Rejecting a PurchaseDocument,
* The incoming parameter is looped and the relevant PurchaseDocument status is set as rejected and details of the Action is store in the RESULT parameter of the method
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<fs_PurchaseDocument>).
      UPDATE zpurchdocument SET status = 3 WHERE purchasedocument = <fs_PurchaseDocument>-PurchaseDocument.
    ENDLOOP.
* The relevant Success Message is mapped to the REPORTED parameter of the method
    APPEND VALUE #(  purchasedocument = ls_purchdocument-purchasedocument
                         %msg = new_message( id = 'ZPURCHDOC_EXCEPTIONS' number = '003' v1 = <fs_PurchaseDocument>-PurchaseDocument    severity = if_abap_behv_message=>severity-success )
                        %element-purchasedocument = cl_abap_behv=>flag_changed ) TO reported-PurchaseDocument.

  ENDMETHOD.

ENDCLASS.

CLASS lhc_PurchaseDocumentItem DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE PurchaseDocumentItem.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE PurchaseDocumentItem.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE PurchaseDocumentItem.

    METHODS read FOR READ
      IMPORTING keys FOR READ PurchaseDocumentItem RESULT result.
    DATA et_messages        TYPE zif_prchdc_logic=>tt_if_t100_message.

ENDCLASS.

CLASS lhc_PurchaseDocumentItem IMPLEMENTATION.
* This method doesn't need to be implemented, since the Create By Association of the PurchaseDocument will be triggered since
* PurchaseDocumentItem CDS view has a Parent child relation defined to the PurchaseDocument CDS view
  METHOD create.
  ENDMETHOD.

  METHOD delete.
    DATA: ls_purchdocItem    TYPE zpurchdocitem,
          lt_purchdocItemKey TYPE zif_prchdc_logic=>tt_purchdocitem_key.
    CLEAR et_messages.
* The relevant PurchaseDocumentItem number for deletion is retrieved
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<fs_PurchaseDocItem_Delete>).
      MOVE-CORRESPONDING <fs_PurchaseDocItem_Delete> TO ls_purchdocItem.
      APPEND VALUE #( purchasedocument =  ls_purchdocItem-purchasedocument  purchasedocumentItem =  ls_purchdocItem-purchasedocumentitem ) TO lt_purchdocItemKey.
    ENDLOOP.
    IF lt_purchdocItemKey IS NOT INITIAL.
* The delete_purchasedocumentItem method is called by passing the relevant PurchaseDocument Item numbers
      zcl_prchdc_logic=>get_instance( )->delete_PurchaseDocItem( EXPORTING it_purchasedocitemkey = lt_purchdocItemKey
                                                                IMPORTING et_messages = et_messages ).
      IF  et_messages IS INITIAL.
* If no errors are returned by the delete_PurchaseDocItem method, then the relevant Success Message is mapped to the REPORTED parameter of the method
        APPEND VALUE #(  purchasedocumentItem = ls_purchdocItem-purchasedocumentitem
                           %msg = new_message( id = 'ZPURCHDOC_EXCEPTIONS' number = '015' v1 = ls_purchdocItem-purchasedocument    severity = if_abap_behv_message=>severity-success )
                          %element-purchasedocument = cl_abap_behv=>flag_changed ) TO reported-purchasedocumentitem.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD update.
    DATA: ls_purchdocumentItem        TYPE zpurchdocitem,
          ls_purchdocumentItemControl TYPE zif_prchdc_logic=>ts_purchdocumentitemControl,
          lt_purchasedocumentItem     TYPE zif_prchdc_logic=>tt_purchdocumentitem,
          lt_purchasedoctItemControl  TYPE zif_prchdc_logic=>tt_purchdocumentitemcontrol.

* The incoming structure containing the PurchaseDocumentItem Details to be updated is looped
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<fs_PurchaseDocItem_Create>).
* Here the relevant fields of the incoming Structure is mapped to the compatible structure of the PurchaseDocumentItem DB table.
      ls_purchdocumentItem = CORRESPONDING #( zcl_prchdc_logic=>get_instance( )->map_purchdocitem_cds_to_db( CORRESPONDING #( <fs_PurchaseDocItem_Create> ) ) ).
* As mentioned in chapter 4, the incoming Structure also has some column %CONTROL which contains the
* flag against all the fields of the PurchaseDocumentItems that were modified by the user and hence we need to store them in a separate structure so that it can be used as
* a reference later to determine which fields from the DB needs to be updated

      ls_purchdocumentItemControl-action                         = 'U'.
      ls_purchdocumentItemControl-purchasedocument               = ls_purchdocumentItem-purchasedocument.
      ls_purchdocumentItemControl-purchasedocumentitem           = ls_purchdocumentItem-purchasedocumentitem.
      ls_purchdocumentItemControl-crea_date_time                 = xsdbool( <fs_PurchaseDocItem_Create>-%control-crea_date_time                 = cl_abap_behv=>flag_changed ).
      ls_purchdocumentItemControl-crea_uname                     = xsdbool( <fs_PurchaseDocItem_Create>-%control-crea_uname                     = cl_abap_behv=>flag_changed ).
      ls_purchdocumentItemControl-currency                       = xsdbool( <fs_PurchaseDocItem_Create>-%control-Currency                       = cl_abap_behv=>flag_changed ).
      ls_purchdocumentItemControl-description                    = xsdbool( <fs_PurchaseDocItem_Create>-%control-Description                    = cl_abap_behv=>flag_changed ).
      ls_purchdocumentItemControl-lchg_date_time                 = 'X'.
      ls_purchdocumentItemControl-lchg_uname                     = 'X'.
      ls_purchdocumentItemControl-price                          = xsdbool( <fs_PurchaseDocItem_Create>-%control-Price                          = cl_abap_behv=>flag_changed ).
      ls_purchdocumentItemControl-purchasedocumentitemimageurl   = xsdbool( <fs_PurchaseDocItem_Create>-%control-PurchaseDocumentItemImageURL   = cl_abap_behv=>flag_changed ).
      ls_purchdocumentItemControl-quantity                       = xsdbool( <fs_PurchaseDocItem_Create>-%control-Quantity                       = cl_abap_behv=>flag_changed ).
      ls_purchdocumentItemControl-quantityunit                   = xsdbool( <fs_PurchaseDocItem_Create>-%control-QuantityUnit                   = cl_abap_behv=>flag_changed ).
      ls_purchdocumentItemControl-vendor                         = xsdbool( <fs_PurchaseDocItem_Create>-%control-Vendor                         = cl_abap_behv=>flag_changed ).
      ls_purchdocumentItemControl-vendortype                     = xsdbool( <fs_PurchaseDocItem_Create>-%control-VendorType                     = cl_abap_behv=>flag_changed ).
      ls_purchdocumentItemControl-lchg_uname                     = xsdbool( <fs_PurchaseDocItem_Create>-%control-lchg_uname                     = cl_abap_behv=>flag_changed ).

* Time Stamp Field for Last Changed Date Time and last changed user name needs to be updated
      GET TIME STAMP FIELD ls_purchdocumentItem-lchg_date_time.
      ls_purchdocumentItem-lchg_uname      = sy-uname.
      APPEND ls_purchdocumentItem        TO lt_purchasedocumentItem.
      APPEND ls_purchdocumentItemControl TO lt_purchasedoctItemControl.
    ENDLOOP.


    IF lt_purchasedoctItemControl IS NOT INITIAL.
* The method update_purchasedocument is called to update the relevant PurchaseDocument Buffer table
* which will be later referred to update the relevant DB table
      zcl_prchdc_logic=>get_instance( )->update_purchasedocitem(  EXPORTING it_purchasedocitem =  lt_purchasedocumentItem
                                                                            it_purchdocitemcontrol = lt_purchasedoctItemControl
                                                                   IMPORTING et_messages = et_messages ).
      IF  et_messages IS INITIAL.
* If no error messages are returned from the update_purchasedocument method, then the relevant success message is pushed to the REPORTED parameter
        APPEND VALUE #(   purchasedocumentItem = ls_purchdocumentItem-purchasedocumentitem
                           %msg = new_message( id = 'ZPURCHDOC_EXCEPTIONS' number = '001' v1 = ls_purchdocumentItem-purchasedocumentitem    severity = if_abap_behv_message=>severity-success )
                          %element-purchasedocument = cl_abap_behv=>flag_changed ) TO reported-purchasedocumentitem.
      ENDIF.

    ENDIF.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_Z_I_PurchaseDocument_U DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS check_before_save REDEFINITION.

    METHODS finalize          REDEFINITION.

    METHODS save              REDEFINITION.

    METHODS cleanup           REDEFINITION.

ENDCLASS.

CLASS lsc_Z_I_PurchaseDocument_U IMPLEMENTATION.
* These methods are executed in the below listed Sequence, except for the cleanup method,
* which is called within any of the other three methods in case the execution logic is aborted
  METHOD check_before_save.
  ENDMETHOD.

  METHOD finalize.
  ENDMETHOD.

  METHOD save.
* The final method where all the data from the relevant buffer tables are used to either created, updated or deleted
* the records in the relevant DB tables based on the execution logic
    zcl_prchdc_logic=>get_instance( )->save( ).
  ENDMETHOD.

  METHOD cleanup.
* This method is used to cleanup all the buffer tables in case the Execution flow is terminated
    zcl_prchdc_logic=>get_instance( )->initialize( ).
  ENDMETHOD.


ENDCLASS.
