CLASS zcl_prchdc_logic DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES zif_prchdc_logic.


    TYPES: BEGIN OF ENUM ty_change_mode STRUCTURE change_mode," Key checks are done separately
             create,
             update," Only fields that have been changed need to be checked
           END OF ENUM ty_change_mode STRUCTURE change_mode.

    TYPES tt_message TYPE STANDARD TABLE OF symsg.
    DATA: mt_update_buffer_PurchDoc     TYPE zif_prchdc_logic=>tt_purchasedocument,
          mt_update_buffer_PurchDocitem TYPE zif_prchdc_logic=>tt_purchdocumentitem.

    CLASS-METHODS: get_instance RETURNING VALUE(ro_instance) TYPE REF TO zcl_prchdc_logic.

    METHODS create_PurchaseDocument     IMPORTING it_purchasedocument TYPE zif_prchdc_logic=>tt_purchasedocument
                                        EXPORTING et_messages         TYPE zif_prchdc_logic=>tt_if_t100_message.

    METHODS delete_PurchaseDocument     IMPORTING it_purchasedocumentkey TYPE zif_prchdc_logic=>tt_purchasedocumentkey
                                                  it_purchdocitemKey     TYPE zif_prchdc_logic=>tt_purchdocitem_key
                                        EXPORTING et_messages            TYPE zif_prchdc_logic=>tt_if_t100_message.

    METHODS update_PurchaseDocument     IMPORTING it_purchasedocument     TYPE zif_prchdc_logic=>tt_purchasedocument
                                                  it_purchdocumentcontrol TYPE zif_prchdc_logic=>tt_purchdocumentcontrol
                                        EXPORTING et_messages             TYPE zif_prchdc_logic=>tt_if_t100_message.

    METHODS create_PurchaseDocItem      IMPORTING it_purchasedocItem     TYPE zif_prchdc_logic=>tt_purchdocumentitem
                                        EXPORTING et_messages            TYPE zif_prchdc_logic=>tt_if_t100_message.

    METHODS delete_PurchaseDocItem      IMPORTING it_purchasedocItemkey TYPE zif_prchdc_logic=>tt_purchdocitem_key
                                        EXPORTING et_messages           TYPE zif_prchdc_logic=>tt_if_t100_message.

    METHODS update_PurchaseDocItem      IMPORTING it_purchasedocItem     TYPE zif_prchdc_logic=>tt_purchdocumentitem
                                                  it_purchdocitemcontrol TYPE zif_prchdc_logic=>tt_purchdocumentitemcontrol
                                        EXPORTING et_messages            TYPE zif_prchdc_logic=>tt_if_t100_message.



    CLASS-METHODS map_purchdoc_cds_to_db
      IMPORTING is_i_purchdoc_u    TYPE Z_I_PurchaseDocument_U
      RETURNING VALUE(rs_purchdoc) TYPE zif_prchdc_logic=>ts_purchasedocument.

    CLASS-METHODS map_purchdocitem_cds_to_db
      IMPORTING is_i_purchdocitem_u    TYPE z_i_purchasedocumentitem_u
      RETURNING VALUE(rs_purchdocitem) TYPE zif_prchdc_logic=>ts_purchasedocitem.

    CLASS-METHODS map_purchaseDoc_message
      IMPORTING iv_cid              TYPE string OPTIONAL
                iv_purchasedocument TYPE zpurchasedocumentdtel OPTIONAL
                is_message          TYPE LINE OF zif_prchdc_logic=>tt_if_t100_message
                is_messageType      TYPE symsgty
      RETURNING VALUE(rs_report)    TYPE LINE OF zif_prchdc_logic=>tt_purchasedocumet_reported.
    METHODS save.
    METHODS initialize.

  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-DATA go_instance TYPE REF TO zcl_prchdc_logic.

    CLASS-METHODS new_message
      IMPORTING id         TYPE symsgid
                number     TYPE symsgno
                severity   TYPE if_abap_behv_message=>t_severity
                v1         TYPE simple OPTIONAL
                v2         TYPE simple OPTIONAL
                v3         TYPE simple OPTIONAL
                v4         TYPE simple OPTIONAL
      RETURNING VALUE(obj) TYPE REF TO if_abap_behv_message .
ENDCLASS.



