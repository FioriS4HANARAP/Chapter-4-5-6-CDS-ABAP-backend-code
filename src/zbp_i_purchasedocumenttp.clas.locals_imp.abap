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
      IMPORTING entities_cba FOR CREATE PurchaseDocument\_PURCHASEDOCUMENTITEM.

    METHODS rba_PURCHASEDOCUMENTITEM FOR READ
      IMPORTING keys_rba FOR READ PurchaseDocument\_PURCHASEDOCUMENTITEM FULL result_requested RESULT result LINK association_links.

    METHODS Approve_Order FOR MODIFY
      IMPORTING keys FOR ACTION PurchaseDocument~Approve_Order RESULT result.

    METHODS Reject_Order FOR MODIFY
      IMPORTING keys FOR ACTION PurchaseDocument~Reject_Order RESULT result.

ENDCLASS.

CLASS lhc_PurchaseDocument IMPLEMENTATION.

  METHOD create.
    DATA: ls_purchdocument TYPE zpurchdocument,
          lt_purchdocument TYPE zif_prchdc_logic=>tt_purchasedocument,
          et_messages      TYPE zif_prchdc_logic=>tt_if_t100_message.
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<fs_PurchaseDocument_Create>).
      MOVE-CORRESPONDING <fs_PurchaseDocument_Create> TO ls_purchdocument.
      ls_purchdocument-crea_uname               = sy-uname.
      ls_purchdocument-lchg_uname               = sy-uname.
      ls_purchdocument-status                   = 1.
    ENDLOOP.
    APPEND ls_purchdocument TO lt_purchdocument.
    zcl_manage_purchasedocuments=>get_instance( )->create_purchasedocument( EXPORTING is_purchasedocument = lt_purchdocument
                                                                IMPORTING et_messages = et_messages ).
    APPEND VALUE #(  purchasedocument = ls_purchdocument-purchasedocument
                         %msg = new_message( id = 'ZPURCHDOC_EXCEPTIONS' number = '000' v1 = ls_purchdocument-purchasedocument    severity = if_abap_behv_message=>severity-success )
                        %element-purchasedocument = cl_abap_behv=>flag_changed ) TO reported-PurchaseDocument.
  ENDMETHOD.

  METHOD delete.
    DATA ls_purchdocument TYPE zpurchdocument.
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<fs_PurchaseDocument_Delete>).
      MOVE-CORRESPONDING <fs_PurchaseDocument_Delete> TO ls_purchdocument.
    ENDLOOP.
    IF sy-subrc EQ 0.
      DELETE FROM zpurchdocitem  WHERE purchasedocument = ls_purchdocument-purchasedocument.
      DELETE zpurchdocument FROM ls_purchdocument.

      APPEND VALUE #(  purchasedocument = ls_purchdocument-purchasedocument
                         %msg = new_message( id = 'ZPURCHDOC_EXCEPTIONS' number = '004' v1 = ls_purchdocument-purchasedocument    severity = if_abap_behv_message=>severity-success )
                        %element-purchasedocument = cl_abap_behv=>flag_changed ) TO reported-PurchaseDocument.

    ENDIF.
  ENDMETHOD.

  METHOD update.
    DATA ls_purchdocument TYPE zpurchdocument.
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<fs_PurchaseDocument_Create>).
      MOVE-CORRESPONDING <fs_PurchaseDocument_Create> TO ls_purchdocument.
      ls_purchdocument-lchg_uname               = sy-uname.
    ENDLOOP.
    IF sy-subrc EQ 0.
      UPDATE zpurchdocument FROM ls_purchdocument.
    ENDIF.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.


  METHOD cba_PURCHASEDOCUMENTITEM.
    DATA ls_purchdocument TYPE zpurchdocument.
    DATA ls_purchdocumentItem TYPE  zpurchdocitem.
    LOOP AT entities_cba ASSIGNING FIELD-SYMBOL(<fs_PurchaseDocument>).
      ls_purchdocument-purchasedocument         = <fs_PurchaseDocument>-PurchaseDocument.
      LOOP AT <fs_PurchaseDocument>-%target ASSIGNING FIELD-SYMBOL(<fs_PurchaseDocumentItem>).
        MOVE-CORRESPONDING <fs_PurchaseDocumentItem> TO ls_purchdocumentItem.
        ls_purchdocumentItem-purchasedocument        = ls_purchdocument-purchasedocument.
        ls_purchdocumentItem-lchg_uname              = sy-uname.
      ENDLOOP.
    ENDLOOP.
    IF sy-subrc EQ 0.
      INSERT zpurchdocitem FROM ls_purchdocumentItem.
    ENDIF.
  ENDMETHOD.

  METHOD rba_PURCHASEDOCUMENTITEM.
  ENDMETHOD.

  METHOD Approve_Order.
    DATA ls_purchdocument TYPE zpurchdocument.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<fs_PurchaseDocument>).
      UPDATE zpurchdocument SET status = 2 WHERE purchasedocument = <fs_PurchaseDocument>-PurchaseDocument.
    ENDLOOP.

    APPEND VALUE #(  purchasedocument = ls_purchdocument-purchasedocument
                         %msg = new_message( id = 'ZPURCHDOC_EXCEPTIONS' number = '002' v1 = <fs_PurchaseDocument>-PurchaseDocument    severity = if_abap_behv_message=>severity-success )
                        %element-purchasedocument = cl_abap_behv=>flag_changed ) TO reported-PurchaseDocument.
  ENDMETHOD.

  METHOD Reject_Order.
    DATA ls_purchdocument TYPE zpurchdocument.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<fs_PurchaseDocument>).
      UPDATE zpurchdocument SET status = 3 WHERE purchasedocument = <fs_PurchaseDocument>-PurchaseDocument.
    ENDLOOP.

    APPEND VALUE #(  purchasedocument = ls_purchdocument-purchasedocument
                         %msg = new_message( id = 'ZPURCHDOC_EXCEPTIONS' number = '003' v1 = <fs_PurchaseDocument>-PurchaseDocument    severity = if_abap_behv_message=>severity-success )
                        %element-purchasedocument = cl_abap_behv=>flag_changed ) TO reported-PurchaseDocument.

* Sample for Failed Scenario
*    APPEND VALUE #(  purchasedocument = ls_purchdocument-purchasedocument ) TO failed-purchasedocument.
*    APPEND VALUE #(  purchasedocument = ls_purchdocument-purchasedocument
*                         %msg = new_message( id = 'ZPURCHDOC_EXCEPTIONS' number = '003' v1 = <fs_PurchaseDocument>-PurchaseDocument    severity = if_abap_behv_message=>severity-error )
*                        %element-purchasedocument = cl_abap_behv=>flag_changed ) TO reported-purchasedocument.
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

ENDCLASS.

CLASS lhc_PurchaseDocumentItem IMPLEMENTATION.

  METHOD create.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD update.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_Z_I_PurchaseDocumentTP DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS check_before_save REDEFINITION.

    METHODS finalize          REDEFINITION.

    METHODS save              REDEFINITION.

    METHODS cleanup           REDEFINITION.

ENDCLASS.

CLASS lsc_Z_I_PurchaseDocumentTP IMPLEMENTATION.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD finalize.
  ENDMETHOD.

  METHOD save.
    zcl_manage_purchasedocuments=>get_instance( )->save( ).
  ENDMETHOD.

  METHOD cleanup.
    zcl_manage_purchasedocuments=>get_instance( )->initialize( ).
  ENDMETHOD.

ENDCLASS.
