@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS Consumption History'
@Metadata.ignorePropagatedAnnotations: true 
@Metadata.allowExtensions: true
define view entity Z_c_history_088
  as projection on Z_R_history_088
{
  key HisUuid,
  key IncUuid,
  key HisId,
        
      @Search.fuzzinessThreshold: 0.8
      @Consumption.valueHelpDefinition: [{entity: { name: 'Z_R_STATUS_088' ,
                                                    element: 'STATUS_DESCRIPTION' },
                                          useForValidation: true }]

      PreviousStatus,
      @Search.fuzzinessThreshold: 0.8
      @Consumption.valueHelpDefinition: [{entity: { name: 'Z_R_STATUS_088' ,
                                                    element: 'STATUS_DESCRIPTION' },
                                        useForValidation: true  }]
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
