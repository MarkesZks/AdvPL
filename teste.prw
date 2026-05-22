#INCLUDE "TOTVS.ch"
#INCLUDE "PROTHEUS.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} XFINA677
PrestaÃ§Ã£o de Contas em Lote
@author Gabriel Marques Messias
@since 2026-05-21
@version 1.0
/*/
//-------------------------------------------------------------------

User Function XFINA677()

	Private cFiltraFLF	:= "FLF->FLF_STATUS == '6'"
    	Private cTitulo		:= "PrestaÃ§Ã£o de Contas em Lote"
        	Private oBrowse		:= NIL
            	Private aRotina		:= MenuDef()

                	oBrowse := FWMarkBrowse():New()
                    	oBrowse:SetAlias("FLF")
                        	oBrowse:SetFieldMark("FLF_XMARK")
                            	oBrowse:SetDescription(cTitulo)
                                	oBrowse:SetCacheView(.F.)
                                    	oBrowse:SetFilterDefault(cFiltraFLF)

                                        	oBrowse:AddLegend("FLF->FLF_STATUS == '1'", "GREEN"  , "Em aberto"                   )
                                            	oBrowse:AddLegend("FLF->FLF_STATUS == '2'", "YELLOW" , "Em conferÃªncia sem bloqueio" )
                                                	oBrowse:AddLegend("FLF->FLF_STATUS == '3'", "ORANGE" , "Em conferÃªncia com bloqueio" )
                                                    	oBrowse:AddLegend("FLF->FLF_STATUS == '4'", "PINK"   , "Em avaliaÃ§Ã£o do gestor"      )
                                                        	oBrowse:AddLegend("FLF->FLF_STATUS == '5'", "BLACK"  , "Reprovada"                   )
                                                            	oBrowse:AddLegend("FLF->FLF_STATUS == '6'", "BLUE"   , "Aprovada"                    )
                                                                	oBrowse:AddLegend("FLF->FLF_STATUS == '7'", "RED"    , "Em avaliaÃ§Ã£o do financeiro"  )
                                                                    	oBrowse:AddLegend("FLF->FLF_STATUS == '8'", "BROWN"  , "Finalizada"                  )
                                                                        	oBrowse:AddLegend("FLF->FLF_STATUS == '9'", "WHITE"  , "Faturada"                    )

                                                                            	oBrowse:Activate()

                                                                                Return

                                                                                //-------------------------------------------------------------------

                                                                                Static Function MenuDef()

                                                                                	Local aRotina := {}

                                                                                    	ADD OPTION aRotina TITLE "Liberar Financeiro Lote" ACTION "U_XF667LIB" OPERATION 10 ACCESS 0

                                                                                        Return aRotina

                                                                                        //-------------------------------------------------------------------

                                                                                        User Function XF667LIB()

                                                                                        	Local cMarca := oBrowse:Mark()

                                                                                            	If !MsgYesNo("Confirma liberaÃ§Ã£o...", "AtenÃ§Ã£o")
                                                                                                		Return
                                                                                                        	EndIf

                                                                                                            	Processa({|| U_XF677GER(cMarca)}, "Liberando...", "Processando...", .F.)

                                                                                                                	oBrowse:Refresh()

                                                                                                                    Return

                                                                                                                    //-------------------------------------------------------------------

                                                                                                                    User Function XF677GER(cMarca)

                                                                                                                    	Local cAlias := GetNextAlias()
                                                                                                                        	Local cQuery := ""
                                                                                                                            	Local nTotal := 0

                                                                                                                                	cQuery := " SELECT FLF.R_E_C_N_O_ REG "
                                                                                                                                    	cQuery += " FROM "   + RetSqlName("FLF") + " FLF "
                                                                                                                                        	cQuery += " WHERE FLF.D_E_L_E_T_ = ' ' "
                                                                                                                                            	cQuery += " AND FLF.FLF_XMARK  = '" + cMarca + "' "
                                                                                                                                                	cQuery += " AND FLF.FLF_STATUS = '6' "

                                                                                                                                                    	dbUseArea(.T., "TOPCONN", TCSqlQuery(cQuery), cAlias, .F., .T.)

                                                                                                                                                        	nTotal := (cAlias)->(LastRec())
                                                                                                                                                            	(cAlias)->(DbGoTop())
                                                                                                                                                                	ProcRegua(nTotal)

                                                                                                                                                                    	While !(cAlias)->(EOF())
                                                                                                                                                                        		IncProc()
                                                                                                                                                                                		FLF->(DbGoTo((cAlias)->REG))
                                                                                                                                                                                        		F677LIBFIN("FLF", FLF->(RecNo()), 10, .T., .F.)
                                                                                                                                                                                                		(cAlias)->(DbSkip())
                                                                                                                                                                                                        	EndDo

                                                                                                                                                                                                            	(cAlias)->(DbCloseArea())

                                                                                                                                                                                                                Return