@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS Consumption Incident'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity Z_c_INCIDENT_088
  provider contract transactional_query
  as projection on Z_R_INCIDENT_088
{
  key IncUuid,

      @Semantics.text: true
      @Search.fuzzinessThreshold: 0.8
      @Search.ranking: #HIGH
      IncidentId,

      Title,

      @Semantics.text: true
      @Search.fuzzinessThreshold: 0.8
      @Search.ranking: #HIGH
      Description,
 
      @Search.fuzzinessThreshold: 0.8
      @Search.ranking: #HIGH
      @Consumption.valueHelpDefinition: [{entity: { name: 'Z_R_STATUS_088' ,
                                                    element: 'STATUS_DESCRIPTION' },
                                          useForValidation: true            }]

      @ObjectModel.text.element: [ 'StatusDescription' ]
      Status,
      _Status.StatusDescription     as StatusDescription,


      @Search.fuzzinessThreshold: 0.8
      @Search.ranking: #HIGH
      @Consumption.valueHelpDefinition: [{entity: { name: 'Z_R_PRIORITY_088' ,
                                                    element: 'PRIORTIY_DESCRIPTION' },
                                          useForValidation: true            }]
      @ObjectModel.text.element: [ 'PriorityDescription' ]
      Priority,
      _Priority.PriorityDescription as PriorityDescription,

      @Semantics.text: true
      @Search.fuzzinessThreshold: 0.8
      @Search.ranking: #HIGH
      CreationDate,

      @Semantics.text: true
      @Search.fuzzinessThreshold: 0.8
      @Search.ranking: #HIGH
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
