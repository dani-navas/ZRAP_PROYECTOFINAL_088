@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS Consumption Incident'
@Metadata.ignorePropagatedAnnotations: true
define root view entity Z_c_INCIDENT_088
  provider contract transactional_query
  as projection on Z_R_INCIDENT_088
{
  key IncUuid,
      IncidentId,
      Title,
      Description,
      Status,
      Priority,
      CreationDate,
      ChangedDate,
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
      _History : redirected to composition child Z_c_history_088
}
