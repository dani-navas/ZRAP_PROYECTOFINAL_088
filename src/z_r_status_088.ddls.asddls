@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Ayuda de Búsqueda CDS Root Status'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.dataCategory: #VALUE_HELP
@Metadata.allowExtensions: true
define view entity z_r_status_088
  as select from zdt_status_088
{
      @ObjectModel.text.element: [ 'StatusDescription' ]
      @UI.textArrangement: #TEXT_LAST
  key status_code        as StatusCode,
      status_description as StatusDescription
}
