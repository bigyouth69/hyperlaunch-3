MCRC=33D035F2
mVersion=1.0.2

;Author: bleasby
;This file contains all functions and labels related with the HyperLaunch Statistics Saving


;-----------------STATISTICS FUNCTIONS------------

UpdateStatistics:
    log("Starting Updating Statistics:", 1)
    TotalElapsedTimeinPause += 0
    log("Total Elapsed Time in Pause in seconds: " TotalElapsedTimeinPause,5)
    ElapsedTime := ( A_TickCount - gameSectionStartTime ) // 1000
    log("gameSectionStartTime:" gameSectionStartTime, 5)
    ElapsedTime := if TotalElapsedTimeinPause ? ElapsedTime - TotalElapsedTimeinPause : ElapsedTime 
    log("ElapsedTime:" ElapsedTime, 5)
    gameStatisticsPath := HLDataPath . "\Statistics\"
    IfNotExist, %gameStatisticsPath%
        FileCreateDir, %gameStatisticsPath%
    HyperPause_StatisticsFile := gameStatisticsPath . systemName . ".ini" 
    HyperPause_GlobalStatisticsFile := gameStatisticsPath . "Global Statistics.ini"
    ;Load ini file previous statistics 
    if !statisticsLoaded
        gosub, LoadStatistics
    log("Loaded game statistics from ini files:`r`n`t`t`t`t`tNumber_of_Times_Played: " Initial_General_Statistics_Statistic_1 "`r`n`t`t`t`t`tLast_Time_Played: " Initial_General_Statistics_Statistic_2 "`r`n`t`t`t`t`tAverage_Time_Played: " Initial_General_Statistics_Statistic_3 "`r`n`t`t`t`t`tTotal_Time_Played: " Initial_General_Statistics_Statistic_4 "`r`n`t`t`t`t`tSystem_Total_Played_Time: " Initial_General_Statistics_Statistic_5 "`r`n`t`t`t`t`tTotal_Global_Played_Time: " Initial_General_Statistics_Statistic_6, 5)
    ;Updating final statistics values
    Final_General_Statistics_Statistic_1 := Initial_General_Statistics_Statistic_1 + 1 
    FormatTime, Final_General_Statistics_Statistic_2, %gameSectionStartHour%, dddd MMMM d, yyyy hh:mm:ss tt
    Final_General_Statistics_Statistic_4 := Initial_General_Statistics_Statistic_4 + ElapsedTime
    Final_General_Statistics_Statistic_3 := round(Final_General_Statistics_Statistic_4/Final_General_Statistics_Statistic_1)
    Final_General_Statistics_Statistic_5 := Initial_General_Statistics_Statistic_5 + ElapsedTime
    Final_General_Statistics_Statistic_6 := Initial_General_Statistics_Statistic_6 + ElapsedTime
    log("Updated Statistics: Number_of_Times_Played: " . Final_General_Statistics_Statistic_1 . "`r`n`t`t`t`t`tLast_Time_Played: " . Final_General_Statistics_Statistic_2 . "`r`n`t`t`t`t`tAverage_Time_Played: " . Final_General_Statistics_Statistic_3 . "`r`n`t`t`t`t`tTotal_Time_Played: " . Final_General_Statistics_Statistic_4 . "`r`n`t`t`t`t`tSystem_Total_Played_Time: " . Final_General_Statistics_Statistic_5 . "`r`n`t`t`t`t`tTotal_Global_Played_Time: " . Final_General_Statistics_Statistic_6,5)
    ; Saving simple statistics
    RIni_SetKeyValue(1,"General","System_Total_Played_Time",Final_General_Statistics_Statistic_5)
    RIni_SetKeyValue(2,"General","Total_Global_Played_Time",Final_General_Statistics_Statistic_6)
    RIni_SetKeyValue(1,dbName,"Number_of_Times_Played",Final_General_Statistics_Statistic_1)
    RIni_SetKeyValue(1,dbName,"Last_Time_Played",Final_General_Statistics_Statistic_2)        
    RIni_SetKeyValue(1,dbName,"Average_Time_Played",Final_General_Statistics_Statistic_3)        
    RIni_SetKeyValue(1,dbName,"Total_Time_Played",Final_General_Statistics_Statistic_4)
    ;Updating statistic values to aggregate multidisc rom statistics
    If (Totaldiscsofcurrentgame>1){ 
        Final_General_Statistics_Statistic_1 := 0
        Final_General_Statistics_Statistic_2 := 0
        Final_General_Statistics_Statistic_3 := 0
        Final_General_Statistics_Statistic_4 := 0
        loop %Totaldiscsofcurrentgame%
            {
            dbNameMultiDisc := romTable[a_index,3]
            Final_General_Statistics_Statistic_1 := Final_General_Statistics_Statistic_1 + RIni_GetKeyValue(1,dbNameMultiDisc,"Number_of_Times_Played", "0") 
            Final_General_Statistics_Statistic_4 := Final_General_Statistics_Statistic_4 + RIni_GetKeyValue(1,dbNameMultiDisc,"Total_Time_Played", "0") 
        }
        FormatTime, Final_General_Statistics_Statistic_2, %gameSectionStartHour%, dddd MMMM d, yyyy hh:mm:ss tt
        Final_General_Statistics_Statistic_3 := round(Final_General_Statistics_Statistic_4/Final_General_Statistics_Statistic_1)
        log("Aggregated Final Statistics to multidisc games:`r`n`t`t`t`t`tNumber_of_Times_Played: " . Final_General_Statistics_Statistic_1 . "`r`n`t`t`t`t`tLast_Time_Played: " . Final_General_Statistics_Statistic_2 . "`r`n`t`t`t`t`tAverage_Time_Played: " . Final_General_Statistics_Statistic_3 . "`r`n`t`t`t`t`tTotal_Time_Played: " . Final_General_Statistics_Statistic_4 . "`r`n`t`t`t`t`tSystem_Total_Played_Time: " . Final_General_Statistics_Statistic_5 . "`r`n`t`t`t`t`tTotal_Global_Played_Time: " . Final_General_Statistics_Statistic_6,5)
    }
    ;updating Top Ten tables 
    InitializeTopTenStatisticsFinalVariables() ;Top Ten Final variables
    UpdateStatisticsRomVariable("System_Top_Ten_Most_Played","Statistic_4","no")
    UpdateStatisticsRomVariable("System_Top_Ten_Times_Played","Statistic_1","no")
    UpdateStatisticsRomVariable("System_Top_Ten_Average_Time","Statistic_3","no")
    UpdateStatisticsRomVariable("Global_Top_Ten_Most_Played","Statistic_4","Global")
    UpdateStatisticsRomVariable("Global_Top_Ten_Times_Played","Statistic_1","Global")
    UpdateStatisticsRomVariable("Global_Top_Ten_Average_Time","Statistic_3","Global")
    UpdateStatisticsSystemVariable("Global_Top_Ten_System_Most_Played","Statistic_5")
    UpdateStatisticsLastPlayedGames()
    ; Saving Updated Statistics to ini files
    gosub, WritingStatisticstoFile ;writing statistics ini files
    log("Game section statistics updated.",1)
