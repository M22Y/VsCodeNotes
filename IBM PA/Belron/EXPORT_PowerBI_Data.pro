
#****Begin: Generated Statements***
#****End: Generated Statements****

########################################################################
########################################################################
## DESCRIPTION
#
#  Export data from Cubes 86, 65, 67, 68, 85 for Scenario / Year specified
#
#
#
## PARAMETRES
#       pDebug          0 aucun debug 4 niveau de debug passe aux autres processus.
#       pYear           Year to export (current Year) and will also take PrevYr = This year - 1.
#       pScenario       Scenario to export.
#
#
## HISTORIQUE
#
# 2022-01-10 Claude-Sebastien JEAN   Creation
# 2022-01-19 Claude-Sebastien JEAN   Added 65_DailySales_Stats
# 2022-01-24 Claude-Sebastien JEAN   Added GL list + Actuals with PrevYr
# 2022-02-03 Claude-Sebastien JEAN   Modified 85 and 86
# 2022-02-15 Claude-Sebastien JEAN   Modified 65  and 67 to add measures.
# 2023-07-22 Claude-Sebastien JEAN   Added Cube 64
# 
# July  2023      Youssef M - RCGT           Updated for migration
# April 2024      Youssef M - RCGT           Added Cube 08 & staring Year for Export instead of N-2
#
#
########################################################################
########################################################################


cProcess = GetProcessName() ;
cTimeStamp = TimSt( Now, '\Y\m\d\h\i\s' );
cDebugFile = GetProcessErrorFileDirectory | cProcess | '.' | cTimeStamp | '.';
# Set debug file name
sDebugFile = cDebugFile | '_01Prolog.debug';

##
## Determine DATA Dir
# rest = GetProcessErrorFileDirectory;
# prev = '';
# pah = '';
# cur = SUBST(rest,1, SCAN('\', rest) );
# rest = SUBST(rest, SCAN('\', rest)+1, LONG(rest)-LONG(cur));
# path = path | cur;
# #DEBUG LOG
# IF( pDebug >= 1 );AsciiOutput( sDebugFile, TIMST(NOW, '\Y-\m-\d \h:\i:\s', 1), 'rest = ' | rest | ' prev = ' | prev | ' path =  ' | path  | ' cur = ' | cur);ENDIF;
# WHILE(cur @<> '');
#
#
#     cur = SUBST(rest,1, SCAN('\', rest) );
#     IF(cur @<> '');
#         prev = path;
#     ENDIF;
#     rest = SUBST(rest, SCAN('\', rest)+1, LONG(rest)-LONG(cur));
#     path = path | cur;
#
#     IF( pDebug >= 1 );AsciiOutput( sDebugFile, TIMST(NOW, '\Y-\m-\d \h:\i:\s', 1), 'rest = ' | rest | ' prev = ' | prev | ' path =  ' | path  | ' cur = ' | cur);ENDIF;
# END;
#
# cDataDir = prev;



cLF = Char ( 10 );

If( pDebug >= 1 );

  # Log start time
  AsciiOutput( sDebugFile, 'Process Started: ' |TIMST(NOW, '\Y-\m-\d \h:\i:\s', 1) );

EndIf;

##-----------------------------------------------------------------------------------------------
## CREATE Directory
##-----------------------------------------------------------------------------------------------
#sDirectory = 'D:\TM1Data\Finances\Export_BI\PowerBI';
#scmd = 'cmd /C "mkdir ' | sDirectory | '"';
##ExecuteCommand(scmd, 1);


# Migration to cloud
##sDirectory = 'D:\TM1Data\Finances\Export_BI\PowerBI';
sDirectory = '..\SourceFiles\Export_BI\PowerBI';
scmd = 'cmd /C "mkdir ' | sDirectory | '"';
ExecuteCommand(scmd, 1);

##-----------------------------------------------------------------------------------------------
## VARIABLES
##-----------------------------------------------------------------------------------------------
sSep = ';';

##-------------------------------------------------------------------------------------------
## Check Parameters
##-------------------------------------------------------------------------------------------
dimyear = 't_Years';
dimsce = 'Versions';

