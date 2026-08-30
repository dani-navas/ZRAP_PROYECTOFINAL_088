@EndUserText.label: 'CDS Abstract ChangeStatus'
define abstract entity z_a_ChangeStatus_088
{
  @EndUserText.label: 'Change Status'
  @Consumption.valueHelpDefinition: [{entity: { name: 'Z_R_STATUS_088' ,
                                                element: 'STATUS_DESCRIPTION' },
                                      useForValidation: true            }]
  Status      : zde_status_088;
  @EndUserText.label: 'Add Observation Text'
  description : zde_description_088;

}