return



LoadStatistics:
    ;Description name without (Disc X)
    If (!romTable && mgCandidate)
        romTable:=CreateRomTable(dbName)
    Totaldiscsofcurrentgame:=romTable.MaxIndex()
    If (Totaldiscsofcurrentgame>1){ 
        DescriptionNameWithoutDisc := romTable[1,4]
        log("Statistics game name without disc info: " DescriptionNameWithoutDisc,5)
    } else {
        DescriptionNameWithoutDisc := dbName
    }
    stringsplit, DescriptionNameSplit, DescriptionNameWithoutDisc, "(", ;Only game  description name
    ClearDescriptionName := RegexReplace( DescriptionNameSplit1, "^\s+|\s+$" )
    log("Statistics cleared game name: " ClearDescriptionName,5)
    if (RIni_Read(1,HyperPause_StatisticsFile) = -11) {
        RIni_Create(1)
        RIni_AddSection(1,"General")
        RIni_AddSection(1,"TopTen_Time_Played")
        RIni_AddSection(1,"TopTen_Times_Played")
        RIni_AddSection(1,"Top_Ten_Average_Time_Played")
    }
    if (RIni_Read(2,HyperPause_GlobalStatisticsFile) = -11) {
        RIni_Create(2) 
        RIni_AddSection(2,"General")
        RIni_AddSection(2,"Last_Played_Games")
        RIni_AddSection(2,"TopTen_System_Most_Played")
        RIni_AddSection(2,"TopTen_Time_Played")
        RIni_AddSection(2,"TopTen_Times_Played")
        RIni_AddSection(2,"Top_Ten_Average_Time_Played")
    }
    Initial_General_Statistics_Statistic_1 := RIni_GetKeyValue(1,dbName,"Number_of_Times_Played","0")
    Initial_General_Statistics_Statistic_2 := RIni_GetKeyValue(1,dbName,"Last_Time_Played","0") 
    Initial_General_Statistics_Statistic_3 := RIni_GetKeyValue(1,dbName,"Average_Time_Played","0") 
    Initial_General_Statistics_Statistic_4 := RIni_GetKeyValue(1,dbName,"Total_Time_Played","0") 
    Initial_General_Statistics_Statistic_5 := RIni_GetKeyValue(1,"General","System_Total_Played_Time","0") 
    Initial_General_Statistics_Statistic_6 := RIni_GetKeyValue(2,"General","Total_Global_Played_Time","0") 
    loop, 10 {
        Initial_System_Top_Ten_Most_Played_Name_%a_index% := If RIni_GetKeyValue(1,"TopTen_Time_Played",A_index . "_Name", "") = -3 ? "" : RIni_GetKeyValue(1,"TopTen_Time_Played",A_index . "_Name", "")
        Initial_System_Top_Ten_Most_Played_Description_%a_index% := If RIni_GetKeyValue(1,"TopTen_Time_Played",A_index . "_Description", "") = -3 ? "" : RIni_GetKeyValue(1,"TopTen_Time_Played",A_index . "_Description", "")
        Initial_System_Top_Ten_Most_Played_Number_%a_index% := RIni_GetKeyValue(1,"TopTen_Time_Played",A_index . "_Time_Played", "0") 
        Initial_System_Top_Ten_Times_Played_Name_%a_index% := If RIni_GetKeyValue(1,"TopTen_Times_Played",A_index . "_Name", "") = -3 ? "" : RIni_GetKeyValue(1,"TopTen_Times_Played",A_index . "_Name", "")
        Initial_System_Top_Ten_Times_Played_Description_%a_index% := If RIni_GetKeyValue(1,"TopTen_Times_Played",A_index . "_Description", "") = -3 ? "" : RIni_GetKeyValue(1,"TopTen_Times_Played",A_index . "_Description", "")          
        Initial_System_Top_Ten_Times_Played_Number_%a_index% := RIni_GetKeyValue(1,"TopTen_Times_Played",A_index . "_Times_Played", "0")
        Initial_System_Top_Ten_Average_Time_Name_%a_index% := If RIni_GetKeyValue(1,"Top_Ten_Average_Time_Played",A_index . "_Name", "") = -3 ? "" : RIni_GetKeyValue(1,"Top_Ten_Average_Time_Played",A_index . "_Name", "")  
        Initial_System_Top_Ten_Average_Time_Description_%a_index% := If RIni_GetKeyValue(1,"Top_Ten_Average_Time_Played",A_index . "_Description", "") = -3 ? "" : RIni_GetKeyValue(1,"Top_Ten_Average_Time_Played",A_index . "_Description", "")        
        Initial_System_Top_Ten_Average_Time_Number_%a_index% := RIni_GetKeyValue(1,"Top_Ten_Average_Time_Played",A_index . "_Time_Played", "0")         
        Initial_Global_Last_Played_Games_System_%a_index% := If RIni_GetKeyValue(2,"Last_Played_Games",A_index . "_System", "") = -3 ? "" : RIni_GetKeyValue(2,"Last_Played_Games",A_index . "_System", "") 
        Initial_Global_Last_Played_Games_Name_%a_index% := If RIni_GetKeyValue(2,"Last_Played_Games",A_index . "_Name", "") = -3 ? "" : RIni_GetKeyValue(2,"Last_Played_Games",A_index . "_Name", "") 
        Initial_Global_Last_Played_Games_Description_%a_index% := If RIni_GetKeyValue(2,"Last_Played_Games",A_index . "_Description", "") = -3 ? "" : RIni_GetKeyValue(2,"Last_Played_Games",A_index . "_Description", "") 
        Initial_Global_Last_Played_Games_Date_%a_index% := If RIni_GetKeyValue(2,"Last_Played_Games",A_index . "_Date", "") = -3 ? "" : RIni_GetKeyValue(2,"Last_Played_Games",A_index . "_Date", "")  
        Initial_Global_Top_Ten_System_Most_Played_Name_%a_index% := If RIni_GetKeyValue(2,"TopTen_System_Most_Played",A_index . "_Name", "") = -3 ? "" : RIni_GetKeyValue(2,"TopTen_System_Most_Played",A_index . "_Name", "")  
        Initial_Global_Top_Ten_System_Most_Played_Number_%a_index% := If RIni_GetKeyValue(2,"TopTen_System_Most_Played",A_index . "_Time_Played", "") = -3 ? "" : RIni_GetKeyValue(2,"TopTen_System_Most_Played",A_index . "_Time_Played", "") 
        Initial_Global_Top_Ten_Most_Played_System_%a_index% := If RIni_GetKeyValue(2,"TopTen_Time_Played",A_index . "_System", "") = -3 ? "" : RIni_GetKeyValue(2,"TopTen_Time_Played",A_index . "_System", "") 
        Initial_Global_Top_Ten_Most_Played_Name_%a_index% := If RIni_GetKeyValue(2,"TopTen_Time_Played",A_index . "_Name", "") = -3 ? "" : RIni_GetKeyValue(2,"TopTen_Time_Played",A_index . "_Name", "") 
        Initial_Global_Top_Ten_Most_Played_Description_%a_index% := If RIni_GetKeyValue(2,"TopTen_Time_Played",A_index . "_Description", "") = -3 ? "" : RIni_GetKeyValue(2,"TopTen_Time_Played",A_index . "_Description", "") 
        Initial_Global_Top_Ten_Most_Played_Number_%a_index% := RIni_GetKeyValue(2,"TopTen_Time_Played",A_index . "_Time_Played", "0") 
        Initial_Global_Top_Ten_Times_Played_System_%a_index% := If RIni_GetKeyValue(2,"TopTen_Times_Played",A_index . "_System", "") = -3 ? "" : RIni_GetKeyValue(2,"TopTen_Times_Played",A_index . "_System", "")  
        Initial_Global_Top_Ten_Times_Played_Name_%a_index% := If RIni_GetKeyValue(2,"TopTen_Times_Played",A_index . "_Name", "") = -3 ? "" : RIni_GetKeyValue(2,"TopTen_Times_Played",A_index . "_Name", "") 
        Initial_Global_Top_Ten_Times_Played_Description_%a_index% := If RIni_GetKeyValue(2,"TopTen_Times_Played",A_index . "_Description", "") = -3 ? "" : RIni_GetKeyValue(2,"TopTen_Times_Played",A_index . "_Description", "") 
        Initial_Global_Top_Ten_Times_Played_Number_%a_index% := RIni_GetKeyValue(2,"TopTen_Times_Played",A_index . "_Times_Played", "0") 
        Initial_Global_Top_Ten_Average_Time_System_%a_index% := If RIni_GetKeyValue(2,"Top_Ten_Average_Time_Played",A_index . "_System", "") = -3 ? "" : RIni_GetKeyValue(2,"Top_Ten_Average_Time_Played",A_index . "_System", "") 
        Initial_Global_Top_Ten_Average_Time_Name_%a_index% := If RIni_GetKeyValue(2,"Top_Ten_Average_Time_Played",A_index . "_Name", "") = -3 ? "" : RIni_GetKeyValue(2,"Top_Ten_Average_Time_Played",A_index . "_Name", "") 
        Initial_Global_Top_Ten_Average_Time_Description_%a_index% := If RIni_GetKeyValue(2,"Top_Ten_Average_Time_Played",A_index . "_Description", "") = -3 ? "" : RIni_GetKeyValue(2,"Top_Ten_Average_Time_Played",A_index . "_Description", "") 
        Initial_Global_Top_Ten_Average_Time_Number_%a_index% := RIni_GetKeyValue(2,"Top_Ten_Average_Time_Played",A_index . "_Time_Played", "0") 
    }    
    statisticsLoaded := true
