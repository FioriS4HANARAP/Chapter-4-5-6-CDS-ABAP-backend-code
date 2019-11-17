"!@testing Z_I_PURCHASEDOCUMENT_U
CLASS ltc_Z_I_PURCHASEDOCUMENT_U
DEFINITION FINAL FOR TESTING
DURATION SHORT
RISK LEVEL HARMLESS.
  PRIVATE SECTION.

    CLASS-DATA:
      environment TYPE REF TO if_cds_test_environment.

    CLASS-METHODS:
      "! In CLASS_SETUP, corresponding doubles and clone(s) for the CDS view under test and its dependencies are created.
      class_setup RAISING cx_static_check,
      "! In CLASS_TEARDOWN, Generated database entities (doubles & clones) should be deleted at the end of test class execution.
      class_teardown.

    DATA:
      act_results                 TYPE STANDARD TABLE OF z_i_purchasedocument_u WITH EMPTY KEY,
      lt_z_i_purchdocoverallprice TYPE STANDARD TABLE OF z_i_purchdocoverallprice WITH EMPTY KEY.

    METHODS:
      "! SETUP method creates a common start state for each test method,
      "! clear_doubles clears the test data for all the doubles used in the test method before each test method execution.
      setup RAISING cx_static_check,
      prepare_testdata_price IMPORTING
          iv_price TYPE float,
      "!  In this method test data is inserted into the generated double(s) and the test is executed and
      "!  the results should be asserted with the actuals.
      price_zero_not_critical FOR TESTING RAISING cx_static_check,
      price_1k_medium_critical FOR TESTING RAISING cx_static_check,
      price_10k_medium_critical FOR TESTING RAISING cx_static_check,
      price_10001_critical FOR TESTING RAISING cx_static_check,
      price_approval_required FOR TESTING RAISING cx_static_check,
      price_no_approval_required FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltc_Z_I_PURCHASEDOCUMENT_U IMPLEMENTATION.

  METHOD class_setup.
    environment = cl_cds_test_environment=>create( i_for_entity = 'Z_I_PURCHASEDOCUMENT_U' ).
  ENDMETHOD.

  METHOD setup.
    environment->clear_doubles( ).
  ENDMETHOD.

  METHOD class_teardown.
    environment->destroy( ).
  ENDMETHOD.

  METHOD price_zero_not_critical.
    prepare_testdata_price( 0 ).
    SELECT * FROM Z_I_PurchaseDocument_U INTO TABLE @act_results.
    cl_abap_unit_assert=>assert_equals( exp = 3 act = act_results[ 1 ]-overallpricecriticality ).
  ENDMETHOD.

  METHOD price_1k_medium_critical.
    prepare_testdata_price( 1000 ).
    SELECT * FROM Z_I_PurchaseDocument_U INTO TABLE @act_results.
    cl_abap_unit_assert=>assert_equals( exp = 2 act = act_results[ 1 ]-overallpricecriticality ).
  ENDMETHOD.

  METHOD price_10k_medium_critical.
    prepare_testdata_price( 10000 ).
    SELECT * FROM Z_I_PurchaseDocument_U INTO TABLE @act_results.
    cl_abap_unit_assert=>assert_equals( exp = 2 act = act_results[ 1 ]-overallpricecriticality ).
  ENDMETHOD.

  METHOD price_10001_critical.
    prepare_testdata_price( 10001 ).
    SELECT * FROM Z_I_PurchaseDocument_U INTO TABLE @act_results.
    cl_abap_unit_assert=>assert_equals( exp = 1 act = act_results[ 1 ]-overallpricecriticality ).
  ENDMETHOD.

  METHOD price_approval_required.
    prepare_testdata_price( 1001 ).
    SELECT * FROM Z_I_PurchaseDocument_U INTO TABLE @act_results.
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = act_results[ 1 ]-isapprovalrequired ).
  ENDMETHOD.

  METHOD price_no_approval_required.
    prepare_testdata_price( 1000 ).
    SELECT * FROM Z_I_PurchaseDocument_U INTO TABLE @act_results.
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = act_results[ 1 ]-isapprovalrequired ).
  ENDMETHOD.

  METHOD prepare_testdata_price.

    "Prepare test data for 'z_i_purchdocoverallprice'
    lt_z_i_purchdocoverallprice = VALUE #(
      (
        purchasedocument = '1'
        overallprice = iv_price
        currency = 'EUR'
        purchasingorganization = 'ORG1'
        description = 'Test'
        status = '2'
        priority = '1'
        crea_uname = 'MATHEWBIN'
        lchg_uname = 'MATHEWBIN'
      ) ).
    environment->insert_test_data( i_data =  lt_z_i_purchdocoverallprice ).

  ENDMETHOD.

ENDCLASS.
