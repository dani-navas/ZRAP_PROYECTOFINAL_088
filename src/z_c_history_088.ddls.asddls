@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS Consumption History'
@Metadata.ignorePropagatedAnnotations: true
define view entity Z_c_history_088
  as projection on Z_R_history_088
{
  key HisUuid,
  key IncUuid,
  key HisId,
      PreviousStatus,
      NewStatus,
      Text,
      @Semantics.user.createdBy: true
      LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      LocalCreatedAt,
      @Semantics.user.lastChangedBy: true
      LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      LastChangedAt,
      /* Associations */
      _Incident : redirected to parent Z_c_INCIDENT_088
}
