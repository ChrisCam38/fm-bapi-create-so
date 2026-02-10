FUNCTION zla02_createso_mr.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(DOC_TYPE) TYPE  AUART
*"     REFERENCE(SALES_ORG) TYPE  VKORG
*"     REFERENCE(DISTR_CHAN) TYPE  VTWEG
*"     REFERENCE(DIVISION) TYPE  SPART
*"     REFERENCE(SOLD_TO) TYPE  KUNNR
*"     REFERENCE(TEST_RUN) TYPE  CHAR1
*"  EXPORTING
*"     REFERENCE(SALES_DOC) TYPE  VBELN_VA
*"----------------------------------------------------------------------
  DATA: ls_header  TYPE bapisdhd1,
        lv_soldto  TYPE kunnr,
        ls_headerx TYPE bapisdhd1x,
        lt_items   TYPE STANDARD TABLE OF bapisditm,
        lt_itemsx  TYPE STANDARD TABLE OF bapisditmx,
        lt_partner TYPE STANDARD TABLE OF bapiparnr,
        lt_return  TYPE STANDARD TABLE OF bapiret2,
        lt_schdl type standard table of bapischdl,
        ls_item    TYPE bapisditm,
        ls_itemx   TYPE bapisditmx,
        ls_partner TYPE bapiparnr,
        ls_schdl   TYPE bapischdl.


  ls_header-doc_type = doc_type.
  ls_header-sales_org = sales_org.
  ls_header-distr_chan = distr_chan.
  ls_header-division = division.


  ls_headerx-doc_type = 'X'.

  ls_headerx-sales_org = 'X'.
  ls_headerx-distr_chan = 'X'.
  ls_headerx-division = 'X'.


  ls_item-itm_number = '000000'.
  ls_item-material = 'MZ-FG-R100'.
  ls_item-target_qty = '1'.
  ls_item-item_categ = 'TATX'.
  ls_item-short_text = 'Placeholder item'.
  APPEND ls_item TO lt_items.

  ls_itemx-itm_number = '000000'.
  ls_itemx-updateflag = 'I'.
  ls_itemx-item_categ = 'X' .
  ls_itemx-short_text = 'X'.
  ls_itemx-target_qty = 'X'.
  APPEND ls_itemx TO lt_itemsx.

  lv_soldto = sold_to.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = lv_soldto
    IMPORTING
      output = lv_soldto.

  ls_partner-itm_number = '000010'.
  ls_partner-partn_role = 'AG'.
  ls_partner-partn_numb = lv_soldto.
  APPEND ls_partner TO lt_partner.

  ls_partner-itm_number = '000000'.
  ls_partner-partn_role = 'WE'.
  ls_partner-partn_numb = lv_soldto.
  APPEND ls_partner TO lt_partner.

  ls_schdl-itm_number = '000010'.
  ls_schdl-sched_line = '0001'.
  ls_schdl-req_qty    = '1'.
  ls_schdl-req_date   = '20260204'.
  APPEND ls_schdl TO lt_schdl.



  CALL FUNCTION 'BAPI_SALESORDER_CREATEFROMDAT2'
    EXPORTING
*     SALESDOCUMENTIN  =
      order_header_in  = ls_header
      order_header_inx = ls_headerx
*     SENDER           =
*     BINARY_RELATIONSHIPTYPE       =
*     INT_NUMBER_ASSIGNMENT         =
*     BEHAVE_WHEN_ERROR  =
*     LOGIC_SWITCH     =
      testrun          = test_run
*     CONVERT          = ' '
*     NO_DEQUEUE_ALL   = ' '
    IMPORTING
      salesdocument    = sales_doc
    TABLES
      order_items_in   = lt_items
      order_items_inx  = lt_itemsx
      order_partners   = lt_partner
      return           = lt_return
      order_schedules_in = lt_schdl.
*   ORDER_SCHEDULES_INX           =
*   ORDER_CONDITIONS_IN           =
*   ORDER_CONDITIONS_INX          =
*   ORDER_CFGS_REF                =
*   ORDER_CFGS_INST               =
*   ORDER_CFGS_PART_OF            =
*   ORDER_CFGS_VALUE              =
*   ORDER_CFGS_BLOB               =
*   ORDER_CFGS_VK                 =
*   ORDER_CFGS_REFINST            =
*   ORDER_CCARD                   =
*   ORDER_TEXT                    =
*   ORDER_KEYS                    =
*   EXTENSIONIN                   =
*   PARTNERADDRESSES              =
*   EXTENSIONEX                   =
*   NFMETALLITMS                  =

  LOOP AT lt_return ASSIGNING FIELD-SYMBOL(<i>).
    WRITE: <i>-type, <i>-id, <i>-number, <i>-message.
  ENDLOOP.
  DATA(lv_error) = abap_false.
  LOOP AT lt_return ASSIGNING FIELD-SYMBOL(<r>)
    WHERE type = 'E' OR type = 'A' OR type = 'X'.
    lv_error = abap_true.
    EXIT.
  ENDLOOP.

  IF lv_error = abap_false AND test_run IS INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*      DESTINATION 'NONE'
      EXPORTING
        wait = 'x'.
  ENDIF.
ENDFUNCTION.
