@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS Root Status'
@Metadata.ignorePropagatedAnnotations: true
define view entity Z_R_status_088
  as select from zdt_status_088
{
  key status_code        as StatusCode,
      status_description as StatusDescription
}
