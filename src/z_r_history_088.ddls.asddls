@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS Root History'
@Metadata.ignorePropagatedAnnotations: true
define view entity Z_R_history_088
  as select from zdt_inct_h_088
  association to parent Z_R_INCIDENT_088 as _Incident on $projection.IncUuid = _Incident.IncUuid
{

  key his_uuid              as HisUuid,
  key inc_uuid              as IncUuid,
  key his_id                as HisId,
      previous_status       as PreviousStatus,
      new_status            as NewStatus,
      text                  as Text,
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
      //Asociación Hijo(HISTORY)->Padre(INCIDENT)
      _Incident
}