return

WritingStatisticstoFile:
    loop, 10 {
        RIni_SetKeyValue(1,"TopTen_Time_Played",A_index . "_Name",Final_System_Top_Ten_Most_Played_Name_%a_index%)
        RIni_SetKeyValue(1,"TopTen_Time_Played",A_index . "_Description" ,Final_System_Top_Ten_Most_Played_Description_%a_index%)
        RIni_SetKeyValue(1,"TopTen_Time_Played",A_index . "_Time_Played" ,Final_System_Top_Ten_Most_Played_Number_%a_index%)
        RIni_SetKeyValue(1,"TopTen_Times_Played",A_index . "_Name" ,Final_System_Top_Ten_Times_Played_Name_%a_index%)
        RIni_SetKeyValue(1,"TopTen_Times_Played",A_index . "_Description" ,Final_System_Top_Ten_Times_Played_Description_%a_index%)
        RIni_SetKeyValue(1,"TopTen_Times_Played",A_index . "_Times_Played" ,Final_System_Top_Ten_Times_Played_Number_%a_index%)
        RIni_SetKeyValue(1,"Top_Ten_Average_Time_Played",A_index . "_Name" ,Final_System_Top_Ten_Average_Time_Name_%a_index%)
        RIni_SetKeyValue(1,"Top_Ten_Average_Time_Played",A_index . "_Description" ,Final_System_Top_Ten_Average_Time_Description_%a_index%)
        RIni_SetKeyValue(1,"Top_Ten_Average_Time_Played",A_index . "_Time_Played" ,Final_System_Top_Ten_Average_Time_Number_%a_index%)
        RIni_SetKeyValue(2,"Last_Played_Games",A_index . "_System" ,Final_Global_Last_Played_Games_System_%a_index%)
        RIni_SetKeyValue(2,"Last_Played_Games",A_index . "_Name" ,Final_Global_Last_Played_Games_Name_%a_index%)
        RIni_SetKeyValue(2,"Last_Played_Games",A_index . "_Description" ,Final_Global_Last_Played_Games_Description_%a_index%)
        RIni_SetKeyValue(2,"Last_Played_Games",A_index . "_Date" ,Final_Global_Last_Played_Games_Date_%a_index%)
        RIni_SetKeyValue(2,"TopTen_System_Most_Played",A_index . "_Name" ,Final_Global_Top_Ten_System_Most_Played_Name_%a_index%)
        RIni_SetKeyValue(2,"TopTen_System_Most_Played",A_index . "_Time_Played" ,Final_Global_Top_Ten_System_Most_Played_Number_%a_index%)
        RIni_SetKeyValue(2,"TopTen_Time_Played",A_index . "_System" ,Final_Global_Top_Ten_Most_Played_System_%a_index%)
        RIni_SetKeyValue(2,"TopTen_Time_Played",A_index . "_Name" ,Final_Global_Top_Ten_Most_Played_Name_%a_index%)
        RIni_SetKeyValue(2,"TopTen_Time_Played",A_index . "_Description" ,Final_Global_Top_Ten_Most_Played_Description_%a_index%)
        RIni_SetKeyValue(2,"TopTen_Time_Played",A_index . "_Time_Played" ,Final_Global_Top_Ten_Most_Played_Number_%a_index%)
        RIni_SetKeyValue(2,"TopTen_Times_Played",A_index . "_System" ,Final_Global_Top_Ten_Times_Played_System_%a_index%)
        RIni_SetKeyValue(2,"TopTen_Times_Played",A_index . "_Name" ,Final_Global_Top_Ten_Times_Played_Name_%a_index%)
        RIni_SetKeyValue(2,"TopTen_Times_Played",A_index . "_Description" ,Final_Global_Top_Ten_Times_Played_Description_%a_index%)
        RIni_SetKeyValue(2,"TopTen_Times_Played",A_index . "_Times_Played" ,Final_Global_Top_Ten_Times_Played_Number_%a_index%)
        RIni_SetKeyValue(2,"Top_Ten_Average_Time_Played",A_index . "_System" ,Final_Global_Top_Ten_Average_Time_System_%a_index%)
        RIni_SetKeyValue(2,"Top_Ten_Average_Time_Played",A_index . "_Name" ,Final_Global_Top_Ten_Average_Time_Name_%a_index%)
        RIni_SetKeyValue(2,"Top_Ten_Average_Time_Played",A_index . "_Description" ,Final_Global_Top_Ten_Average_Time_Description_%a_index%)
        RIni_SetKeyValue(2,"Top_Ten_Average_Time_Played",A_index . "_Time_Played" ,Final_Global_Top_Ten_Average_Time_Number_%a_index%) 
    }
    RIni_Write(1,HyperPause_StatisticsFile,"`r`n",1,1,1)
    RIni_Write(2,HyperPause_GlobalStatisticsFile,"`r`n",1,1,1)