#############
## Year
#############
IF (DIMIX(dimyear, pYear) = 0);
    errmes = '## ERROR: "' | pYear | '" does not exist in the ' | dimyear | ' dimension!';
    #DEBUG LOG
    AsciiOutput( sDebugFile, TIMST(NOW, '\Y-\m-\d \h:\i:\s', 1), errmes);
    LogOutput( 'ERROR',  errmes);
    ProcessError;
ENDIF;

IF (DIMIX(dimyear, pStartYear) = 0 & pStartYear @<> '');
    errmes = '## ERROR: "' | pStartYear | '" does not exist in the ' | dimyear | ' dimension!';
    #DEBUG LOG
    AsciiOutput( sDebugFile, TIMST(NOW, '\Y-\m-\d \h:\i:\s', 1), errmes);
    LogOutput( 'ERROR',  errmes);
    ProcessError;
ENDIF;
# Check pYear is Bigger than pStartYear
#IF (StringToNumber(pStartYear) > StringToNumber(pYear) );
#    errmes = '## ERROR: "' | pStartYear | '" does not exist in the ' | dimyear | ' dimension!';
#    #DEBUG LOG
#    AsciiOutput( sDebugFile, TIMST(NOW, '\Y-\m-\d \h:\i:\s', 1), errmes);
#    LogOutput( 'ERROR',  errmes);
#    ProcessError;
#ENDIF;


# build t_Year Dimension
sPrevYear = ATTRS( dimyear, pYear, 'Prev_Yr' );
sYear = pYear;
IF(UPPER(pScenario) @= 'ACTUAL' & StringToNumber(pStartYear) < StringToNumber(pYear) );
    While (sPrevYear @<> pStartYear);
        sYear = sYear | ' + ' | sPrevYear;
        sPrevYear = ATTRS( dimyear, sPrevYear, 'Prev_Yr' );
    END;
    # Last Year to be added
    sYear = sYear | ' + ' | pStartYear;
ELSE;
    sYear = pYear;
ENDIF;


#############
## Scenario
#############

IF (DIMIX(dimsce, pScenario) = 0);
    errmes = '## ERROR: "' | pScenario | '" does not exist in the ' | dimsce | ' dimension!';
    #DEBUG LOG
    AsciiOutput( sDebugFile, TIMST(NOW,'\Y-\m-\d \h:\i:\s', 1), errmes);
    LogOutput( 'ERROR',  errmes);
    ProcessError;
ENDIF;




dimcubes = '}cubes';

#subset name
sSubsetcubes = cProcess;

#Delete subset if it already exists.
IF (SubsetExists(dimcubes, sSubsetcubes) = 1);
    SubsetDestroy(dimcubes, sSubsetcubes);
ENDIF;

#Create subset.
SubsetCreate(dimcubes, sSubsetcubes);
# SubsetElementInsert(dimcubes, sSubsetcubes, '38_Manning_Actuals', 0);
SubsetElementInsert(dimcubes, sSubsetcubes, '86_ETL_GL', 0);
SubsetElementInsert(dimcubes, sSubsetcubes, '85_ETL_Stats', 0);
SubsetElementInsert(dimcubes, sSubsetcubes, '68_DailySales_GL_Std', 0);
SubsetElementInsert(dimcubes, sSubsetcubes, '67_DailySales_Stats_Std', 0);
SubsetElementInsert(dimcubes, sSubsetcubes, '65_DailySales_Stats', 0);
SubsetElementInsert(dimcubes, sSubsetcubes, '64_DailySales_Stats_Franchises', 0);
#SubsetElementInsert(dimcubes, sSubsetcubes, '111_SalesCOS_ADAS', 0);
SubsetElementInsert(dimcubes, sSubsetcubes, '08_SalesCOS_B2B_WH_by_Customer', 0);



dimgl = 'GL_Accounts';

#subset name
sSubsetgl = 'TEMPEXPORT_' | cProcess;

#Delete subset if it already exists.
IF (SubsetExists(dimgl, sSubsetgl) = 1);
    # SubsetDestroy(dimgl, sSubsetgl);
    SubsetDeleteAllElements(dimgl, sSubsetgl);
ELSE;
    #Create subset.
    SubsetCreate(dimgl, sSubsetgl);
ENDIF;


# SubsetElementInsert(dimcubes, sSubsetcubes, '38_Manning_Actuals', 0);

