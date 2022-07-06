class ZCL_IM_HU_BASICS_HUHDR definition
  public
  final
  create public .

public section.

  interfaces /SCWM/IF_EX_HU_BASICS_HUHDR .
  interfaces IF_BADI_INTERFACE .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_HU_BASICS_HUHDR IMPLEMENTATION.


  METHOD /scwm/if_ex_hu_basics_huhdr~change.

    DATA: ls_t340d    TYPE /scwm/t340d,
          ls_t300md   TYPE /scwm/s_t300_md,
          lt_packspec TYPE /scwm/tt_guid_ps,
          lt_pscont   TYPE /scwm/tt_packspec_nested.

    BREAK-POINT ID zewmdevbook_445.

* Get WCR from buffer
    DATA(ls_wcr) = zcl_im_who_sort=>get_wcr_to( ).
* Check if buffer is filled
    CHECK NOT ls_wcr IS INITIAL.
* Get warehouse settings
    CALL FUNCTION '/SCWM/T340D_READ_SINGLE'
      EXPORTING
        iv_lgnum  = cs_huhdr-lgnum
      IMPORTING
        es_t340d  = ls_t340d
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.
    IF sy-subrc <> 0.
      EXIT.
    ENDIF.
* Get warehouse assignment
    CALL FUNCTION '/SCWM/T300_MD_READ_SINGLE'
      EXPORTING
        iv_lgnum   = cs_huhdr-lgnum
      IMPORTING
        es_t300_md = ls_t300md
      EXCEPTIONS
        not_found  = 1
        OTHERS     = 99.
    IF sy-subrc <> 0.
      EXIT.
    ENDIF.
* Build up field catalog
    DATA(ls_fields) = VALUE /scwm/pak_com_i( pak_locid = ls_t300md-scuguid
                                             pak_rule  = ls_wcr-packprofile ).
* Get packaging specification
    CALL FUNCTION '/SCWM/PS_FIND_AND_EVALUATE'
      EXPORTING
        is_fields       = ls_fields
        iv_procedure    = ls_t340d-whoctlist
        i_data          = ls_wcr-packprofile
      IMPORTING
        et_packspec     = lt_packspec
      EXCEPTIONS
        determine_error = 1
        read_error      = 2
        OTHERS          = 99.
    IF sy-subrc <> 0.
      EXIT.
    ENDIF.
* Determine HU type from packspec
    LOOP AT lt_packspec INTO DATA(lv_guid_ps).
      CLEAR: lt_pscont.
      CALL FUNCTION '/SCWM/PS_PACKSPEC_GET'
        EXPORTING
          iv_guid_ps             = lv_guid_ps
          iv_read_elements       = abap_true
          iv_read_dyn_attributes = abap_true
        IMPORTING
          et_packspec_content    = lt_pscont
        EXCEPTIONS
          error                  = 1
          OTHERS                 = 99.
      IF sy-subrc <> 0.
        EXIT.
      ENDIF.
      SORT lt_pscont BY content-content_seq DESCENDING.
      TRY.
          DATA(pscont) = VALUE #( lt_pscont[ 1 ] ).
        CATCH cx_sy_itab_line_not_found.
          CONTINUE.
      ENDTRY.
      SORT pscont-levels BY display_seq DESCENDING.
      DATA(level) = VALUE #( pscont-levels[ 1 ] OPTIONAL ).
      IF level-hu_matid IS INITIAL.
        CONTINUE.
      ENDIF.
* Set HU type from packaging specification
* Only if packmat of HU and packspec is the same
      IF level-hu_matid EQ cs_huhdr-pmat_guid
      AND NOT level-hutyp IS INITIAL.
        cs_huhdr-letyp = level-hutyp.
      ELSE.
        CONTINUE.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  method /SCWM/IF_EX_HU_BASICS_HUHDR~CREATE.
  endmethod.
ENDCLASS.
