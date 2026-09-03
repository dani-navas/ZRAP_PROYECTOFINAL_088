CLASS lhc_Incident DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    CONSTANTS: BEGIN OF c_status,
                 open       TYPE zde_status_088 VALUE 'OP',
                 inprogress TYPE zde_status_088 VALUE 'IP',
                 pending    TYPE zde_status_088 VALUE 'PE',
                 completed  TYPE zde_status_088 VALUE 'CO',
                 closed     TYPE zde_status_088 VALUE 'CL',
                 canceled   TYPE zde_status_088 VALUE 'CN',
               END OF c_status.


    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR Incident RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations FOR Incident RESULT result.

    METHODS get_instance_features FOR INSTANCE FEATURES
      keys REQUEST requested_features FOR Incident RESULT result.

    METHODS ChangeStatus FOR MODIFY
       keys FOR ACTION Incident~ChangeStatus RESULT result.

    METHODS set_inital_values FOR DETERMINE ON MODIFY
       keys FOR Incident~set_inital_values.

    METHODS new_record_history FOR DETERMINE ON SAVE
       keys FOR Incident~new_record_history.

    METHODS new_record FOR MODIFY
       keys FOR ACTION Incident~new_record.

    METHODS validate_required_fields FOR VALIDATE ON SAVE
       keys FOR Incident~validate_required_fields.

    METHODS validate_range_dates FOR VALIDATE ON SAVE
       keys FOR Incident~validate_range_dates.

    METHODS validate_change_status FOR VALIDATE ON SAVE
       keys FOR Incident~validate_change_status.

    METHODS validate_status_op FOR VALIDATE ON SAVE
       keys FOR Incident~validate_status_op.

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

    result = VALUE #( FOR ls_incident IN incidents ( %tky = ls_incident-%tky
                                                     %action-ChangeStatus = COND #( WHEN ls_incident-%is_draft = if_abap_behv=>mk-on
                                                                                    THEN if_abap_behv=>fc-o-disabled
                                                                                    ELSE if_abap_behv=>fc-o-enabled  )

*                                                    % = COND #( WHEN ls_incident-status = c_status-completed OR
*                                                                                   ls_incident-status = c_status-closed    OR
*                                                                                   ls_incident-status = c_status-canceled
*                                                                                  THEN  if_abap_behv=>fc-o-disabled
*                                                                                  ELSE  if_abap_behv=>fc-o-enabled )
                                                                                      )  ).

  ENDMETHOD.


 METHOD ChangeStatus.

    DATA l_error TYPE abap_boolean.

    DATA lt_update_incidents TYPE TABLE FOR UPDATE z_r_incident_088.
    DATA lt_create_history   TYPE TABLE FOR CREATE z_r_incident_088\_History.

*Lectura de la entidad y obtenemos todos los campos de la entidad z_r_incident_088
*se guardan los datos en la tabla interna incident
    READ ENTITIES OF z_r_incident_088
    IN LOCAL MODE ENTITY Incident
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(incidents).

    CHECK incidents IS NOT INITIAL.

    LOOP AT incidents ASSIGNING FIELD-SYMBOL(<fs_incidents>).

*obtenemos los datos de los parámetros del del boton ChangeStatus
      DATA(l_newstatus)  = keys[ KEY id %tky = <fs_incidents>-%tky ]-%param-Status.
      DATA(l_observation) = keys[ KEY id %tky = <fs_incidents>-%tky ]-%param-description.

*Status actual antes de cambiarlo
      DATA(l_oldstatus)  =  <fs_incidents>-Status.

*No se puede cambiar un incidente a Completed (CO) o Closed (CL) si aún está en Pending (PE)
      IF <fs_incidents>-Status = c_status-pending AND ( l_newstatus = c_status-completed OR
                                                        l_newstatus = c_status-closed ) .

        APPEND  VALUE #( %tky = <fs_incidents>-%tky ) TO failed-incident.
        APPEND VALUE #( %tky        = <fs_incidents>-%tky
                        %state_area = 'VALIDATE_STATUS'
                        %msg        = NEW zcl_message_incident_088( textid   = zcl_message_incident_088=>validate_status_pe
                                                                    severity = if_abap_behv_message=>severity-error )
                        %op-%action-ChangeStatus = if_abap_behv=>mk-on
                           ) TO reported-incident.
        l_error = abap_true.
      ENDIF.

*Para un incidente con estatus Canceled (CN), Completed (CO) o Closed (CL), ya no es posible cambiar el estatus
      IF <fs_incidents>-Status = c_status-canceled   OR
         <fs_incidents>-Status = c_status-completed  OR
         <fs_incidents>-Status = c_status-closed.
        APPEND  VALUE #( %tky = <fs_incidents>-%tky ) TO failed-incident.
        APPEND VALUE #( %tky        = <fs_incidents>-%tky
                        %state_area = 'VALIDATE_STATUS'
                        %msg        = NEW zcl_message_incident_088( textid   = zcl_message_incident_088=>validate_status_co_cl_ca
                                                                    severity = if_abap_behv_message=>severity-error )
                        %op-%action-ChangeStatus = if_abap_behv=>mk-on
                           ) TO reported-incident.
        l_error = abap_true.
      ENDIF.