return 


InitializeTopTenStatisticsFinalVariables()
    {
    Global
    loop, 10 {
        Final_System_Top_Ten_Most_Played_Description_%a_index% := % Initial_System_Top_Ten_Most_Played_Description_%a_index%
        Final_System_Top_Ten_Most_Played_Name_%a_index% := % Initial_System_Top_Ten_Most_Played_Name_%a_index%
        Final_System_Top_Ten_Most_Played_Number_%a_index% := % Initial_System_Top_Ten_Most_Played_Number_%a_index%
        Final_System_Top_Ten_Times_Played_Description_%a_index% := % Initial_System_Top_Ten_Times_Played_Description_%a_index%
        Final_System_Top_Ten_Times_Played_Name_%a_index% := % Initial_System_Top_Ten_Times_Played_Name_%a_index%
        Final_System_Top_Ten_Times_Played_Number_%a_index% := % Initial_System_Top_Ten_Times_Played_Number_%a_index%
        Final_System_Top_Ten_Average_Time_Description_%a_index% := % Initial_System_Top_Ten_Average_Time_Description_%a_index%
        Final_System_Top_Ten_Average_Time_Name_%a_index% := % Initial_System_Top_Ten_Average_Time_Name_%a_index%
        Final_System_Top_Ten_Average_Time_Number_%a_index% := % Initial_System_Top_Ten_Average_Time_Number_%a_index%
        Final_Global_Last_Played_Games_System_%a_index% := % Initial_Global_Last_Played_Games_System_%a_index%
        Final_Global_Last_Played_Games_Description_%a_index% := % Initial_Global_Last_Played_Games_Description_%a_index%
        Final_Global_Last_Played_Games_Name_%a_index% := % Initial_Global_Last_Played_Games_Name_%a_index%
        Final_Global_Last_Played_Games_Date_%a_index% := % Initial_Global_Last_Played_Games_Date_%a_index%
        Final_Global_Top_Ten_System_Most_Played_Name_%a_index% := % Initial_Global_Top_Ten_System_Most_Played_Name_%a_index% 
        Final_Global_Top_Ten_System_Most_Played_Number_%a_index% := % Initial_Global_Top_Ten_System_Most_Played_Number_%a_index%
        Final_Global_Top_Ten_Most_Played_System_%a_index% := % Initial_Global_Top_Ten_Most_Played_System_%a_index%
        Final_Global_Top_Ten_Most_Played_Description_%a_index% := % Initial_Global_Top_Ten_Most_Played_Description_%a_index%
        Final_Global_Top_Ten_Most_Played_Name_%a_index% := % Initial_Global_Top_Ten_Most_Played_Name_%a_index%
        Final_Global_Top_Ten_Most_Played_Number_%a_index% := % Initial_Global_Top_Ten_Most_Played_Number_%a_index%
        Final_Global_Top_Ten_Times_Played_System_%a_index% := % Initial_Global_Top_Ten_Times_Played_System_%a_index%
        Final_Global_Top_Ten_Times_Played_Description_%a_index% := % Initial_Global_Top_Ten_Times_Played_Description_%a_index%
        Final_Global_Top_Ten_Times_Played_Name_%a_index% := % Initial_Global_Top_Ten_Times_Played_Name_%a_index%
        Final_Global_Top_Ten_Times_Played_Number_%a_index% := % Initial_Global_Top_Ten_Times_Played_Number_%a_index%
        Final_Global_Top_Ten_Average_Time_System_%a_index% := % Initial_Global_Top_Ten_Average_Time_System_%a_index%
        Final_Global_Top_Ten_Average_Time_Description_%a_index% := % Initial_Global_Top_Ten_Average_Time_Description_%a_index%
        Final_Global_Top_Ten_Average_Time_Name_%a_index% := % Initial_Global_Top_Ten_Average_Time_Name_%a_index%
        Final_Global_Top_Ten_Average_Time_Number_%a_index% := % Initial_Global_Top_Ten_Average_Time_Number_%a_index%
    }
return
}


