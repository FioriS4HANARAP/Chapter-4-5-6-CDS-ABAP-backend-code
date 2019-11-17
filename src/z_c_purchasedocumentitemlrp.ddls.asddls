@EndUserText.label: 'Purchase Document'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Search.searchable: true
@Metadata.allowExtensions:true
@VDM.viewType: #CONSUMPTION

define view entity Z_C_PurchaseDocumentItemLrp
   as projection on Z_I_PurchaseDocumentItem_U
{
      @EndUserText.label: 'Purchase Document Item'
      @Search: {defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.8}
  key PurchaseDocumentItem,
      @ObjectModel.foreignKey.association: '_PurchaseDocument'
      @EndUserText.label: 'Purchase Document'
  key PurchaseDocument,
      @EndUserText.label: 'Price'
      Price,
      @EndUserText.label: 'Quantity'
      Quantity,
      @EndUserText.label: 'Overall Item Price'
      OverallItemPrice,
      @Search: {defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.8}
      @EndUserText.label: 'Vendor Name'
      Vendor,
      @EndUserText.label: 'Vendor Type'
      @Consumption.valueHelpDefinition: [{entity:{name:'Z_C_VendorTypeVH' , element: 'VendorType'}}]
      VendorType,      
      @Search: {defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.8}
      @EndUserText.label: 'Item Description'
      Description,     
      @Consumption.valueHelpDefinition: [{entity:{name:'I_Currency' , element: 'Currency'}}]
      Currency,
      @Consumption.valueHelpDefinition: [{entity:{name:'I_UnitOfMeasure' , element: 'UnitOfMeasure'}}]
      QuantityUnit,
      @EndUserText.label: 'Image'
      @Consumption.filter.hidden: true
      PurchaseDocumentItemImageURL,
      @ObjectModel.virtualElement: true
      @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VENDOR_RATING_CALC_EXIT'
      virtual VendorRating :abap.int1 ( 0  ),     
      @EndUserText.label: 'Created at'
      crea_date_time,
      @EndUserText.label: 'Created by'
      crea_uname,
      @EndUserText.label: 'Last changed at'
      lchg_date_time,
      @EndUserText.label: 'Last changed by'
      lchg_uname,
      /* Associations */
      _PurchaseDocument  : redirected to parent Z_C_PurchaseDocumentLrp,
      _QuantityUnitOfMeasure,
      _VendorType

}


