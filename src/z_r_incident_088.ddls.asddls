@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS Root Incident'
@Metadata.ignorePropagatedAnnotations: true
define root view entity Z_R_INCIDENT_088
  as select from zdt_inct_088
  composition [0..*] of Z_R_history_088  as _History
  association [0..1] to Z_R_status_088   as _Status   on _Status.StatusCode = $projection.Status
  association [0..1] to Z_R_priority_088 as _Priority on _Priority.PriorityCode = $projection.Priority
{

  key inc_uuid              as IncUuid,
      incident_id           as IncidentId,
      title                 as Title,
      description           as Description,
      status                as Status,
      priority              as Priority,
      creation_date         as CreationDate,
      changed_date          as ChangedDate,
      @Semantics.user.createdBy: true
      local_created_by      as LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      local_created_at      as LocalCreatedAt,
      @Semantics.user.lastChangedBy: true
      local_last_changed_by as LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      //Asociación PADRE (INCIDENT)->HIJO(HISTORY)
      _History,
      _Status,
      _Priority
}
