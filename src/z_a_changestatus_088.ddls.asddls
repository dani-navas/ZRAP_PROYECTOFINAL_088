@EndUserText.label: 'CDS Abstract ChangeStatus'
@Metadata.allowExtensions: true
define abstract entity z_a_ChangeStatus_088
{
  @EndUserText.label: 'Change Status'
  @Consumption.valueHelpDefinition: [{entity: { name: 'Z_R_STATUS_088' ,
                                                element: 'StatusCode' },
                                      useForValidation: true            }]
  Status      : zde_status_088;
  @EndUserText.label: 'Add Observation Text'
  description : zde_description_088;

}
