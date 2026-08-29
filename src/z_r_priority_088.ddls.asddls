@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS Root Priority'
@Metadata.ignorePropagatedAnnotations: true
define view entity Z_R_priority_088
  as select from zdt_priority_088
{
  key priority_code        as PriorityCode,
      priority_description as PriorityDescription
}
