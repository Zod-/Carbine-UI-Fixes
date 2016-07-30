require "Apollo"
_G.CarbineUIFixes = rawget(_G, "CarbineUIFixes") or {}

local ContextMenuPlayerFix = {}

local kstrRaidMarkerToSprite = {
  "Icon_Windows_UI_CRB_Marker_Bomb",
  "Icon_Windows_UI_CRB_Marker_Ghost",
  "Icon_Windows_UI_CRB_Marker_Mask",
  "Icon_Windows_UI_CRB_Marker_Octopus",
  "Icon_Windows_UI_CRB_Marker_Pig",
  "Icon_Windows_UI_CRB_Marker_Chicken",
  "Icon_Windows_UI_CRB_Marker_Toaster",
  "Icon_Windows_UI_CRB_Marker_UFO",
}

function ContextMenuPlayerFix:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function ContextMenuPlayerFix:Init()
  self.load = Apollo.GetAddon("ContextMenuPlayerFix") == nil
  self.dependencies = self.load and {"ContextMenuPlayer"} or {}
end

function ContextMenuPlayerFix:OnLoad()
  if not self.load then
    return
  end
  local cmp = Apollo.GetAddon("ContextMenuPlayer")
  cmp.RedrawAll = function ()
    self:RedrawAll(cmp)
  end
end

