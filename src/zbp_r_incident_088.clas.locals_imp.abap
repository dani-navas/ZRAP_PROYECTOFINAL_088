CLASS lhc_Incident DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR Incident RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations FOR Incident RESULT result.

    METHODS get_instance_features FOR INSTANCE FEATURES
      keys REQUEST requested_features FOR Incident RESULT result.

    METHODS ChangeStatus FOR MODIFY
       keys FOR ACTION Incident~ChangeStatus RESULT result.

    METHODS default_values FOR DETERMINE ON MODIFY
       keys FOR Incident~default_values.

    METHODS new_record_history FOR DETERMINE ON SAVE
       keys FOR Incident~new_record_history.

    METHODS new_record FOR MODIFY
       keys FOR ACTION Incident~new_record.

    METHODS validate_required_fields FOR VALIDATE ON SAVE
       keys FOR Incident~validate_required_fields.

    METHODS validate_range_dates FOR VALIDATE ON SAVE
       keys FOR Incident~validate_range_dates.

ENDCLASS.

CLASS lhc_Incident IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD get_instance_features.

*Lectura de la entidad y obtenemos todos los campos de la entidad z_r_incident_088
*se guardan los datos en la tabla interna incident
    READ ENTITIES OF z_r_incident_088
    IN LOCAL MODE ENTITY Incident
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(incidents).

    result = VALUE #( FOR ls_incident IN incidents (
                                     %tky = ls_incident-%tky
                                     %action-ChangeStatus = COND #( WHEN ls_incident-%is_draft = if_abap_behv=>mk-on
                                                                 THEN if_abap_behv=>fc-o-disabled
                                                                 ELSE if_abap_behv=>fc-o-enabled )
                                                                  ) ).

  ENDMETHOD.

  METHOD ChangeStatus.
  ENDMETHOD.

  METHOD default_values.

*Lectura de la entidad y obtenemos todos los campos de la entidad z_r_incident_088
*se guardan los datos en la tabla interna incident
    READ ENTITIES OF z_r_incident_088
    IN LOCAL MODE ENTITY Incident
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(incidents).

*se descarta los registros que ya tienen un IncidentId asignado
    DELETE incidents WHERE IncidentId IS NOT INITIAL.

    CHECK incidents IS NOT INITIAL.

*Obtenemos de la tabla de BBDD el IncidentId con el valor mayor es decir el último valor guardado
*Status = 'OP'
*CretionDate con la fecha del systema
    SELECT SINGLE FROM zdt_inct_088
    FIELDS MAX( incident_id )
    INTO @DATA(l_incident).

    MODIFY ENTITIES OF z_r_incident_088
    IN LOCAL MODE ENTITY Incident
    UPDATE FIELDS ( IncidentId
                     Status
                     CreationDate )
    WITH VALUE #( FOR incident IN incidents INDEX INTO l_index
                   (  %tky = incident-%tky
                      IncidentId = l_incident + l_index
                      status = 'OP'
                      CreationDate = cl_abap_context_info=>get_system_date( )
                      ) ).

  ENDMETHOD.

  METHOD new_record_history.

*al guardar el regsitro creado de Incident, ejecuta la acción interna: new_record,
*la acción new record creara un registro en la tabla History
    MODIFY ENTITIES OF z_r_incident_088
    IN LOCAL MODE
    ENTITY Incident
    EXECUTE new_record
    FROM CORRESPONDING #( keys ).

  ENDMETHOD.


  METHOD new_record.

    DATA lt_history_create TYPE TABLE FOR CREATE z_r_incident_088\_History.


*Lectura de la entidad y obtenemos todos los campos de la entidad z_r_incident_088
*se guardan los datos en la tabla interna incident
    READ ENTITIES OF z_r_incident_088
    IN LOCAL MODE ENTITY Incident
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(incidents).


    LOOP AT incidents ASSIGNING FIELD-SYMBOL(<fs_incidents>).

*Obtenemos de la tabla de BBDD el HisId con el valor mayor es decir el último valor guardado,
*teniendo en cuenta que tiene que ser del mísmo IncUuid
      SELECT SINGLE FROM zdt_inct_h_088
      FIELDS MAX( his_id )
      WHERE inc_uuid = @<fs_incidents>-IncUuid AND
            his_id IS NOT INITIAL
      INTO @DATA(l_his_id).