CLASS zcl_prchdc_logic IMPLEMENTATION.

  METHOD get_instance.
    go_instance = COND #( WHEN go_instance IS BOUND THEN go_instance ELSE NEW #( ) ).
    ro_instance = go_instance.
  ENDMETHOD.

  METHOD create_PurchaseDocument.
    CLEAR:  et_messages.
    lcl_prch_buffer=>get_instance( )->buffer_purchdoc_for_create( EXPORTING it_purchasedocument   = it_purchasedocument
                                                                  IMPORTING et_messages = et_messages ).
  ENDMETHOD.

  METHOD delete_PurchaseDocument.
    lcl_prch_buffer=>get_instance( )->buffer_purchdoc_for_delete( EXPORTING it_purchasedocumentkey   = it_purchasedocumentkey
                                                                            it_purchasedocitemtkey   = it_purchdocitemkey
                                                                  IMPORTING et_messages = et_messages ).
  ENDMETHOD.

  METHOD update_PurchaseDocument.
    DATA: lt_purchasedocument_db     TYPE  zif_prchdc_logic=>tt_purchasedocument,
          lt_purchasedocument_update TYPE zif_prchdc_logic=>tt_purchasedocument.
    FIELD-SYMBOLS <fs_purchdocument_buffer> TYPE zpurchdocument.

    SELECT * FROM zpurchdocument
    INTO TABLE          @lt_purchasedocument_db
    FOR ALL ENTRIES IN  @it_purchasedocument
    WHERE               purchasedocument = @it_purchasedocument-purchasedocument.

    LOOP AT it_purchasedocument ASSIGNING FIELD-SYMBOL(<fs_purchasedocument_current>).
      READ  TABLE lt_purchasedocument_db INTO DATA(ls_purchasedocument_db)
      WITH KEY purchasedocument = <fs_purchasedocument_current>-purchasedocument.
      IF sy-subrc = 0.
        INSERT ls_purchasedocument_db INTO TABLE mt_update_buffer_PurchDoc ASSIGNING <fs_purchdocument_buffer>.
      ENDIF.

      READ TABLE it_purchdocumentcontrol ASSIGNING FIELD-SYMBOL(<fs_purchasedocumentControl>) WITH KEY purchasedocument = <fs_purchasedocument_current>-purchasedocument.

      DATA lv_field TYPE i.
      lv_field = 2.
      DO.
        ASSIGN COMPONENT lv_field OF STRUCTURE <fs_purchasedocumentControl> TO FIELD-SYMBOL(<v_flag>).
        IF sy-subrc <> 0.
          EXIT.
        ENDIF.
        IF <v_flag> = abap_true.
          ASSIGN COMPONENT lv_field OF STRUCTURE <fs_purchasedocument_current> TO FIELD-SYMBOL(<v_field_current>).
          ASSERT sy-subrc = 0.
          ASSIGN COMPONENT lv_field OF STRUCTURE <fs_purchdocument_buffer> TO FIELD-SYMBOL(<v_field_db>).
          ASSERT sy-subrc = 0.
          <v_field_db> = <v_field_current>.
        ENDIF.
        lv_field = lv_field + 1.
      ENDDO.

    ENDLOOP.

    lcl_prch_buffer=>get_instance( )->buffer_purchdoc_for_update( EXPORTING it_purchasedocument   = mt_update_buffer_PurchDoc
                                                                  IMPORTING et_messages = et_messages ).
  ENDMETHOD.

  METHOD delete_PurchaseDocItem.
    lcl_prch_buffer=>get_instance( )->buffer_purchdocitem_for_delete( EXPORTING it_purchasedocitemkey  = it_purchasedocitemkey
                                                                      IMPORTING et_messages = et_messages ).
  ENDMETHOD.

  METHOD create_PurchaseDocItem.
    lcl_prch_buffer=>get_instance( )->buffer_purchdocitem_for_create( EXPORTING it_purchasedocitem  = it_purchasedocitem
                                                                      IMPORTING et_messages = et_messages ).
  ENDMETHOD.

  METHOD map_purchdoc_cds_to_db.
    rs_purchdoc = CORRESPONDING #( is_i_purchdoc_u MAPPING  purchasedocument         = PurchaseDocument
                                                            crea_date_time           = crea_date_time
                                                            crea_uname               = crea_uname
                                                            description              = Description
                                                            lchg_date_time           = lchg_date_time
                                                            lchg_uname               = lchg_uname
                                                            priority                 = Priority
                                                            purchasedocumentimageurl = PurchaseDocumentImageURL
                                                            purchasingorganization   = PurchasingOrganization
                                                            status                   = status ).
  ENDMETHOD.


  METHOD map_purchdocitem_cds_to_db.
    rs_purchdocitem = CORRESPONDING #( is_i_purchdocitem_u MAPPING  purchasedocument             = PurchaseDocument
                                                                    crea_date_time               = crea_date_time
                                                                    crea_uname                   = crea_uname
                                                                    description                  = Description
                                                                    lchg_date_time               = lchg_date_time
                                                                    lchg_uname                   = lchg_uname
                                                                    purchasedocumentitem         = PurchaseDocumentItem
                                                                    quantity                     = Quantity
                                                                    quantityunit                 = QuantityUnit
                                                                    vendor                       = Vendor
                                                                    vendortype                   = VendorType
                                                                    price                        = Price
                                                                    purchasedocumentitemimageurl = PurchaseDocumentItemImageURL
                                                                    currency                     = Currency ).
  ENDMETHOD.

  METHOD map_purchaseDoc_message.
    DATA: ls_message TYPE LINE OF tt_message.
    MOVE-CORRESPONDING is_message->t100key TO ls_message.
    ls_message-msgty = is_messageType.
    ls_message-msgv1 = iv_purchasedocument.
    DATA(lo) = new_message( id       = ls_message-msgid
                            number   = ls_message-msgno
                            severity = if_abap_behv_message=>severity-error
                            v1       = ls_message-msgv1
                            v2       = ls_message-msgv2
                            v3       = ls_message-msgv3
                            v4       = ls_message-msgv4 ).
    rs_report-%cid     = iv_cid.
    rs_report-PurchaseDocument = iv_purchasedocument.
    rs_report-%msg     = lo.
  ENDMETHOD.

  METHOD new_message.
    obj = NEW lcl_abap_behv_msg(
      textid = VALUE #(
                 msgid = id
                 msgno = number
                 attr1 = COND #( WHEN v1 IS NOT INITIAL THEN 'IF_T100_DYN_MSG~MSGV1' )
                 attr2 = COND #( WHEN v2 IS NOT INITIAL THEN 'IF_T100_DYN_MSG~MSGV2' )
                 attr3 = COND #( WHEN v3 IS NOT INITIAL THEN 'IF_T100_DYN_MSG~MSGV3' )
                 attr4 = COND #( WHEN v4 IS NOT INITIAL THEN 'IF_T100_DYN_MSG~MSGV4' )
      )
      msgty = SWITCH #( severity
                WHEN if_abap_behv_message=>severity-error       THEN 'E'
                WHEN if_abap_behv_message=>severity-warning     THEN 'W'
                WHEN if_abap_behv_message=>severity-information THEN 'I'
                WHEN if_abap_behv_message=>severity-success     THEN 'S' )
      msgv1 = |{ v1 }|
      msgv2 = |{ v2 }|
      msgv3 = |{ v3 }|
      msgv4 = |{ v4 }|
    ).
    obj->m_severity = severity.
  ENDMETHOD.

  METHOD update_PurchaseDocItem.
    DATA: lt_purchdocItem_db     TYPE  zif_prchdc_logic=>tt_purchdocumentitem,
          lt_purchdocitem_update TYPE zif_prchdc_logic=>tt_purchdocumentitem.
    FIELD-SYMBOLS <fs_purchdocitem_buffer> TYPE zpurchdocitem.
    SELECT * FROM zpurchdocitem INTO TABLE @lt_purchdocitem_db  FOR ALL ENTRIES IN @it_purchasedocitem
    WHERE purchasedocument = @it_purchasedocitem-purchasedocument
    AND purchasedocumentitem = @it_purchasedocitem-purchasedocumentitem.

    LOOP AT it_purchasedocitem ASSIGNING FIELD-SYMBOL(<fs_purchdocitem_current>).
      READ  TABLE lt_purchdocitem_db INTO DATA(ls_purchdocitem_db)
      WITH KEY purchasedocument = <fs_purchdocitem_current>-purchasedocument
      purchasedocumentitem = <fs_purchdocitem_current>-purchasedocumentitem.
      IF sy-subrc = 0.
        INSERT ls_purchdocitem_db INTO TABLE mt_update_buffer_purchdocitem ASSIGNING <fs_purchdocitem_buffer>.
      ENDIF.

      READ TABLE it_purchdocitemcontrol ASSIGNING FIELD-SYMBOL(<fs_purchasedocItemControl>)
      WITH KEY purchasedocument = <fs_purchdocitem_current>-purchasedocument
      purchasedocumentitem =  <fs_purchdocitem_current>-purchasedocumentitem.

      DATA lv_field TYPE i.
      lv_field = 2.
      DO.
        ASSIGN COMPONENT lv_field OF STRUCTURE <fs_purchasedocItemControl> TO FIELD-SYMBOL(<v_flag>).
        IF sy-subrc <> 0.
          EXIT.
        ENDIF.
        IF <v_flag> = abap_true.
          ASSIGN COMPONENT lv_field OF STRUCTURE <fs_purchdocitem_current> TO FIELD-SYMBOL(<v_field_current>).
          ASSERT sy-subrc = 0.
          ASSIGN COMPONENT lv_field OF STRUCTURE <fs_purchdocitem_buffer> TO FIELD-SYMBOL(<v_field_db>).
          ASSERT sy-subrc = 0.
          <v_field_db> = <v_field_current>.
        ENDIF.
        lv_field = lv_field + 1.
      ENDDO.

    ENDLOOP.
    lcl_prch_buffer=>get_instance( )->buffer_purchdocitem_for_update( EXPORTING it_purchasedocitem   = mt_update_buffer_purchdocitem
                                                                      IMPORTING et_messages = et_messages ).
  ENDMETHOD.

  METHOD save.
    lcl_prch_buffer=>get_instance( )->save( ).
    initialize( ).
  ENDMETHOD.

  METHOD initialize.
    lcl_prch_buffer=>get_instance( )->initialize( ).
  ENDMETHOD.

ENDCLASS.