function ContextMenuPlayerFix:RedrawAll(self)
	if not self.wndMain or not self.wndMain:IsValid() then
		return
	end

	local bCrossFaction = self.bCrossFaction
	local strTarget = self.strTarget
	local unitTarget = self.unitTarget
	local wndButtonList = self.wndMain:FindChild("ButtonList")

	-- Repeated use booleans
	local unitPlayer = GameLib.GetPlayerUnit()
	local bInGroup = GroupLib.InGroup()
	local bAmIGroupLeader = GroupLib.AmILeader()
	local bBaseCrossFaction = unitTarget and unitTarget:GetBaseFaction() ~= unitPlayer:GetBaseFaction()
	local tMyGroupData = GroupLib.GetGroupMember(1)
	local tCharacterData = GameLib.SearchRelationshipStatusByCharacterName(strTarget)
	local tTargetGroupData = (tCharacterData and tCharacterData.nPartyIndex) and GroupLib.GetGroupMember(tCharacterData.nPartyIndex) or nil

	-----------------------------------------------------------------------------------------------
	-- Even if hostile/neutral
	-----------------------------------------------------------------------------------------------

	if unitTarget and unitTarget == unitPlayer:GetAlternateTarget()	 then
		self:HelperBuildRegularButton(wndButtonList, "BtnClearFocus", Apollo.GetString("ContextMenu_ClearFocus"))
	elseif unitTarget and unitTarget:GetHealth() ~= nil and unitTarget:GetType() ~= "Simple" then
		self:HelperBuildRegularButton(wndButtonList, "BtnSetFocus", Apollo.GetString("ContextMenu_SetFocus"))
	end

	if unitTarget and GameLib.GetPetDismissCommand(unitTarget) > 0 then
		self:HelperBuildPetDismissButton(wndButtonList, "BtnPetDismiss", Apollo.GetString("CRB_Dismiss"), unitTarget)
	end

	if unitTarget and bInGroup and tMyGroupData.bCanMark then
		self:HelperBuildRegularButton(wndButtonList, "BtnMarkTarget", Apollo.GetString("ContextMenu_MarkTarget"))

		local btnMarkerList = self:FactoryProduce(wndButtonList, "BtnMarkerList", "BtnMarkerList")
		local wndMarkerListItems = btnMarkerList:FindChild("MarkerListPopoutItems")
		btnMarkerList:AttachWindow(btnMarkerList:FindChild("MarkerListPopoutFrame"))

		for idx = 1, 8 do
			local wndCurr = self:FactoryProduce(wndMarkerListItems, "BtnMarkerIcon", "BtnMark"..idx)
			wndCurr:FindChild("BtnMarkerIconSprite"):SetSprite(kstrRaidMarkerToSprite[idx])
			wndCurr:FindChild("BtnMarkerMouseCatcher"):SetData("BtnMark"..idx)

			local nCurrentTargetMarker = unitTarget and unitTarget:GetTargetMarker() or ""
			if nCurrentTargetMarker == idx then
				wndCurr:SetCheck(true)
			end
		end

		local wndClear = self:FactoryProduce(wndMarkerListItems, "BtnMarkerIcon", "BtnMarkClear")
		wndClear:FindChild("BtnMarkerMouseCatcher"):SetData("BtnMarkClear")
		--wndClear:SetText("X")
	end

	if unitTarget and unitTarget:IsACharacter() and unitTarget ~= unitPlayer then
		self:HelperBuildRegularButton(wndButtonList, "BtnReportUnit", Apollo.GetString("ContextMenu_ReportPlayer"))
	elseif self.nReportId then -- No unit available
		self:HelperBuildRegularButton(wndButtonList, "BtnReportChat", Apollo.GetString("ContextMenu_ReportSpam"))
	end

	if unitTarget and (self.tPlayerFaction ~= unitTarget:GetFaction() or not unitTarget:IsACharacter()) then
		if unitTarget:IsACharacter() then
			if tCharacterData and tCharacterData.tFriend and tCharacterData.tFriend.bRival then
				self:HelperBuildRegularButton(wndButtonList, "BtnUnrival", Apollo.GetString("ContextMenu_RemoveRival"))
			else
				self:HelperBuildRegularButton(wndButtonList, "BtnAddRival", Apollo.GetString("ContextMenu_AddRival"))
			end
		end

		self:ResizeAndRedraw()
		return
	end

	-----------------------------------------------------------------------------------------------
	-- Early exit, else continue only if target is a character
	-----------------------------------------------------------------------------------------------

	if unitTarget and unitTarget:IsACharacter() then
		if unitTarget ~= unitPlayer then
			self:HelperBuildRegularButton(wndButtonList, "BtnInspect", Apollo.GetString("ContextMenu_Inspect"))

			-- Trade always visible, just enabled/disabled
			local eCanTradeResult = P2PTrading.CanInitiateTrade(unitTarget)
			local wndCurr = self:HelperBuildRegularButton(wndButtonList, "BtnTrade", Apollo.GetString("ContextMenu_Trade"))
			local bEnabled = eCanTradeResult == P2PTrading.P2PTradeError_Ok or eCanTradeResult == P2PTrading.P2PTradeError_TargetRangeMax
			local strTooltip = ""
			if not bEnabled then
				strTooltip = self.strTradeBtnTooltip
			end
			self:HelperEnableDisableRegularButton(wndCurr, bEnabled, strTooltip)

			-- Duel
			local eCurrentZonePvPRules = GameLib.GetCurrentZonePvpRules()
			if not eCurrentZonePvPRules or eCurrentZonePvPRules ~= GameLib.CodeEnumZonePvpRules.Sanctuary then
				if GameLib.GetDuelOpponent(unitPlayer) == unitTarget and GameLib.GetDuelState() == GameLib.CodeEnumDuelState.Dueling then
					self:HelperBuildRegularButton(wndButtonList, "BtnForfeit", Apollo.GetString("ContextMenu_ForfeitDuel"))
				else
					self:HelperBuildRegularButton(wndButtonList, "BtnDuel", Apollo.GetString("ContextMenu_Duel"))
				end
			end
		else
			-- PvP Flag
			self:UpdatePvpFlagBtn()
		end
	end

	if unitTarget == nil or unitTarget ~= unitPlayer then
		local bCanWhisper = not bBaseCrossFaction
		local bCanAccountWisper = false
		if tCharacterData and tCharacterData.tAccountFriend then
			bCanAccountWisper = true
			bCanWhisper = tCharacterData.tAccountFriend.arCharacters[1] ~= nil
				and tCharacterData.tAccountFriend.arCharacters[1].strRealm == GameLib.GetRealmName()
				and tCharacterData.tAccountFriend.arCharacters[1].nFactionId == GameLib.GetPlayerUnit():GetFaction()
		end

		if bCanWhisper and not bCanAccountWisper then
			self:HelperBuildRegularButton(wndButtonList, "BtnWhisper", Apollo.GetString("ContextMenu_Whisper"))
		end

		if bCanAccountWisper then
			self:HelperBuildRegularButton(wndButtonList, "BtnAccountWhisper", Apollo.GetString("ContextMenu_AccountWhisper"))
		end

		if (not bInGroup or (tMyGroupData.bCanInvite and (unitTarget and not unitTarget:IsInYourGroup()))) and not bCrossFaction then
			self:HelperBuildRegularButton(wndButtonList, "BtnInvite", Apollo.GetString("ContextMenu_InviteToGroup"))
		end

		if (not bInGroup or (unitTarget and not unitTarget:IsInYourGroup())) and not bCrossFaction then
			self:HelperBuildRegularButton(wndButtonList, "BtnJoin", Apollo.GetString("CRB_Join_Group"))
		end
	end

	-----------------------------------------------------------------------------------------------
	-- Social Lists
	-----------------------------------------------------------------------------------------------

	if unitTarget == nil or unitTarget ~= unitPlayer then
		local btnSocialList = self:FactoryProduce(wndButtonList, "BtnSocialList", "BtnSocialList")
		local wndSocialListItems = btnSocialList:FindChild("SocialListPopoutItems")
		btnSocialList:AttachWindow(btnSocialList:FindChild("SocialListPopoutFrame"))

		local bIsFriend = tCharacterData and tCharacterData.tFriend and tCharacterData.tFriend.bFriend
		local bIsRival = tCharacterData and tCharacterData.tFriend and tCharacterData.tFriend.bRival
		local bIsNeighbor = tCharacterData and tCharacterData.tNeighbor
		local bIsAccountFriend = tCharacterData and tCharacterData.tAccountFriend

		if bIsFriend then
			self:HelperBuildRegularButton(wndSocialListItems, "BtnUnfriend", Apollo.GetString("ContextMenu_RemoveFriend"))
		elseif not bBaseCrossFaction then
			self:HelperBuildRegularButton(wndSocialListItems, "BtnAddFriend", Apollo.GetString("ContextMenu_AddFriend"))
		end

		if bIsRival then
			self:HelperBuildRegularButton(wndSocialListItems, "BtnUnrival", Apollo.GetString("ContextMenu_RemoveRival"))
		else
			self:HelperBuildRegularButton(wndSocialListItems, "BtnAddRival", Apollo.GetString("ContextMenu_AddRival"))
		end

		if bIsNeighbor then
			self:HelperBuildRegularButton(wndSocialListItems, "BtnUnneighbor", Apollo.GetString("ContextMenu_RemoveNeighbor"))
		elseif not bBaseCrossFaction then
			self:HelperBuildRegularButton(wndSocialListItems, "BtnAddNeighbor", Apollo.GetString("ContextMenu_AddNeighbor"))
		end

		if bIsFriend and not bIsAccountFriend then
			self:HelperBuildRegularButton(wndSocialListItems, "BtnAccountFriend", Apollo.GetString("ContextMenu_PromoteFriend"))
		end

		if bIsAccountFriend then
			self:HelperBuildRegularButton(wndSocialListItems, "BtnUnaccountFriend", Apollo.GetString("ContextMenu_UnaccountFriend"))
			self.tAccountFriend = tCharacterData.tAccountFriend
		end

		if tCharacterData and tCharacterData.tFriend and tCharacterData.tFriend.bIgnore then
			self:HelperBuildRegularButton(wndSocialListItems, "BtnUnignore", Apollo.GetString("ContextMenu_Unignore"))
		else
			self:HelperBuildRegularButton(wndSocialListItems, "BtnIgnore", Apollo.GetString("ContextMenu_Ignore"))
		end

        if HousingLib.IsHousingWorld() then
	        self:HelperBuildRegularButton(wndSocialListItems, "BtnVisitPlayer", Apollo.GetString("CRB_Visit"))
	    end
	end

	-----------------------------------------------------------------------------------------------
	-- Group Lists
	-----------------------------------------------------------------------------------------------

	if bInGroup and unitTarget ~= unitPlayer then
		local btnGroupList = self:FactoryProduce(wndButtonList, "BtnGroupList", "BtnGroupList")
		local wndGroupListItems = btnGroupList:FindChild("GroupPopoutItems")
		btnGroupList:AttachWindow(btnGroupList:FindChild("GroupPopoutFrame"))

		-- see if tMygroupData is currently mentoring tTargetGroupData
		if tTargetGroupData then
			local bTargetingMentor = tTargetGroupData.nMenteeIdx == tMyGroupData.nMemberIdx
			local bTargetingMentee = tMyGroupData.nMenteeIdx == tTargetGroupData.nMemberIdx

			if tTargetGroupData.bIsOnline and not bTargetingMentee and tTargetGroupData.nLevel < tMyGroupData.nLevel then
				self:HelperBuildRegularButton(wndGroupListItems, "BtnMentor", Apollo.GetString("ContextMenu_Mentor"))
			end

			if (tMyGroupData.bIsMentoring and bTargetingMentee) or (tMyGroupData.bIsMentored and bTargetingMentor) then
				self:HelperBuildRegularButton(wndGroupListItems, "BtnStopMentor", Apollo.GetString("ContextMenu_StopMentor"))
			end

			if unitTarget then
				self:HelperBuildRegularButton(wndButtonList, "BtnLocate", Apollo.GetString("ContextMenu_Locate"))
			end

			if bAmIGroupLeader then
				self:HelperBuildRegularButton(wndGroupListItems, "BtnPromote", Apollo.GetString("ContextMenu_Promote"))
			end

			if tMyGroupData.bCanKick then
				self:HelperBuildRegularButton(wndGroupListItems, "BtnKick", Apollo.GetString("ContextMenu_Kick"))
			end

			local bInMatchingGame = MatchingGameLib.IsInGameInstance()
			local bIsMatchingGameFinished = MatchingGameLib.IsFinished()

			if bInMatchingGame and not bIsMatchingGameFinished then
				local wndCurr = self:HelperBuildRegularButton(wndGroupListItems, "BtnVoteToKick", Apollo.GetString("ContextMenu_VoteToKick"))
				self:HelperEnableDisableRegularButton(wndCurr, not MatchingGameLib.IsVoteKickActive(), "")
			end

			if bInMatchingGame and not bIsMatchingGameFinished then
				local tMatchState = MatchingGameLib.GetPvpMatchState()
				if not tMatchState or tMatchState.eRules ~= MatchingGameLib.Rules.DeathmatchPool then
					local wndCurr = self:HelperBuildRegularButton(wndGroupListItems, "BtnVoteToDisband", Apollo.GetString("ContextMenu_VoteToDisband"))
					self:HelperEnableDisableRegularButton(wndCurr, not MatchingGameLib.IsVoteSurrenderActive(), "")
				end
			end

			if bAmIGroupLeader then
				if tTargetGroupData.bCanKick then
					self:HelperBuildRegularButton(wndGroupListItems, "BtnGroupTakeKick", Apollo.GetString("ContextMenu_DenyKicks"))
				else
					self:HelperBuildRegularButton(wndGroupListItems, "BtnGroupGiveKick", Apollo.GetString("ContextMenu_AllowKicks"))
				end

				if tTargetGroupData.bCanInvite then
					self:HelperBuildRegularButton(wndGroupListItems, "BtnGroupTakeInvite", Apollo.GetString("ContextMenu_DenyInvites"))
				else
					self:HelperBuildRegularButton(wndGroupListItems, "BtnGroupGiveInvite", Apollo.GetString("ContextMenu_AllowInvites"))
				end

				if tTargetGroupData.bCanMark then
					self:HelperBuildRegularButton(wndGroupListItems, "BtnGroupTakeMark", Apollo.GetString("ContextMenu_DenyMarking"))
				else
					self:HelperBuildRegularButton(wndGroupListItems, "BtnGroupGiveMark", Apollo.GetString("ContextMenu_AllowMarking"))
				end
			end
		end

		if not tTargetGroupData and tMyGroupData.bCanInvite and not bCrossFaction then
			self:HelperBuildRegularButton(wndGroupListItems, "BtnInvite", Apollo.GetString("ContextMenu_Invite"))
		end

		if not tTargetGroupData and not bCrossFaction then
			self:HelperBuildRegularButton(wndGroupListItems, "BtnJoin", Apollo.GetString("CRB_Join_Group"))
		end

		if #btnGroupList:FindChild("GroupPopoutItems"):GetChildren() == 0 then
			btnGroupList:Destroy()
		end
	end

	if bInGroup and unitTarget == unitPlayer then
		self:HelperBuildRegularButton(wndButtonList, "BtnLeaveGroup", Apollo.GetString("ContextMenu_LeaveGroup"))
	end

	-----------------------------------------------------------------------------------------------
	-- Guild Options
	-----------------------------------------------------------------------------------------------
	local tMyRankPermissions = self.guildCurr and self.guildCurr:GetRanks()[self.guildCurr:GetMyRank()] or nil
	local bTargetIsUnderMyRank = self.guildCurr and self.guildCurr:GetMyRank() < self.tPlayerGuildData.nRank
	if self.tPlayerGuildData and self.guildCurr ~= nil and tMyRankPermissions.bChangeMemberRank and bTargetIsUnderMyRank then
		local btnGuildList = self:FactoryProduce(wndButtonList, "BtnGuildList", "BtnGuildList")
		local wndGuildListItems = btnGuildList:FindChild("GuildListPopoutItems")
		btnGuildList:AttachWindow(btnGuildList:FindChild("GuildListPopoutFrame"))

			if self.guildCurr then
				--[[if tMyRankPermissions.bKick then
				self:HelperBuildRegularButton(wndGuildListItems, "BtnKickFromGuild", Apollo.GetString("ContextMenu_KickFromGuild"))
				end]]--

				if bTargetIsUnderMyRank and self.tPlayerGuildData.nRank ~= 2 then
					self:HelperBuildRegularButton(wndGuildListItems, "BtnPromoteInGuild", Apollo.GetString("ContextMenu_Promote_Rank"))
				end

				if bTargetIsUnderMyRank and self.tPlayerGuildData.nRank ~= 10 then
					self:HelperBuildRegularButton(wndGuildListItems, "BtnDemoteInGuild", Apollo.GetString("ContextMenu_Demote_Rank"))
				end
			end

			if bTargetIsUnderMyRank and self.tPlayerGuildData.nRank ~= 10 then
				self:HelperBuildRegularButton(wndGuildListItems, "BtnDemoteInGuild", Apollo.GetString("ContextMenu_Demote_Rank"))
			end
		end


	self:ResizeAndRedraw()
end

_G.CarbineUIFixes.ContextMenuPlayerFix = ContextMenuPlayerFix:new()