UpdateStatisticsRomVariable(StatisticsTable,RelatedGeneralStatistic,GlobalSystemTest)
    {
    Global
    namefound = 0  
    Loop, 10 { ;removing rom info from statistics table
        currentplusone := a_index + 1
        TempDescriptionNameVar := % Final_%StatisticsTable%_Description_%a_index%
        TempSystemVar := % Final_%StatisticsTable%_System_%a_index%
        if(GlobalSystemTest="Global"){
            if(systemName = TempSystemVar){
                if(DescriptionNameWithoutDisc = TempDescriptionNameVar){
                    namefound = 1
                }
            }
        } else {
            if(DescriptionNameWithoutDisc = TempDescriptionNameVar){
                namefound = 1
            }
        }
        if (namefound = 1){
            Final_%StatisticsTable%_System_%a_index% := % Final_%StatisticsTable%_System_%currentplusone%
            Final_%StatisticsTable%_Description_%a_index% := % Final_%StatisticsTable%_Description_%currentplusone%
            Final_%StatisticsTable%_Name_%a_index% := % Final_%StatisticsTable%_Name_%currentplusone%
            Final_%StatisticsTable%_Number_%a_index% := % Final_%StatisticsTable%_Number_%currentplusone%
        }
    }
    Loop, 10 { ;adding new rom statistics to table
        inverse := 11 - a_index
        inverseplusone := 12 - a_index 
        TempCurrentStatisticVar := % Final_General_Statistics_%RelatedGeneralStatistic%
        TempStatisticVar := % Final_%StatisticsTable%_Number_%inverse%  
        TempCurrentStatisticVar += 0
        TempStatisticVar += 0
        if(TempCurrentStatisticVar > TempStatisticVar){
            Final_%StatisticsTable%_System_%inverseplusone% := % Final_%StatisticsTable%_System_%inverse%
            Final_%StatisticsTable%_Description_%inverseplusone% := % Final_%StatisticsTable%_Description_%inverse%
            Final_%StatisticsTable%_Name_%inverseplusone% := % Final_%StatisticsTable%_Name_%inverse%
            Final_%StatisticsTable%_Number_%inverseplusone% := % Final_%StatisticsTable%_Number_%inverse%        
            Final_%StatisticsTable%_System_%inverse% := % systemName
            Final_%StatisticsTable%_Description_%inverse% := % DescriptionNameWithoutDisc
            Final_%StatisticsTable%_Name_%inverse% := % ClearDescriptionName
            Final_%StatisticsTable%_Number_%inverse% := % Final_General_Statistics_%RelatedGeneralStatistic%       
        }
    }
return
}
   

