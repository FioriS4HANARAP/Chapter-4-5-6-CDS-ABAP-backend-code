class ZCL_MANAGE_PURCHASEDOCUMENTS definition
  public
  final
  create public .

public section.

  interfaces ZIF_PRCHDC_LOGIC .

  types:
    BEGIN OF ENUM ty_change_mode STRUCTURE change_mode," Key checks are done separately
             create,
             update," Only fields that have been changed need to be checked
           END OF ENUM ty_change_mode STRUCTURE change_mode .

  class-methods GET_INSTANCE
    returning
      value(RO_INSTANCE) type ref to ZCL_PRCHDC_LOGIC .
  methods CREATE_PURCHASEDOCUMENT
    importing
      !IS_PURCHASEDOCUMENT type ZIF_PRCHDC_LOGIC=>TT_PURCHASEDOCUMENT
    exporting
      !ES_PURCHASEDOCUMENT type ZIF_PRCHDC_LOGIC=>TT_PURCHASEDOCUMENT
      !ET_MESSAGES type ZIF_PRCHDC_LOGIC=>TT_IF_T100_MESSAGE .
  methods SAVE .
  methods INITIALIZE .
  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-DATA go_instance TYPE REF TO zcl_prchdc_logic.
ENDCLASS.



CLASS ZCL_MANAGE_PURCHASEDOCUMENTS IMPLEMENTATION.


  METHOD CREATE_PURCHASEDOCUMENT.
  CLEAR: es_purchasedocument, et_messages.
    lcl_prch_buffer=>get_instance( )->buffer_purchdoc_for_create( EXPORTING it_purchasedocument   = is_purchasedocument
                                                                  IMPORTING et_messages = et_messages ).
  ENDMETHOD.


  METHOD GET_INSTANCE.
    go_instance = COND #( WHEN go_instance IS BOUND THEN go_instance ELSE NEW #( ) ).
    ro_instance = go_instance.
  ENDMETHOD.


  METHOD INITIALIZE.
    lcl_prch_buffer=>get_instance( )->initialize( ).
  ENDMETHOD.


  METHOD SAVE.
    lcl_prch_buffer=>get_instance( )->save( ).
    initialize( ).
  ENDMETHOD.
ENDCLASS.
