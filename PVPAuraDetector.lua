local addonName, ns = ...

PVPAuraDetectorDB = PVPAuraDetectorDB or {}

-- State variables
local monitoringPhase = nil -- nil (inactive), 1 (gathering), 2 (event-driven)
local lastKnownState = nil
local pollingTicker = nil

-- Frame for event registration
local frame = CreateFrame("Frame")

local PARTY_UNITS = {"player", "party1", "party2", "party3", "party4"}

---------------------------------------------------------------------------
-- Instance Presence Verification
---------------------------------------------------------------------------

local function AreAllMembersInInstance()
    local playerMapID = C_Map.GetBestMapForUnit("player")
    if not playerMapID then return false end

    for i = 1, 4 do
        local unit = "party" .. i
        if UnitExists(unit) then
            local memberMapID = C_Map.GetBestMapForUnit(unit)
            if not memberMapID or memberMapID ~= playerMapID then
                return false
            end
        end
    end
    return true
end

---------------------------------------------------------------------------
-- PVP Flag Checking
---------------------------------------------------------------------------

local function CheckPartyPVPFlags()
    local flags = {}
    for _, unit in ipairs(PARTY_UNITS) do
        if UnitExists(unit) then
            local name = UnitName(unit)
            local isPVP = UnitIsPVP(unit) and true or false
            flags[#flags + 1] = {name = name, isPVP = isPVP}
        end
    end
    return flags
end

local function BuildStateSnapshot(flags)
    local sorted = {}
    for i, entry in ipairs(flags) do
        sorted[i] = entry
    end
    table.sort(sorted, function(a, b) return a.name < b.name end)

    local parts = {}
    for _, entry in ipairs(sorted) do
        parts[#parts + 1] = entry.name .. ":" .. (entry.isPVP and "1" or "0")
    end
    return table.concat(parts, ",")
end

local function DetectMismatch(flags)
    local hasPVPOn = false
    local hasPVPOff = false
    local pvpOffNames = {}

    for _, entry in ipairs(flags) do
        if entry.isPVP then
            hasPVPOn = true
        else
            hasPVPOff = true
            pvpOffNames[#pvpOffNames + 1] = entry.name
        end
    end

    return hasPVPOn and hasPVPOff, pvpOffNames
end

---------------------------------------------------------------------------
-- Reporting
---------------------------------------------------------------------------

local function ReportMismatch(pvpOffNames)
    local nameList = table.concat(pvpOffNames, ", ")
    local msg = "PVP Flag Mismatch! Group-wide buffs may not work correctly. PVP disabled: " .. nameList .. " -- type /pvp to enable."
    SendChatMessage(msg, "PARTY")
end

local function PerformCheck()
    local flags = CheckPartyPVPFlags()
    local isMismatch, pvpOffNames = DetectMismatch(flags)

    if isMismatch then
        local snapshot = BuildStateSnapshot(flags)
        if snapshot ~= lastKnownState then
            lastKnownState = snapshot
            ReportMismatch(pvpOffNames)
        end
    else
        lastKnownState = nil
    end
end

---------------------------------------------------------------------------
-- Polling
---------------------------------------------------------------------------

local function StopPolling()
    if pollingTicker then
        pollingTicker:Cancel()
        pollingTicker = nil
    end
end

local function StartPolling()
    if pollingTicker then return end
    pollingTicker = C_Timer.NewTicker(10, function()
        if monitoringPhase ~= 1 then return end
        if not AreAllMembersInInstance() then return end

        PerformCheck()

        -- All members verified inside, transition to Phase 2
        StopPolling()
        monitoringPhase = 2
    end)
end

---------------------------------------------------------------------------
-- Activation / Deactivation
---------------------------------------------------------------------------

local function EnterPhase1()
    monitoringPhase = 1
    StartPolling()
end

local function StopMonitoring()
    monitoringPhase = nil
    StopPolling()
    lastKnownState = nil
end

local function EvaluateMonitoring()
    local inInstance = IsInInstance()
    local inGroup = IsInGroup()

    if inInstance and inGroup then
        if not monitoringPhase then
            EnterPhase1()
        end
    else
        if monitoringPhase then
            StopMonitoring()
        end
    end
end

---------------------------------------------------------------------------
-- Phase 2 Handlers
---------------------------------------------------------------------------

local function HandlePhase2UnitFlags()
    if not AreAllMembersInInstance() then
        -- Member outside: return to Phase 1, preserve lastKnownState
        monitoringPhase = 1
        StartPolling()
        return
    end

    PerformCheck()
end

local function HandlePhase2RosterUpdate()
    -- Group composition changed: return to Phase 1, clear state
    lastKnownState = nil
    monitoringPhase = 1
    StartPolling()
end

---------------------------------------------------------------------------
-- Event Dispatcher
---------------------------------------------------------------------------

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ZONE_CHANGED_NEW_AREA" then
        EvaluateMonitoring()
    elseif event == "GROUP_ROSTER_UPDATE" then
        if monitoringPhase == 2 then
            HandlePhase2RosterUpdate()
        else
            EvaluateMonitoring()
        end
    elseif event == "UNIT_FLAGS" then
        if monitoringPhase == 2 then
            HandlePhase2UnitFlags()
        end
    end
end)

frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
frame:RegisterEvent("GROUP_ROSTER_UPDATE")
frame:RegisterEvent("UNIT_FLAGS")

---------------------------------------------------------------------------
-- Slash Command
---------------------------------------------------------------------------

SLASH_PVPCHECK1 = "/pvpcheck"
SlashCmdList["PVPCHECK"] = function()
    if not IsInInstance() then
        print("|cffff9900PVPAuraDetector:|r This command only works inside a dungeon instance.")
        return
    end

    local flags = CheckPartyPVPFlags()
    local isMismatch, pvpOffNames = DetectMismatch(flags)

    if isMismatch then
        ReportMismatch(pvpOffNames)
    else
        print("|cff00ff00PVPAuraDetector:|r All party members have the same PVP flag state.")
    end
end
