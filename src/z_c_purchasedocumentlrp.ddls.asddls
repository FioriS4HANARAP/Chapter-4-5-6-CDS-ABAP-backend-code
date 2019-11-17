@EndUserText.label: 'Purchase Document'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Search.searchable: true
@Metadata.allowExtensions:true
@VDM.viewType: #CONSUMPTION

define root view entity Z_C_PurchaseDocumentLrp
  as projection on Z_I_PurchaseDocument_U

{
      @EndUserText.label: 'Purchase Document'
      @Consumption.semanticObject: 'PurchasingDocument'
  key PurchaseDocument,
      @EndUserText.label: 'Overall Price'
      OverallPrice,
      @EndUserText.label: 'Approval Required'
      @ObjectModel.foreignKey.association: '_IsApprovalRequired'
      @Consumption.valueHelpDefinition: [{entity:{name:'I_Indicator' , element: 'IndicatorValue'}}]
      IsApprovalRequired,
      OverallPriceCriticality,
      @EndUserText.label: 'Status'
      @Consumption.valueHelpDefinition: [{entity:{name:'Z_C_StatusVH' , element: 'Status'}}]
      Status,
      @EndUserText.label: 'Priority'
      @Consumption.valueHelpDefinition: [{entity:{name:'Z_C_PriorityVH' , element: 'Priority'}}]
      Priority,
      @Search.defaultSearchElement : true
      @Search.fuzzinessThreshold : 0.8
      @Semantics.text: true
      @EndUserText.label: 'Description'
      Description,
      @EndUserText.label: 'Purchasing Organization'
      @Consumption.valueHelpDefinition: [{entity:{name:'Z_I_PurchasingOrganization' , element: 'PurchasingOrganization'}}]
      PurchasingOrganization,
      @EndUserText.label: 'Currency'
      Currency,
      @EndUserText.label: 'Created at'
      @Consumption.filter.hidden: true
      crea_date_time,
      @EndUserText.label: 'Created by'
      crea_uname,
      @EndUserText.label: 'Last changed at'
      @Consumption.filter.hidden: true
      lchg_date_time,
      @EndUserText.label: 'Last changed by'
      lchg_uname,
      @EndUserText.label: 'Image'
      @Consumption.filter.hidden: true
      PurchaseDocumentImageURL,


      /* Associations */
      _PurchaseDocumentItem : redirected to composition child Z_C_PurchaseDocumentItemLrp,
      _Currency,
      _IsApprovalRequired,
      _Priority,   
      _Status,
      _PurchasingOrganization 
}
