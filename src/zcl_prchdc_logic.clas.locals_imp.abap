*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
CLASS lcl_abap_behv_msg IMPLEMENTATION.

  METHOD constructor.
    CALL METHOD super->constructor EXPORTING previous = previous.
    me->msgty = msgty .
    me->msgv1 = msgv1 .
    me->msgv2 = msgv2 .
    me->msgv3 = msgv3 .
    me->msgv4 = msgv4 .
    CLEAR me->textid.
    IF textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.
  ENDMETHOD.

ENDCLASS.

CLASS lcl_prch_buffer DEFINITION FINAL CREATE PRIVATE.
  PUBLIC SECTION.

    " Buffer Tables
    DATA: mt_create_buffer_PurchDoc     TYPE zif_prchdc_logic=>tt_purchasedocument,
          mt_update_buffer_PurchDoc     TYPE zif_prchdc_logic=>tt_purchasedocument,
          mt_delete_buffer_PurchDoc     TYPE zif_prchdc_logic=>tt_purchasedocumentKey,
          mt_create_buffer_PurchDocItem TYPE zif_prchdc_logic=>tt_purchdocumentitem,
          mt_update_buffer_PurchDocItem TYPE zif_prchdc_logic=>tt_purchdocumentitem,
          mt_delete_buffer_PurchDocItem TYPE zif_prchdc_logic=>tt_purchdocitem_key.

    CLASS-METHODS: get_instance RETURNING VALUE(ro_instance) TYPE REF TO lcl_prch_buffer.


    METHODS buffer_PurchDoc_for_Create     IMPORTING it_purchaseDocument TYPE zif_prchdc_logic=>tt_purchasedocument
                                           EXPORTING et_purchaseDocument TYPE zif_prchdc_logic=>tt_purchasedocument
                                                     et_messages         TYPE zif_prchdc_logic=>tt_if_t100_message.

    METHODS buffer_purchdoc_for_delete     IMPORTING it_purchaseDocumentkey TYPE zif_prchdc_logic=>tt_purchasedocumentkey
                                                     it_purchaseDocitemtkey TYPE zif_prchdc_logic=>tt_purchdocitem_key
                                           EXPORTING et_messages            TYPE zif_prchdc_logic=>tt_if_t100_message.

    METHODS buffer_purchdoc_for_update     IMPORTING it_purchaseDocument TYPE zif_prchdc_logic=>tt_purchasedocument
                                           EXPORTING et_messages         TYPE zif_prchdc_logic=>tt_if_t100_message.

    METHODS buffer_PurchDocItem_for_create IMPORTING it_purchaseDocItem TYPE zif_prchdc_logic=>tt_purchdocumentitem
                                           EXPORTING et_messages        TYPE zif_prchdc_logic=>tt_if_t100_message.

    METHODS buffer_purchdocitem_for_update IMPORTING it_purchaseDocItem TYPE zif_prchdc_logic=>tt_purchdocumentitem
                                           EXPORTING et_messages        TYPE zif_prchdc_logic=>tt_if_t100_message.

    METHODS buffer_purchdocitem_for_delete IMPORTING it_purchaseDocItemKey TYPE zif_prchdc_logic=>tt_purchdocitem_key
                                           EXPORTING et_messages           TYPE zif_prchdc_logic=>tt_if_t100_message.


    METHODS save.
    METHODS initialize.

  PRIVATE SECTION.

    CLASS-DATA go_instance TYPE REF TO lcl_prch_buffer.

    TYPES:
      BEGIN OF ts_purchasedocument_id,
        purchasedocument TYPE zpurchasedocumentdtel,
      END OF ts_purchasedocument_id,

      tt_purchasedocument_id TYPE SORTED TABLE OF ts_purchasedocument_id WITH UNIQUE KEY purchasedocument.

    DATA lt_purchasedocument_id TYPE tt_purchasedocument_id.

ENDCLASS.