*Se inserta el registro con los valores iniciales a la tabla interna
      TRY.
          APPEND VALUE #( %tky = <fs_incidents>-%tky
                          %target = VALUE #( ( hisuuid = cl_system_uuid=>create_uuid_x16_static( )
                                               incuuid = <fs_incidents>-incuuid
                                               hisid = l_his_id + 1
                                               PreviousStatus = ''
                                               newstatus = 'OP'
                                               text = 'First Incident'  ) )
                                               )
                                              TO lt_history_create.
        CATCH cx_uuid_error.
          "handle exception
      ENDTRY.
    ENDLOOP.


*Se el registro en la tabla History
    MODIFY ENTITIES OF z_r_incident_088
   IN LOCAL MODE ENTITY Incident
   CREATE BY \_History
   FIELDS ( HisUuid
            IncUuid
            HisId
            PreviousStatus
            NewStatus
            Text )
   AUTO FILL CID
   WITH lt_history_create.

  ENDMETHOD.

  METHOD validate_required_fields.

*Lectura de la entidad y obtenemos todos los campos de la entidad z_r_incident_088
*se guardan los datos en la tabla interna incident
    READ ENTITIES OF z_r_incident_088
    IN LOCAL MODE ENTITY Incident
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(incidents).

    CHECK incidents IS NOT INITIAL.

    LOOP AT incidents INTO DATA(ls_incident).

      IF ls_incident-Title IS INITIAL.
        APPEND  VALUE #( %tky = ls_incident-%tky ) TO failed-incident.
        APPEND VALUE #( %tky        = ls_incident-%tky
                        %state_area = 'VALIDATE_REQUEST'
                        %msg        = NEW zcl_message_incident_088( textid   = zcl_message_incident_088=>title
                                                                    severity = if_abap_behv_message=>severity-error )
                        %element-title = if_abap_behv=>mk-on
                           ) TO reported-incident.
      ENDIF.
      IF ls_incident-Description IS INITIAL.
        APPEND  VALUE #( %tky = ls_incident-%tky ) TO failed-incident.
        APPEND VALUE #( %tky        = ls_incident-%tky
                        %state_area = 'VALIDATE_REQUEST'
                        %msg        = NEW zcl_message_incident_088( textid   = zcl_message_incident_088=>description
                                                                    severity = if_abap_behv_message=>severity-error )
                        %element-description = if_abap_behv=>mk-on
                        ) TO reported-incident.
      ENDIF.
      IF ls_incident-priority IS INITIAL.
        APPEND  VALUE #( %tky = ls_incident-%tky ) TO failed-incident.
        APPEND VALUE #( %tky        = ls_incident-%tky
                        %state_area = 'VALIDATE_REQUEST'
                        %msg        = NEW zcl_message_incident_088( textid   = zcl_message_incident_088=>priority
                                                                    severity = if_abap_behv_message=>severity-error )
                        %element-priority = if_abap_behv=>mk-on
                        ) TO reported-incident.
      ENDIF.
      IF ls_incident-status IS INITIAL.
        APPEND  VALUE #( %tky = ls_incident-%tky ) TO failed-incident.
        APPEND VALUE #( %tky        = ls_incident-%tky
                        %state_area = 'VALIDATE_REQUEST'
                        %msg        = NEW zcl_message_incident_088( textid   = zcl_message_incident_088=>status
                                                                    severity = if_abap_behv_message=>severity-error )
                        %element-status = if_abap_behv=>mk-on
                        ) TO reported-incident.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD validate_range_dates.

*Lectura de la entidad y obtenemos todos los campos de la entidad z_r_incident_088
*se guardan los datos en la tabla interna incident
    READ ENTITIES OF z_r_incident_088
    IN LOCAL MODE ENTITY Incident
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(incidents).

    CHECK incidents IS NOT INITIAL.

    LOOP AT incidents INTO DATA(ls_incident).

      IF ( ls_incident-CreationDate IS NOT INITIAL AND
           ls_incident-ChangedDate  IS NOT INITIAL ) AND
        (  ls_incident-CreationDate > ls_incident-ChangedDate   ) .
        APPEND VALUE #( %tky = ls_incident-%tky ) TO failed-incident.
        APPEND VALUE #( %tky         = ls_incident-%tky
                        %state_area  = 'VALIDATE_DATES'
                        %msg         = NEW zcl_message_incident_088( textid = zcl_message_incident_088=>createdate_changeddate
                                                                     changed_date = ls_incident-ChangedDate
                                                                     create_date = ls_incident-CreationDate
                                                                  severity = if_abap_behv_message=>severity-error  )
                        %element-ChangedDate = if_abap_behv=>mk-on
                        ) TO reported-incident.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
