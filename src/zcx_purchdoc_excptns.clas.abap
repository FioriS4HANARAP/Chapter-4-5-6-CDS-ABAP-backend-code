class ZCX_PURCHDOC_EXCPTNS definition
  public
  inheriting from CX_STATIC_CHECK
  final
  create public .

public section.

  interfaces IF_T100_DYN_MSG .
  interfaces IF_T100_MESSAGE .

  constants:
    begin of PURCHASEDOCUMENTITEM,
      msgid type symsgid value 'ZPURCHDOC_EXCEPTIONS',
      msgno type symsgno value '001',
      attr1 type scx_attrname value 'MV_PURCHASEDOCUMENTITEM',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of PURCHASEDOCUMENTITEM .
  constants:
    begin of PURCHASEDOCUMENT,
      msgid type symsgid value 'ZPURCHDOC_EXCEPTIONS',
      msgno type symsgno value '000',
      attr1 type scx_attrname value 'MV_PURCHASEDOCUMENT',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of PURCHASEDOCUMENT .
  constants:
    begin of APPROVED,
      msgid type symsgid value 'ZPURCHDOC_EXCEPTIONS',
      msgno type symsgno value '002',
      attr1 type scx_attrname value 'MV_PURCHASEDOCUMENT',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of APPROVED .
  constants:
    begin of PURCHASEDOCEXISTS,
      msgid type symsgid value 'ZPURCHDOC_EXCEPTIONS',
      msgno type symsgno value '005',
      attr1 type scx_attrname value 'MV_PURCHASEDOCUMENT',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of PURCHASEDOCEXISTS .
  constants:
    begin of PURCHASEDOCINTIAL,
      msgid type symsgid value 'ZPURCHDOC_EXCEPTIONS',
      msgno type symsgno value '009',
      attr1 type scx_attrname value 'MV_PURCHASEDOCUMENTITEM',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of PURCHASEDOCINTIAL .
  constants:
    begin of PURCHDOCITEMEXISTS,
      msgid type symsgid value 'ZPURCHDOC_EXCEPTIONS',
      msgno type symsgno value '007',
      attr1 type scx_attrname value 'MV_PURCHASEDOCUMENTITEM',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of PURCHDOCITEMEXISTS .
  constants:
    begin of PURCHDOCITEMINITIAL,
      msgid type symsgid value 'ZPURCHDOC_EXCEPTIONS',
      msgno type symsgno value '010',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of PURCHDOCITEMINITIAL .
  constants:
    begin of PURCHASEDOCEXITSINBUFFER,
      msgid type symsgid value 'ZPURCHDOC_EXCEPTIONS',
      msgno type symsgno value '006',
      attr1 type scx_attrname value 'MV_PURCHASEDOCUMENT',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of PURCHASEDOCEXITSINBUFFER .
  constants:
    begin of PURCHDOCITEMEXISTSINBUFFER,
      msgid type symsgid value 'ZPURCHDOC_EXCEPTIONS',
      msgno type symsgno value '008',
      attr1 type scx_attrname value 'MV_PURCHASEDOCUMENTITEM',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of PURCHDOCITEMEXISTSINBUFFER .
  data MV_CURRENCY_CODE type TCURR_CURR .
  data MV_PURCHASEDOCUMENT type ZPURCHASEDOCUMENTDTEL .
  data MV_UNAME type SYUNAME .
  data MV_PURCHASEDOCUMENTITEM type ZPURCHASEDOCUMENTDTEL .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !MV_CURRENCY_CODE type TCURR_CURR optional
      !MV_PURCHASEDOCUMENT type ZPURCHASEDOCUMENTDTEL optional
      !MV_UNAME type SYUNAME optional
      !MV_PURCHASEDOCUMENTITEM type ZPURCHASEDOCUMENTDTEL optional .
protected section.
private section.
ENDCLASS.



CLASS ZCX_PURCHDOC_EXCPTNS IMPLEMENTATION.


  method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
.
me->MV_CURRENCY_CODE = MV_CURRENCY_CODE .
me->MV_PURCHASEDOCUMENT = MV_PURCHASEDOCUMENT .
me->MV_UNAME = MV_UNAME .
me->MV_PURCHASEDOCUMENTITEM = MV_PURCHASEDOCUMENTITEM .
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = IF_T100_MESSAGE=>DEFAULT_TEXTID.
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
  endmethod.
ENDCLASS.