SubsetElementInsert(dimgl, sSubsetgl, '000120', 0);
SubsetElementInsert(dimgl, sSubsetgl, '000130', 0);
SubsetElementInsert(dimgl, sSubsetgl, '000140', 0);
SubsetElementInsert(dimgl, sSubsetgl, '000142', 0);
SubsetElementInsert(dimgl, sSubsetgl, '000144', 0);
SubsetElementInsert(dimgl, sSubsetgl, '000145', 0);
SubsetElementInsert(dimgl, sSubsetgl, '000150', 0);
SubsetElementInsert(dimgl, sSubsetgl, '000160', 0);
SubsetElementInsert(dimgl, sSubsetgl, '000110', 0);
SubsetElementInsert(dimgl, sSubsetgl, '000179', 0);
SubsetElementInsert(dimgl, sSubsetgl, '000195', 0);
SubsetElementInsert(dimgl, sSubsetgl, '000210', 0);
SubsetElementInsert(dimgl, sSubsetgl, '000230', 0);
SubsetElementInsert(dimgl, sSubsetgl, '000235', 0);
SubsetElementInsert(dimgl, sSubsetgl, '000236', 0);
SubsetElementInsert(dimgl, sSubsetgl, '000240', 0);
SubsetElementInsert(dimgl, sSubsetgl, '000244', 0);
SubsetElementInsert(dimgl, sSubsetgl, '000199', 0);
SubsetElementInsert(dimgl, sSubsetgl, '000225', 0);
SubsetElementInsert(dimgl, sSubsetgl, '000255', 0);
SubsetElementInsert(dimgl, sSubsetgl, '000273', 0);
SubsetElementInsert(dimgl, sSubsetgl, '000274', 0);
SubsetElementInsert(dimgl, sSubsetgl, '000276', 0);
SubsetElementInsert(dimgl, sSubsetgl, '000279', 0);
SubsetElementInsert(dimgl, sSubsetgl, '000280', 0);
SubsetElementInsert(dimgl, sSubsetgl, '000266', 0);
SubsetElementInsert(dimgl, sSubsetgl, '000267', 0);
SubsetElementInsert(dimgl, sSubsetgl, '000268', 0);
SubsetElementInsert(dimgl, sSubsetgl, '000269', 0);
SubsetElementInsert(dimgl, sSubsetgl, '000300', 0);
SubsetElementInsert(dimgl, sSubsetgl, '008106', 0);
SubsetElementInsert(dimgl, sSubsetgl, '008110', 0);
SubsetElementInsert(dimgl, sSubsetgl, '008179', 0);
SubsetElementInsert(dimgl, sSubsetgl, '008195', 0);
SubsetElementInsert(dimgl, sSubsetgl, '008210', 0);
SubsetElementInsert(dimgl, sSubsetgl, '008230', 0);
SubsetElementInsert(dimgl, sSubsetgl, '008235', 0);
SubsetElementInsert(dimgl, sSubsetgl, '008236', 0);
SubsetElementInsert(dimgl, sSubsetgl, '008240', 0);
SubsetElementInsert(dimgl, sSubsetgl, '008244', 0);
SubsetElementInsert(dimgl, sSubsetgl, '008225', 0);
SubsetElementInsert(dimgl, sSubsetgl, '008255', 0);
SubsetElementInsert(dimgl, sSubsetgl, '008273', 0);
SubsetElementInsert(dimgl, sSubsetgl, '008274', 0);
SubsetElementInsert(dimgl, sSubsetgl, '008276', 0);
SubsetElementInsert(dimgl, sSubsetgl, '008279', 0);
SubsetElementInsert(dimgl, sSubsetgl, '008299', 0);
SubsetElementInsert(dimgl, sSubsetgl, '008280', 0);
SubsetElementInsert(dimgl, sSubsetgl, '008295', 0);
SubsetElementInsert(dimgl, sSubsetgl, '008296', 0);
SubsetElementInsert(dimgl, sSubsetgl, '008297', 0);
SubsetElementInsert(dimgl, sSubsetgl, '008298', 0);
SubsetElementInsert(dimgl, sSubsetgl, '008265', 0);
SubsetElementInsert(dimgl, sSubsetgl, '008300', 0);
SubsetElementInsert(dimgl, sSubsetgl, '010000', 0);
SubsetElementInsert(dimgl, sSubsetgl, '011300', 0);
SubsetElementInsert(dimgl, sSubsetgl, '011460', 0);
SubsetElementInsert(dimgl, sSubsetgl, '019000', 0);
SubsetElementInsert(dimgl, sSubsetgl, '020000', 0);
SubsetElementInsert(dimgl, sSubsetgl, '020040', 0);
SubsetElementInsert(dimgl, sSubsetgl, '020050', 0);
SubsetElementInsert(dimgl, sSubsetgl, '020100', 0);
SubsetElementInsert(dimgl, sSubsetgl, '020110', 0);
SubsetElementInsert(dimgl, sSubsetgl, '020200', 0);
SubsetElementInsert(dimgl, sSubsetgl, '020300', 0);
SubsetElementInsert(dimgl, sSubsetgl, '020400', 0);
SubsetElementInsert(dimgl, sSubsetgl, '020401', 0);
SubsetElementInsert(dimgl, sSubsetgl, '020500', 0);
SubsetElementInsert(dimgl, sSubsetgl, '020600', 0);
SubsetElementInsert(dimgl, sSubsetgl, '020700', 0);
SubsetElementInsert(dimgl, sSubsetgl, '020800', 0);
SubsetElementInsert(dimgl, sSubsetgl, '020900', 0);
SubsetElementInsert(dimgl, sSubsetgl, '021000', 0);
SubsetElementInsert(dimgl, sSubsetgl, '021100', 0);
SubsetElementInsert(dimgl, sSubsetgl, '021200', 0);
SubsetElementInsert(dimgl, sSubsetgl, '021300', 0);
SubsetElementInsert(dimgl, sSubsetgl, '021400', 0);
SubsetElementInsert(dimgl, sSubsetgl, '021500', 0);
SubsetElementInsert(dimgl, sSubsetgl, '021600', 0);
SubsetElementInsert(dimgl, sSubsetgl, '022250', 0);
SubsetElementInsert(dimgl, sSubsetgl, '025000', 0);
SubsetElementInsert(dimgl, sSubsetgl, '040001', 0);
SubsetElementInsert(dimgl, sSubsetgl, '040005', 0);
SubsetElementInsert(dimgl, sSubsetgl, '041400', 0);
SubsetElementInsert(dimgl, sSubsetgl, '043001', 0);
SubsetElementInsert(dimgl, sSubsetgl, '044900', 0);
SubsetElementInsert(dimgl, sSubsetgl, '045300', 0);
SubsetElementInsert(dimgl, sSubsetgl, '050180', 0);
SubsetElementInsert(dimgl, sSubsetgl, '051300', 0);
SubsetElementInsert(dimgl, sSubsetgl, '051500', 0);
SubsetElementInsert(dimgl, sSubsetgl, '051605', 0);
SubsetElementInsert(dimgl, sSubsetgl, '051665', 0);
SubsetElementInsert(dimgl, sSubsetgl, '051700', 0);
SubsetElementInsert(dimgl, sSubsetgl, '011006', 0);
SubsetElementInsert(dimgl, sSubsetgl, '011008', 0);
SubsetElementInsert(dimgl, sSubsetgl, '043640', 0);
SubsetElementInsert(dimgl, sSubsetgl, '043720', 0);
SubsetElementInsert(dimgl, sSubsetgl, '043730', 0);
SubsetElementInsert(dimgl, sSubsetgl, '043890', 0);
SubsetElementInsert(dimgl, sSubsetgl, '043850', 0);
SubsetElementInsert(dimgl, sSubsetgl, '043940', 0);
SubsetElementInsert(dimgl, sSubsetgl, '051691', 0);
SubsetElementInsert(dimgl, sSubsetgl, '051702', 0);
SubsetElementInsert(dimgl, sSubsetgl, '051712', 0);
SubsetElementInsert(dimgl, sSubsetgl, '051732', 0);
SubsetElementInsert(dimgl, sSubsetgl, '051740', 0);


