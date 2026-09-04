@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Ayuda de Búsqueda CDS Root Priority'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.dataCategory: #VALUE_HELP
@Metadata.allowExtensions: true
define view entity Z_R_priority_088
  as select from zdt_priority_088
{
      @ObjectModel.text.element: [ 'PriorityDescription' ]
      @UI.textArrangement: #TEXT_LAST
  key priority_code        as PriorityCode,
      priority_description as PriorityDescription
}
