local addonName, ns = ...

PVPAuraDetectorDB = PVPAuraDetectorDB or {}

-- State variables
local isMonitoring = false
local lastReportedState = nil
local debounceTimer = nil
local pollingTicker = nil

-- Frame for event registration
local frame = CreateFrame("Frame")

local PARTY_UNITS = {"player", "party1", "party2", "party3", "party4"}

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
        if snapshot ~= lastReportedState then
            ReportMismatch(pvpOffNames)
            lastReportedState = snapshot
        end
    else
        lastReportedState = nil
    end
end

---------------------------------------------------------------------------
-- Debounce and Polling
---------------------------------------------------------------------------

local function ScheduleDebouncedCheck()
    if debounceTimer then
        debounceTimer:Cancel()
        debounceTimer = nil
    end
    debounceTimer = C_Timer.NewTimer(2, function()
        debounceTimer = nil
        PerformCheck()
    end)
end

local function StartPolling()
    if pollingTicker then return end
    pollingTicker = C_Timer.NewTicker(10, function()
        PerformCheck()
    end)
end

local function StopPolling()
    if pollingTicker then
        pollingTicker:Cancel()
        pollingTicker = nil
    end
end

---------------------------------------------------------------------------
-- Activation / Deactivation
---------------------------------------------------------------------------

local function EvaluateMonitoring()
    local inInstance = IsInInstance()
    local inGroup = IsInGroup()

    if inInstance and inGroup then
        if not isMonitoring then
            isMonitoring = true
            StartPolling()
            ScheduleDebouncedCheck()
        end
    else
        if isMonitoring then
            isMonitoring = false
            StopPolling()
            lastReportedState = nil
            if debounceTimer then
                debounceTimer:Cancel()
                debounceTimer = nil
            end
        end
    end
end

---------------------------------------------------------------------------
-- Event Dispatcher
---------------------------------------------------------------------------

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ZONE_CHANGED_NEW_AREA" or event == "GROUP_ROSTER_UPDATE" then
        EvaluateMonitoring()
        if isMonitoring then
            ScheduleDebouncedCheck()
        end
    elseif event == "UNIT_FLAGS" then
        if isMonitoring then
            ScheduleDebouncedCheck()
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