CLASS lcl_prch_buffer IMPLEMENTATION.

  METHOD get_instance.
    go_instance = COND #( WHEN go_instance IS BOUND THEN go_instance ELSE NEW #( ) ).
    ro_instance = go_instance.
  ENDMETHOD.

  METHOD buffer_PurchDoc_for_Create.
    CLEAR: et_purchaseDocument,
           et_messages,
           lt_purchasedocument_id.

    CHECK it_purchaseDocument IS NOT INITIAL.

    SELECT FROM zpurchdocument
    FIELDS                             purchasedocument
    FOR ALL ENTRIES IN                 @it_purchaseDocument
    WHERE                              purchasedocument = @it_purchaseDocument-purchasedocument
    INTO CORRESPONDING FIELDS OF TABLE @lt_purchasedocument_id.

    LOOP AT it_purchaseDocument INTO DATA(ls_purchdoc_create) ##INTO_OK.
      " Check Purchase Document number is initial or not
      IF ls_purchdoc_create-purchasedocument IS INITIAL.
        "add exception to message class if purchase document ID is initial
        APPEND NEW zcx_purchdoc_excptns( textid = zcx_purchdoc_excptns=>purchasedocintial  mv_purchasedocument = ls_purchdoc_create-purchasedocument )
        TO et_messages.
        initialize( ).
        RETURN.
      ENDIF.

      " Check if the Purchase Document ID already Exists
      IF line_exists( lt_purchasedocument_id[ purchasedocument = ls_purchdoc_create-purchasedocument ] ).
        "add exception to message class if Purchase Do  cument ID exists
        APPEND NEW zcx_purchdoc_excptns( textid = zcx_purchdoc_excptns=>purchasedocexists  mv_purchasedocument = ls_purchdoc_create-purchasedocument )
        TO et_messages.
        initialize( ).
        RETURN.
      ENDIF.

      " Check in buffer table if the Purchase Document ID already exists or not
      IF line_exists( mt_create_buffer_PurchDoc[ purchasedocument = ls_purchdoc_create-purchasedocument ] ).
        "add exception to message class if Purchase Document ID exists in buffer table
        APPEND NEW zcx_purchdoc_excptns( textid = zcx_purchdoc_excptns=>purchasedocexitsinbuffer  mv_purchasedocument = ls_purchdoc_create-purchasedocument )
        TO et_messages.
        initialize( ).
        RETURN.
      ENDIF.

      INSERT ls_purchdoc_create INTO TABLE mt_create_buffer_PurchDoc.
    ENDLOOP.

    et_purchaseDocument = mt_create_buffer_PurchDoc.
  ENDMETHOD.

  METHOD buffer_purchdoc_for_delete.
    CLEAR: et_messages.
    CHECK it_purchaseDocumentkey IS NOT INITIAL.

    MOVE-CORRESPONDING it_purchasedocumentkey TO mt_delete_buffer_PurchDoc.
    MOVE-CORRESPONDING it_purchasedocitemtkey TO mt_delete_buffer_purchdocitem.

  ENDMETHOD.

  METHOD buffer_purchdoc_for_update.
    CLEAR: et_messages.
    CHECK it_purchasedocument IS NOT INITIAL.

    MOVE-CORRESPONDING it_purchasedocument TO mt_update_buffer_purchdoc.
  ENDMETHOD.


  METHOD buffer_PurchDocItem_for_create.
    CLEAR et_messages.
    CHECK it_purchasedocitem IS NOT INITIAL.
    MOVE-CORRESPONDING it_purchasedocitem TO mt_create_buffer_PurchDocItem.
  ENDMETHOD.

  METHOD buffer_purchdocitem_for_update.
    CLEAR: et_messages.
    CHECK it_purchasedocitem IS NOT INITIAL.
    MOVE-CORRESPONDING it_purchasedocitem TO mt_update_buffer_purchdocitem.
  ENDMETHOD.

  METHOD buffer_purchdocitem_for_delete.
    CLEAR: et_messages.
    CHECK it_purchasedocitemkey IS NOT INITIAL.
    MOVE-CORRESPONDING it_purchasedocitemkey TO mt_delete_buffer_purchdocitem.
  ENDMETHOD.


  METHOD save.
    "Here in the save method, the corresponding buffer tables are read
    "and the relevant data is updated,deleted or created in the
    "PurchaseDocument and PurchasedocumentItem tables
    INSERT zpurchdocument FROM TABLE @mt_create_buffer_PurchDoc.
    UPDATE zpurchdocument FROM TABLE @mt_update_buffer_PurchDoc.
    DELETE zpurchdocument FROM TABLE @( CORRESPONDING #( mt_delete_buffer_PurchDoc ) ).
    "Same logic is applied to the PurchaseDocument Table
    INSERT zpurchdocitem  FROM TABLE @mt_create_buffer_PurchDocItem.
    UPDATE zpurchdocitem  FROM TABLE @mt_update_buffer_PurchDocItem.
    DELETE zpurchdocitem  FROM TABLE @( CORRESPONDING #( mt_delete_buffer_PurchDocItem ) ).
  ENDMETHOD.


  METHOD initialize.
    CLEAR: mt_create_buffer_PurchDoc,
           mt_update_buffer_purchdoc,
           mt_delete_buffer_purchdoc,
           mt_delete_buffer_PurchDocItem,
           mt_update_buffer_PurchDocItem.
  ENDMETHOD.
ENDCLASS.
