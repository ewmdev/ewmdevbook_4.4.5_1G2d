class ZCL_IM_WHO_SORT definition
  public
  final
  create public .

public section.

  interfaces /SCWM/IF_EX_WHO_SORT .
  interfaces IF_BADI_INTERFACE .

  class-data SS_WCR type /SCWM/TWCR .

  class-methods GET_WCR_TO
    returning
      value(ES_WCR) type /SCWM/TWCR .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_WHO_SORT IMPLEMENTATION.


  METHOD /scwm/if_ex_who_sort~sort.

    BREAK-POINT ID zewmdevbook_1g2d.

    "If a packaging profile is supplied fill the buffer
    CHECK NOT is_wcr-packprofile IS INITIAL.
    ss_wcr = is_wcr.

  ENDMETHOD.


  METHOD get_wcr_to.

    BREAK-POINT ID zewmdevbook_1g2d.
    es_wcr = ss_wcr.

  ENDMETHOD.
ENDCLASS.
