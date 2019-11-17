interface ZIF_PRCHDC_LOGIC
  public .


  types TT_PURCHASEDOCUMENT  TYPE SORTED TABLE OF   zpurchdocument     WITH UNIQUE KEY purchasedocument.
  types TT_PURCHDOCUMENTITEM TYPE SORTED TABLE OF   zpurchdocitem      WITH UNIQUE KEY purchasedocument purchasedocumentitem .


  "! Key structure of Purchase Document
  TYPES BEGIN OF ts_purchdoc_key.
  TYPES action           TYPE String.
  TYPES purchasedocument TYPE ZPURCHASEDOCUMENTDTEL.
  TYPES END OF ts_purchdoc_key.
  "! Table type that contains only the PurchaseDocument Key
  TYPES tt_purchasedocumentKey TYPE SORTED TABLE OF ts_purchdoc_key WITH UNIQUE KEY purchasedocument.

TYPES:    BEGIN OF ts_purchdoc_control,
          description                 TYPE abap_bool,
          status                      TYPE abap_bool,
          priority                    TYPE abap_bool,
          purchasingorganization      TYPE abap_bool,
          purchasedocumentimageurl    TYPE abap_bool,
          crea_date_time              TYPE abap_bool,
          crea_uname                  TYPE abap_bool,
          lchg_date_time              TYPE abap_bool,
          lchg_uname                  TYPE abap_bool,
    END OF ts_purchdoc_control.

TYPES:    BEGIN OF ts_purchdocItem_control,
           description                  TYPE abap_bool,
           price                        TYPE abap_bool,
           currency                     TYPE abap_bool,
           quantity                     TYPE abap_bool,
           quantityunit                 TYPE abap_bool,
           vendor                       TYPE abap_bool,
           vendortype                   TYPE abap_bool,
           purchasedocumentitemimageurl TYPE abap_bool,
           crea_date_time               TYPE abap_bool,
           crea_uname                   TYPE abap_bool,
           lchg_date_time               TYPE abap_bool,
           lchg_uname                   TYPE abap_bool,
    END OF ts_purchdocItem_control.

  "! Key structure of Purchase Document Item
  TYPES BEGIN OF ts_purchdocitem_key.
  TYPES action           TYPE String.
  TYPES purchasedocument TYPE ZPURCHASEDOCUMENTDTEL.
  TYPES purchasedocumentItem  TYPE zpurchasedocumentdtel.
  TYPES END OF ts_purchdocitem_key.

  TYPES BEGIN OF ts_purchdocumentControl.
  INCLUDE TYPE ts_purchdoc_key.
  INCLUDE TYPE ts_purchdoc_control.
  TYPES END OF ts_purchdocumentControl.

  TYPES BEGIN OF ts_purchdocumentitemControl.
  INCLUDE TYPE ts_purchdocitem_key.
  INCLUDE TYPE ts_purchdocitem_control.
  TYPES END OF ts_purchdocumentitemControl.



  TYPES BEGIN OF ts_purchasedocument.
  INCLUDE TYPE zpurchdocument.
  TYPES END OF ts_purchasedocument.

  TYPES BEGIN OF ts_purchasedocItem.
  INCLUDE TYPE zpurchdocitem.
  TYPES END OF ts_purchasedocItem.


  TYPES tt_purchdocumentitemControl TYPE TABLE OF ts_purchdocumentitemControl.
  TYPES tt_purchdocumentControl     TYPE TABLE OF   ts_purchdocumentControl.
  "! Table type that contains only the PurchaseDocument Item Key
  TYPES tt_purchdocitem_key TYPE SORTED TABLE OF ts_purchdocitem_key WITH UNIQUE KEY purchasedocument purchasedocumentItem.

*   Type definition for import parameters --------------------------

    TYPES tt_purchasedocumet_failed                  TYPE TABLE FOR FAILED   Z_I_PurchaseDocument_U.
    TYPES tt_purchasedocumet_mapped                  TYPE TABLE FOR MAPPED   Z_I_PurchaseDocument_U.
    TYPES tt_purchasedocumet_reported                TYPE TABLE FOR REPORTED Z_I_PurchaseDocument_U.

    TYPES tt_purchasedocItem_failed                  TYPE TABLE FOR FAILED   Z_I_PurchaseDocumentItem_U.
    TYPES tt_purchasedocItem_mapped                  TYPE TABLE FOR MAPPED   Z_I_PurchaseDocumentItem_U.
    TYPES tt_purchasedocItem_reported                TYPE TABLE FOR REPORTED Z_I_PurchaseDocumentItem_U.

  constants CO_VERSION_MAJOR type INT2 value 2 ##NO_TEXT.
  constants CO_VERSION_MINOR type INT2 value 0 ##NO_TEXT.

*****************
* Message table *
*****************

  "! Table of messages
  TYPES tt_message TYPE STANDARD TABLE OF symsg.

  "! Table of messages like T100. <br/>
  "! We have only error messages.
  "! Currently we do not communicate Warnings or Success Messages.
  "! Internally we use a table of exceptions.
  TYPES tt_if_t100_message TYPE STANDARD TABLE OF REF TO if_t100_message WITH EMPTY KEY.
endinterface.
