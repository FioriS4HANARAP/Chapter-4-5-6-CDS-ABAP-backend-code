*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
CLASS lcl_prch_buffer DEFINITION FINAL CREATE PRIVATE.
  PUBLIC SECTION.

" Buffer Tables
    DATA: mt_create_buffer TYPE zif_prchdc_logic=>tt_purchasedocument,
          mt_update_buffer TYPE zif_prchdc_logic=>tt_purchasedocument,
          mt_delete_buffer TYPE zif_prchdc_logic=>tt_purchasedocumentKey.

    CLASS-METHODS: get_instance RETURNING VALUE(ro_instance) TYPE REF TO lcl_prch_buffer.


    METHODS buffer_PurchDoc_for_Create     IMPORTING it_purchaseDocument  TYPE zif_prchdc_logic=>tt_purchasedocument
                    EXPORTING et_purchaseDocument  TYPE zif_prchdc_logic=>tt_purchasedocument
                              et_messages          TYPE zif_prchdc_logic=>tt_if_t100_message.
    METHODS save.
    METHODS initialize.
PRIVATE SECTION.
    CLASS-DATA go_instance TYPE REF TO lcl_prch_buffer.


ENDCLASS.

CLASS lcl_prch_buffer IMPLEMENTATION.
  METHOD get_instance.
    go_instance = COND #( WHEN go_instance IS BOUND THEN go_instance ELSE NEW #( ) ).
    ro_instance = go_instance.
  ENDMETHOD.

  METHOD buffer_PurchDoc_for_Create.
    CLEAR et_purchaseDocument.
    CLEAR et_messages.

TYPES: BEGIN OF ts_purchasedocument_id,
             purchasedocument  TYPE ZPURCHASEDOCUMENTDTEL,
           END OF ts_purchasedocument_id,
           tt_purchasedocument_id TYPE SORTED TABLE OF ts_purchasedocument_id WITH UNIQUE KEY purchasedocument.
    DATA lt_purchasedocument_id TYPE tt_purchasedocument_id.

    CHECK it_purchaseDocument IS NOT INITIAL.

    SELECT FROM ZPURCHDOCUMENT FIELDS purchasedocument FOR ALL ENTRIES IN @it_purchaseDocument WHERE purchasedocument = @it_purchaseDocument-purchasedocument
     INTO CORRESPONDING FIELDS OF TABLE @lt_purchasedocument_id.

    LOOP AT it_purchaseDocument INTO DATA(ls_purchdoc_create) ##INTO_OK.
      " Booking_ID key must not be initial
      IF ls_purchdoc_create-purchasedocument IS INITIAL.
        "add excpetion to message class as booking id is initial
        RETURN.
      ENDIF.

      " Booking_ID key check DB
      READ TABLE lt_purchasedocument_id TRANSPORTING NO FIELDS WITH TABLE KEY purchasedocument = ls_purchdoc_create-purchasedocument.
      IF sy-subrc = 0.
        "add excpetion to message class as booking id exists
        RETURN.
      ENDIF.

      " Booking_ID key check Buffer
      READ TABLE mt_create_buffer TRANSPORTING NO FIELDS WITH TABLE KEY purchasedocument = ls_purchdoc_create-purchasedocument.
      IF sy-subrc = 0.
        "add excpetion to message class as booking id is exists in buffer
        RETURN.
      ENDIF.


      INSERT ls_purchdoc_create INTO TABLE mt_create_buffer.
    ENDLOOP.

    et_purchaseDocument = mt_create_buffer.


  ENDMETHOD.


  METHOD save.
    INSERT ZPURCHDOCUMENT FROM TABLE @mt_create_buffer.
*    UPDATE ZPURCHDOCUMENT FROM TABLE @mt_update_buffer.
*    DELETE ZPURCHDOCUMENT FROM TABLE @( CORRESPONDING #( mt_delete_buffer ) ).
  ENDMETHOD.


  METHOD initialize.
    CLEAR: mt_create_buffer, mt_update_buffer, mt_delete_buffer.
  ENDMETHOD.
ENDCLASS.
