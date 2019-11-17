@AbapCatalog.sqlViewName: 'ZPRCHVNDRTYPE'
@VDM.viewType: #BASIC
@AccessControl.authorizationCheck: #NOT_ALLOWED
@EndUserText.label: 'Vendor Type'
@ObjectModel.representativeKey: 'VendorType'
@ObjectModel.semanticKey: ['VendorType']
@Analytics.dataCategory: #DIMENSION
@ObjectModel.resultSet.sizeCategory: #XS
define view Z_I_VendorType   as select from zpurchvendortyp
{

      @ObjectModel.text.element: ['VendorTypeText']
      @EndUserText.label: 'Vendor Type'
  key vendortype     as VendorType,

      @Semantics.text: true
      @EndUserText.label: 'Vendor Type Text'
      vendortypetext as VendorTypeText
}