UpdateStatisticsSystemVariable(StatisticsTable,RelatedGeneralStatistic)
    {
    Global
    namefound = 0  
    Loop, 10 { ;removing rom info from statistics table
        currentplusone := a_index + 1
        TempSystemVar := % Final_%StatisticsTable%_Name_%a_index%
        if(systemName = TempSystemVar){
            namefound = 1
        }
        if (namefound = 1){
            Final_%StatisticsTable%_Name_%a_index% := % Final_%StatisticsTable%_Name_%currentplusone%
            Final_%StatisticsTable%_Number_%a_index% := % Final_%StatisticsTable%_Number_%currentplusone%
        }
    }
    Loop, 10 { ;adding new rom statistics to table
        inverse := 11 - a_index
        inverseplusone := 12 - a_index 
        TempCurrentStatisticVar := % Final_General_Statistics_%RelatedGeneralStatistic%
        TempStatisticVar := % Final_%StatisticsTable%_Number_%inverse%
        TempCurrentStatisticVar += 0
        TempStatisticVar += 0
        if(TempCurrentStatisticVar > TempStatisticVar){
            Final_%StatisticsTable%_Name_%inverseplusone% := % Final_%StatisticsTable%_Name_%inverse%
            Final_%StatisticsTable%_Number_%inverseplusone% := % Final_%StatisticsTable%_Number_%inverse%        
            Final_%StatisticsTable%_Name_%inverse% := %  systemName
            Final_%StatisticsTable%_Number_%inverse% := % Final_General_Statistics_%RelatedGeneralStatistic%       
        }
    }
return
}
    
    
UpdateStatisticsLastPlayedGames()
    {
    Global
    namefound = 0  
    Loop, 10 { ;removing rom info from statistics table
        currentplusone := a_index + 1
        TempDescriptionNameVar := % Final_Global_Last_Played_Games_Description_%a_index%
        TempSystemVar := % Final_Global_Last_Played_Games_System_%a_index%
        if(DescriptionNameWithoutDisc = TempSystemVar){
            if(DescriptionName = TempDescriptionNameVar){
                namefound = 1
            }
        }
        if (namefound = 1){
            Final_Global_Last_Played_Games_System_%a_index% := % Final_Global_Last_Played_Games_System_%currentplusone%
            Final_Global_Last_Played_Games_Description_%a_index% := % Final_Global_Last_Played_Games_Description_%currentplusone%
            Final_Global_Last_Played_Games_Name_%a_index% := % Final_Global_Last_Played_Games_Name_%currentplusone%
            Final_Global_Last_Played_Games_Date_%a_index% := % Final_Global_Last_Played_Games_Date_%currentplusone%
        }
    }
    Loop, 10 { ;adding new rom statistics to table
        inverse := 11 - a_index
        inverseplusone := 12 - a_index
        Final_Global_Last_Played_Games_System_%inverseplusone% := % Final_Global_Last_Played_Games_System_%inverse%
        Final_Global_Last_Played_Games_Description_%inverseplusone% := % Final_Global_Last_Played_Games_Description_%inverse%
        Final_Global_Last_Played_Games_Name_%inverseplusone% := % Final_Global_Last_Played_Games_Name_%inverse%
        Final_Global_Last_Played_Games_Date_%inverseplusone% := % Final_Global_Last_Played_Games_Date_%inverse%
        Final_Global_Last_Played_Games_System_%inverse% := % systemName
        Final_Global_Last_Played_Games_Description_%inverse% := % DescriptionNameWithoutDisc
        Final_Global_Last_Played_Games_Name_%inverse% := % ClearDescriptionName
        Final_Global_Last_Played_Games_Date_%inverse% := % Final_General_Statistics_Statistic_2
    }
return   
}