*Si el estado cambia a In Progress (IP), debe asignarse un RESPONSABLE
*Solo el usuario asignado o un administrador pueden cambiar el estado de un incidente.
      DATA(l_user_responsable) = cl_abap_context_info=>get_user_technical_name( ).

      IF <fs_incidents>-Status = c_status-inprogress  AND l_user_responsable <> 'CB9980000088'.
        APPEND  VALUE #( %tky = <fs_incidents>-%tky ) TO failed-incident.
        APPEND VALUE #( %tky        = <fs_incidents>-%tky
                        %state_area = 'VALIDATE_STATUS'
                        %msg        = NEW zcl_message_incident_088( textid   = zcl_message_incident_088=>validate_user
                                                                    user     = l_user_responsable
                                                                    severity = if_abap_behv_message=>severity-error )
                        %op-%action-ChangeStatus = if_abap_behv=>mk-on
                           ) TO reported-incident.
        l_error = abap_true.
      ENDIF.

      CHECK l_error = abap_false.

      APPEND VALUE #( %tky   = <fs_incidents>-%tky
                      status = l_newstatus
                      changedDate = cl_abap_context_info=>get_system_date( )   ) TO lt_update_incidents.


*Obtenemos de la tabla de BBDD el HisId con el valor mayor es decir el último valor guardado,
*teniendo en cuenta que tiene que ser del mísmo IncUuid
      SELECT SINGLE FROM zdt_inct_h_088
      FIELDS MAX( his_id )
      WHERE inc_uuid = @<fs_incidents>-IncUuid AND
            his_id IS NOT INITIAL
      INTO @DATA(l_his_id).

*se rellena la tabla interna con los nuevos datos
      TRY.
          APPEND VALUE #( %tky = <fs_incidents>-%tky
                          %target = VALUE #( ( hisuuid = cl_system_uuid=>create_uuid_x16_static( )
                                               incuuid = <fs_incidents>-incuuid
                                               hisid = l_his_id + 1
                                               PreviousStatus = l_oldstatus
                                               newstatus = l_newstatus
                                               text = l_observation
                                               ) )
                                               )
                                              TO lt_create_history.
        CATCH cx_uuid_error.
          "handle exception
      ENDTRY.
    ENDLOOP.

    MODIFY ENTITIES OF z_r_incident_088
   IN LOCAL MODE ENTITY Incident
   UPDATE FIELDS
   ( status
     ChangedDate   )
   WITH lt_update_incidents.


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
    WITH lt_creatE_history
    MAPPED mapped.


    READ ENTITIES OF z_r_incident_088
    IN LOCAL MODE ENTITY Incident
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_incidents).

    result = VALUE #( FOR ls_Incident IN lt_incidents ( %tky   = ls_incident-%tky
                                                        %param = ls_incident             ) ).


  ENDMETHOD.

  METHOD set_inital_values.

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


*Se inserta el registro en la tabla History
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

      IF ls_incident-IncidentId IS INITIAL.
        APPEND  VALUE #( %tky = ls_incident-%tky ) TO failed-incident.
        APPEND VALUE #( %tky        = ls_incident-%tky
                        %state_area = 'VALIDATE_REQUEST'
                        %msg        = NEW zcl_message_incident_088( textid   = zcl_message_incident_088=>incidentid
                                                                    severity = if_abap_behv_message=>severity-error )
                        %element-IncidentId = if_abap_behv=>mk-on
                           ) TO reported-incident.
      ENDIF.
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


  METHOD validate_change_status.

    READ ENTITIES OF z_r_incident_088
    IN LOCAL MODE ENTITY Incident
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(incidents).

    LOOP AT incidents INTO DATA(ls_incidents).

*Si el estado cambia a In Progress (IP), debe asignarse un responsable
*Solo el usuario asignado o un administrador pueden cambiar el estado de un incidente.
      DATA(l_user_responsable) = cl_abap_context_info=>get_user_technical_name( ).

      IF ls_incidents-Status = c_status-inprogress  AND l_user_responsable <> 'CB9980000088'.
        APPEND  VALUE #( %tky = ls_incidents-%tky  )  TO failed-incident.
        APPEND VALUE #( %tky        = ls_incidents-%tky
                        %state_area = 'VALIDATE_STATUS'
                        %msg        = NEW zcl_message_incident_088( textid   = zcl_message_incident_088=>validate_user
                                                                    user     = l_user_responsable
                                                                    severity = if_abap_behv_message=>severity-error )
                        %element-Status = if_abap_behv=>mk-on
                           ) TO reported-incident.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


METHOD validate_status_op.

    CHECK keys IS NOT INITIAL.

*Con la tabla de validación KEYS se obtiene de la BBDD el registro que se quiere eliminar
* mediante el InncUuid(UUID clave única por registro)
    SELECT inc_uuid, status
        FROM zdt_inct_088
        FOR ALL ENTRIES IN @keys
        WHERE inc_uuid = @keys-IncUuid
        INTO TABLE @DATA(lt_db_incidents).

    LOOP AT lt_db_incidents INTO DATA(ls_db_incident).

*Se comprueba que tenga el STATUS = 'OP' (Abierto) si es así se va a buscar mediante el UUID para obtener el %TKY
*para mostrar el mensaje de error y bloquear la acción
      IF ls_db_incident-status = c_status-open.
        READ TABLE keys INTO DATA(ls_key) WITH KEY IncUuid = ls_db_incident-inc_uuid.
        IF sy-subrc = 0.
          APPEND VALUE #( %tky = ls_key-%tky ) TO failed-incident.
          APPEND VALUE #( %tky = ls_key-%tky
                          %msg = NEW zcl_message_incident_088( textid   = zcl_message_incident_088=>validate_status_op_delete
                                                               severity = if_abap_behv_message=>severity-error  )
                        ) TO reported-incident.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