#loop through all elements.
nmaxcubes = SubsetGetSize(dimcubes, sSubsetcubes);
ncubes = nmaxcubes;
WHILE(ncubes >= 1);
    #element.
    elcubes = SubsetGetElementName(dimcubes, sSubsetcubes, ncubes);

    #Loop through every subset element.

    ##-----------------------------------------------------------------------------------------------
    ## EXPORT CUBEs
    ##-----------------------------------------------------------------------------------------------
    fname = elcubes | '_' | pScenario | '.txt';

    #DEBUG LOG
    IF( pDebug >= 1 );AsciiOutput( sDebugFile, TIMST(NOW, '\Y-\m-\d \h:\i:\s', 1), 'EXPORTING: ' | fname | ' for ' | elcubes | ' - ' | pScenario | ' - ' | pYear);ENDIF;

    sViewNameSource  = 'Export_' | pScenario | '_' | pYear;

    ExecuteProcess( 'SYS_View_Destroy',
                'pCubeName', elcubes,
                'pViewName', sViewNameSource);

    sMDX_OrgStruct_Ret = '{TM1FILTERBYLEVEL({TM1DRILLDOWNMEMBER({[Org_Structure].[RE_SERETAIL]}, ALL, RECURSIVE)}, 0)}';
    sMDX_OrgStruct_Conso = '{TM1FILTERBYLEVEL({TM1DRILLDOWNMEMBER({[Org_Structure].[RE CO CONSOLIDATED]}, ALL, RECURSIVE)}, 0)}';

    sProd = 'Windshield + Side + Back + RV_Glass + Bus_Glass + Kits_Retail + Sales_Discounts + Deductibles + Repairs';
    sCustSeg = 'Insurance + Cash + Trade + Fleet + No_Segment + Interne + APPLE_FR + LEBEAU_FR + DURO_FR + STD_FR + NOVUS_FR + ISP + Commercial_EXT + Other_EXT + Grossiste + No_Segment_EXT + Franchise_Customer';
    sGL = '000120 + 000130 + 000140 + 000142 + 000144 + 000145 + 000150 + 000160 + 000110 + 000179 + 000195 + 000210 + 000230 + 000235 + 000236 + 000240 + 000244 + 000270 + 000280 + 000266 + 000267 + 000268 + 000269 + 000300 + 4245 + 3248 + 3848 + 000276';


    ## Specifics for cube 08

    sProd_08 = 'Replacement + Repairs';
    sCustSeg_08 = 'B2B';
    sCustFleet_08 = 'COURRIER + DAILY RENTAL + FLEET CARD + NATIONAL + OTHER_FLEET + REGIONAL + BodyShop + New_Car_Dealer + OTHER_TRADE + Used_Car_Dealer';
    
    
    ##------------------------------------------------------
    ## If we demand an ACTUAL scenario, Loop all the way back to starting year --- moved to Top of Prolog
    ##------------------------------------------------------
    # build t_Year Dimension
    #sPrevYear = ATTRS( dimyear, pYear, 'Prev_Yr' );
    #IF(UPPER(pScenario) @= 'ACTUAL' & StringToNumber(pStartYear) < StringToNumber(pYear) );
    # 
    #    sYear = pYear | ' + ' | sPrevYear;
    #ELSE;
    #    sYear = pYear;
    #ENDIF;


    # Export views 
    LogOutput( 'INFO', 'Exporting cube ' | elcubes);
    IF(elcubes @= '08_SalesCOS_B2B_WH_by_Customer');
        nSkipCalc = 0;
        ExecuteProcess( 'SYS_View_Create',
                    'pCubeName', elcubes,
                    'pViewName', sViewNameSource,
                    # pAction : Source / ViewZeroOut
                    'pAction', 'Source',
                    #	Possible options for pDimX are:
                    #
                    #	[1]  %  = Specific Element Name (ex: '%TOT_Company'  or  %Feb+March+Sept+Q1 )
                    #	[2]  #  = Only elements at level <n> are included (ex: '#0' for all leaves)
                    #	[3]  *  = All elements in the dimension (ex: '*' )
                    #	[4]  !  = Get leaf elements on the specified consolidated element (ex: '!YTD_06')
                    #	[5]  &  = Use a predefined MDX (ex: '&Except({DrillDownLevel({[Finstm...')
                    #	[6]  ]  = Use an existing Subset (ex: ]SYS_i_am_a_subset)
                    'pDim1', 'Versions:%' | pScenario,
                    'pDim2', 't_Years:%' | sYear,
                    'pDim3', 'Products_Detailed:%' | sProd_08,
                    'pDim4', 'Org_Structure:&' | sMDX_OrgStruct_Ret,
                    'pDim4', 'Customer_Segments:%' | sCustSeg_08,
                    'pDim4', 'Customer_Fleet_Wholesale:%' | sCustFleet_08,
                    'pDim5', 'm_SalesCOS:%Total_Units + Net_Sales',
                    'pSuppressZeroes', 1,
                    'pSuppressZeroesColumns', 0,
                    'pSuppressZeroesRows', 0,
                    'pSkipCalc', nSkipCalc,
                    'pSkipRule', 0,
                    'pDefaultElement', '#0');
        
    ELSEIF(elcubes @= '67_DailySales_Stats_Std');
        nSkipCalc = 0;
        ExecuteProcess( 'SYS_View_Create',
                    'pCubeName', elcubes,
                    'pViewName', sViewNameSource,
                    # pAction : Source / ViewZeroOut
                    'pAction', 'Source',
                    #	Possible options for pDimX are:
                    #
                    #	[1]  %  = Specific Element Name (ex: '%TOT_Company'  or  %Feb+March+Sept+Q1 )
                    #	[2]  #  = Only elements at level <n> are included (ex: '#0' for all leaves)
                    #	[3]  *  = All elements in the dimension (ex: '*' )
                    #	[4]  !  = Get leaf elements on the specified consolidated element (ex: '!YTD_06')
                    #	[5]  &  = Use a predefined MDX (ex: '&Except({DrillDownLevel({[Finstm...')
                    #	[6]  ]  = Use an existing Subset (ex: ]SYS_i_am_a_subset)
                    'pDim1', 'Versions:%' | pScenario,
                    'pDim2', 't_Years:%' | sYear,
                    'pDim3', 'Products_Detailed:%' | sProd,
                    'pDim4', 'Org_Structure:&' | sMDX_OrgStruct_Conso,
                    'pDim5', 'm_ETL_Stats_Daily_Std:%Sales_Units_All_Year + Sales$ + Sales$_Gross_All_Year',
                    'pSuppressZeroes', 1,
                    'pSuppressZeroesColumns', 0,
                    'pSuppressZeroesRows', 0,
                    'pSkipCalc', nSkipCalc,
                    'pSkipRule', 0,
                    'pDefaultElement', '#0');

    ELSEIF(elcubes @= '85_ETL_Stats');
        nSkipCalc = 0;
        ExecuteProcess( 'SYS_View_Create',
                    'pCubeName', elcubes,
                    'pViewName', sViewNameSource,
                    # pAction : Source / ViewZeroOut
                    'pAction', 'Source',
                    #	Possible options for pDimX are:
                    #
                    #	[1]  %  = Specific Element Name (ex: '%TOT_Company'  or  %Feb+March+Sept+Q1 )
                    #	[2]  #  = Only elements at level <n> are included (ex: '#0' for all leaves)
                    #	[3]  *  = All elements in the dimension (ex: '*' )
                    #	[4]  !  = Get leaf elements on the specified consolidated element (ex: '!YTD_06')
                    #	[5]  &  = Use a predefined MDX (ex: '&Except({DrillDownLevel({[Finstm...')
                    #	[6]  ]  = Use an existing Subset (ex: ]SYS_i_am_a_subset)
                    'pDim1', 'Versions:%' | pScenario,
                    'pDim2', 't_Years:%' | sYear,
                    'pDim3', 'Products_Detailed:%' | sProd,
                    'pDim4', 'Org_Structure:&' | sMDX_OrgStruct_Ret,
                    'pDim5', 'Customer_Segments:%' | sCustSeg,
                    'pDim6', 'm_ETL_Stats:%Mobile_Units + Sales_Units + Sales$',
                    'pSuppressZeroes', 1,
                    'pSuppressZeroesColumns', 0,
                    'pSuppressZeroesRows', 0,
                    'pSkipCalc', nSkipCalc,
                    'pSkipRule', 0,
                    'pDefaultElement', '#0');

    ELSEIF(elcubes @= '65_DailySales_Stats');
        nSkipCalc = 0;
        ExecuteProcess( 'SYS_View_Create',
                    'pCubeName', elcubes,
                    'pViewName', sViewNameSource,
                    # pAction : Source / ViewZeroOut
                    'pAction', 'Source',
                    #	Possible options for pDimX are:
                    #
                    #	[1]  %  = Specific Element Name (ex: '%TOT_Company'  or  %Feb+March+Sept+Q1 )
                    #	[2]  #  = Only elements at level <n> are included (ex: '#0' for all leaves)
                    #	[3]  *  = All elements in the dimension (ex: '*' )
                    #	[4]  !  = Get leaf elements on the specified consolidated element (ex: '!YTD_06')
                    #	[5]  &  = Use a predefined MDX (ex: '&Except({DrillDownLevel({[Finstm...')
                    #	[6]  ]  = Use an existing Subset (ex: ]SYS_i_am_a_subset)
                    'pDim1', 'Versions:%' | pScenario,
                    'pDim2', 't_Years:%' | sYear,
                    'pDim3', 'Products_Detailed:%' | sProd,
                    'pDim4', 'Org_Structure:&' | sMDX_OrgStruct_Ret,
                    'pDim5', 'm_ETL_Stats:%Mobile_Units + Mobile$ + Sales_Units + Sales$',
                    'pSuppressZeroes', 1,
                    'pSuppressZeroesColumns', 0,
                    'pSuppressZeroesRows', 0,
                    'pSkipCalc', nSkipCalc,
                    'pSkipRule', 0,
                    'pDefaultElement', '#0');

    ELSEIF(elcubes @= '68_DailySales_GL_Std');
        nSkipCalc = 0;
        ExecuteProcess( 'SYS_View_Create',
                    'pCubeName', elcubes,
                    'pViewName', sViewNameSource,
                    # pAction : Source / ViewZeroOut
                    'pAction', 'Source',
                    #	Possible options for pDimX are:
                    #
                    #	[1]  %  = Specific Element Name (ex: '%TOT_Company'  or  %Feb+March+Sept+Q1 )
                    #	[2]  #  = Only elements at level <n> are included (ex: '#0' for all leaves)
                    #	[3]  *  = All elements in the dimension (ex: '*' )
                    #	[4]  !  = Get leaf elements on the specified consolidated element (ex: '!YTD_06')
                    #	[5]  &  = Use a predefined MDX (ex: '&Except({DrillDownLevel({[Finstm...')
                    #	[6]  ]  = Use an existing Subset (ex: ]SYS_i_am_a_subset)
                    'pDim1', 'Versions:%' | pScenario,
                    'pDim2', 't_Years:%' | sYear,
                    'pDim3', 'GL_Accounts:%' | sGL,
                    'pDim4', 'm_ETL_GL_Daily_Std:%Dollars$_All_Year',
                    'pSuppressZeroes', 1,
                    'pSuppressZeroesColumns', 0,
                    'pSuppressZeroesRows', 0,
                    'pSkipCalc', nSkipCalc,
                    'pSkipRule', 0,
                    'pDefaultElement', '#0');

    ELSEIF(elcubes @= '86_ETL_GL');
        nSkipCalc = 0;
        ExecuteProcess( 'SYS_View_Create',
                    'pCubeName', elcubes,
                    'pViewName', sViewNameSource,
                    # pAction : Source / ViewZeroOut
                    'pAction', 'Source',
                    #	Possible options for pDimX are:
                    #
                    #	[1]  %  = Specific Element Name (ex: '%TOT_Company'  or  %Feb+March+Sept+Q1 )
                    #	[2]  #  = Only elements at level <n> are included (ex: '#0' for all leaves)
                    #	[3]  *  = All elements in the dimension (ex: '*' )
                    #	[4]  !  = Get leaf elements on the specified consolidated element (ex: '!YTD_06')
                    #	[5]  &  = Use a predefined MDX (ex: '&Except({DrillDownLevel({[Finstm...')
                    #	[6]  ]  = Use an existing Subset (ex: ]SYS_i_am_a_subset)
                    'pDim1', 'Versions:%' | pScenario,
                    'pDim2', 't_Years:%' | sYear,
                    'pDim3', 'GL_Accounts:]' | sSubsetgl,
                    'pDim4', 'Org_Structure:&' | sMDX_OrgStruct_Conso,
                    'pSuppressZeroes', 1,
                    'pSuppressZeroesColumns', 0,
                    'pSuppressZeroesRows', 0,
                    'pSkipCalc', nSkipCalc,
                    'pSkipRule', 0,
                    'pDefaultElement', '#0');

    ELSEIF(elcubes @= '64_DailySales_Stats_Franchises');
        nSkipCalc = 0;
        ExecuteProcess( 'SYS_View_Create',
                    'pCubeName', elcubes,
                    'pViewName', sViewNameSource,
                    # pAction : Source / ViewZeroOut
                    'pAction', 'Source',
                    #	Possible options for pDimX are:
                    #
                    #	[1]  %  = Specific Element Name (ex: '%TOT_Company'  or  %Feb+March+Sept+Q1 )
                    #	[2]  #  = Only elements at level <n> are included (ex: '#0' for all leaves)
                    #	[3]  *  = All elements in the dimension (ex: '*' )
                    #	[4]  !  = Get leaf elements on the specified consolidated element (ex: '!YTD_06')
                    #	[5]  &  = Use a predefined MDX (ex: '&Except({DrillDownLevel({[Finstm...')
                    #	[6]  ]  = Use an existing Subset (ex: ]SYS_i_am_a_subset)
                    'pDim1', 'Versions:%' | pScenario,
                    'pDim2', 't_Years:%' | sYear,
                    'pDim3', 'Products_Detailed_Franchises:%Windshield + Side + Back + RV_Glass + Bus_Glass + Kits_Retail + Sales_Discounts + Deductibles + Repairs',
                    'pDim4', 'm_ETL_Stats_Daily_Std:% Sales_Units + Sales$',
                    'pSuppressZeroes', 1,
                    'pSuppressZeroesColumns', 0,
                    'pSuppressZeroesRows', 0,
                    'pSkipCalc', nSkipCalc,
                    'pSkipRule', 0,
                    'pDefaultElement', '#0');




    ELSE;
        nSkipCalc = 1;
        ExecuteProcess( 'SYS_View_Create',
                    'pCubeName', elcubes,
                    'pViewName', sViewNameSource,
                    # pAction : Source / ViewZeroOut
                    'pAction', 'Source',
                    #	Possible options for pDimX are:
                    #
                    #	[1]  %  = Specific Element Name (ex: '%TOT_Company'  or  %Feb+March+Sept+Q1 )
                    #	[2]  #  = Only elements at level <n> are included (ex: '#0' for all leaves)
                    #	[3]  *  = All elements in the dimension (ex: '*' )
                    #	[4]  !  = Get leaf elements on the specified consolidated element (ex: '!YTD_06')
                    #	[5]  &  = Use a predefined MDX (ex: '&Except({DrillDownLevel({[Finstm...')
                    #	[6]  ]  = Use an existing Subset (ex: ]SYS_i_am_a_subset)
                    'pDim1', 'Versions:%' | pScenario,
                    'pDim2', 't_Years:%' | sYear,
                    'pSuppressZeroes', 1,
                    'pSuppressZeroesColumns', 0,
                    'pSuppressZeroesRows', 0,
                    'pSkipCalc', nSkipCalc,
                    'pSkipRule', 0);
    ENDIF;

    LogOutput( 'INFO', 'Exporting cube ' | elcubes | ' for ' | pScenario | ' / ' | sYear | ' to ' | sDirectory | '\' | fname);
    ExecuteProcess('Bedrock.Cube.Data.ViewExportToFile'
        , 'pCube', elcubes
        , 'pView', sViewNameSource
        , 'pExportPath', sDirectory
        , 'pExportFile', fname
        , 'pSkipRuleValues', 0
        , 'pSkipCalcValues', nSkipCalc
        , 'pSkipNullValues', 1
        , 'pTitleRecord', 1
        );

    ExecuteProcess( 'SYS_View_Destroy', 'pCubeName', elcubes, 'pViewName', sViewNameSource);

    #next element.
    ncubes = ncubes - 1;
END;


#Delete subset if it already exists.
IF (SubsetExists(dimgl, sSubsetgl) = 1);
    SubsetDestroy(dimgl, sSubsetgl);
ENDIF;
IF( pDebug >= 1 );AsciiOutput( sDebugFile, TIMST(NOW, '\Y-\m-\d \h:\i:\s', 1), 'PROCESS END');ENDIF;


