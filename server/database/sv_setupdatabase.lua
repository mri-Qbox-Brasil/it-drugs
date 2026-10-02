-- Setup the Database from the it_drugs.sql file
DatabaseSetuped = false

-- Statements run one at a time: on a fresh database an async ALTER could reach the server before its CREATE TABLE.
local function runSqlFile(path)
    local file = LoadResourceFile(GetCurrentResourceName(), path)

    for line in file:gsub("\r\n", "\n"):gmatch("[^\n]+") do
        local ok, response = pcall(MySQL.rawExecute.await, line, {})
        if ok and response then
            if Config.Debug then lib.print.info('Executed SQL Statment ' .. line) end
        else
            lib.print.error('Failed to execute SQL statement: ' .. line)
        end
    end
end

CreateThread(function()
    runSqlFile('server/database/drug_plants.sql')
    runSqlFile('server/database/drug_processing.sql')
    DatabaseSetuped = true
end)
