@AbapCatalog.sqlViewName: 'ZPRCHVNDTYPVH'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value Help for Vendor Type'

@Search.searchable: true

@ObjectModel.semanticKey:  [ 'VendorType' ]
@ObjectModel.representativeKey: ['VendorType']
@VDM.viewType: #CONSUMPTION

@ObjectModel.resultSet.sizeCategory: #XS
@ObjectModel.dataCategory: #VALUE_HELP
define view Z_C_VendorTypeVH 
  as select from Z_I_VendorType as VendorTypeText
  {
    @ObjectModel.text.element: ['VendorTypeText']
    key VendorType,
    @Search: { defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.7 }
    VendorTypeText
}
