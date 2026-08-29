CLASS zcl_database_generation_088 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_database_generation_088 IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.

*Se rellena con datos la tabla Status, con su code y descripciones
    DELETE FROM zdt_status_088.
    MODIFY zdt_status_088 FROM TABLE @( VALUE #( ( status_code = 'OP'
                                                   status_description = 'Open' )

                                                 ( status_code = 'IP'
                                                   status_description = 'In Progress' )

                                                 (    status_code = 'PE'
                                                   status_description = 'Pending' )

                                                 (    status_code = 'CO'
                                                   status_description = 'Completed' )

                                                  (   status_code = 'CL'
                                                   status_description = 'Closed' )

                                                 (   status_code = 'CN'
                                                   status_description = 'Canceled' )
                                                    ) ).

    IF sy-subrc = 0.
      out->write( |Registros insertado en ZDT_STATUS_088: { sy-dbcnt }| ).
    ENDIF.


*Se rellena con datos la tabla Priority, con su code y descripciones
    DELETE FROM zdt_priority_088.
    MODIFY zdt_priority_088 FROM TABLE @( VALUE #( ( priority_code = 'H'
                                                   priority_description = 'High' )

                                                 ( priority_code = 'M'
                                                   priority_description = 'Medium' )

                                                 (    priority_code = 'L'
                                                   priority_description = 'Low' )
                                                    ) ).

    IF sy-subrc = 0.
      out->write( |Registros insertado en ZDT_PRIORITY_088: { sy-dbcnt }| ).
    ENDIF.


  ENDMETHOD.

ENDCLASS.
